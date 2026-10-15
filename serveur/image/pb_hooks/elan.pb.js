/// <reference path="../pb_data/types.d.ts" />
//
// Serveur ÉLAN : les routes propres à l'app.
//
//   GET  /api/elan/etat                 le serveur est-il prêt ? reste-t-il à créer le premier compte ?
//   POST /api/elan/premier-compte       crée le compte propriétaire, avec le code d'installation
//   POST /api/elan/courses              l'app envoie ses courses modifiées
//   GET  /api/elan/courses              l'app demande ce qui a changé depuis sa dernière synchro
//   POST /api/elan/deconnecter-partout  ferme les sessions des autres appareils du compte
//
// Et deux commandes de secours, lancées dans le conteneur (voir le guide) :
//   /pb/mot-de-passe-proprietaire NOUVEAU_MOT_DE_PASSE
//   /pb/fermer-administration
//
// Le reste (connexion, comptes, fichiers) passe par les routes standard de PocketBase,
// avec les règles d'accès de pb_migrations.
//
// Chaque fonction est autonome : PocketBase les exécute séparément, sans variables partagées.

// Version du protocole entre l'app et le serveur.
routerAdd("GET", "/api/elan/etat", (e) => {
  return e.json(200, {
    serveur: "elan",
    version: 1,
    premierCompte: e.app.countRecords("users") === 0,
    // Le premier compte demande le code d'installation (serveur 1.2 et suivants).
    code: true,
  })
})

// Serveur tout neuf : un code d'installation, à saisir dans l'app pour créer le premier compte.
// Sans lui, n'importe qui sur le réseau pourrait se déclarer propriétaire avant toi.
// Il est écrit dans donnees/code-premier-compte.txt et dans le journal du conteneur.
onBootstrap((e) => {
  e.next()
  if (e.app.countRecords("users") > 0) return
  const chemin = e.app.dataDir() + "/code-premier-compte.txt"
  let code = ""
  try {
    code = toString($os.readFile(chemin)).trim()
  } catch (_) {
    // Pas encore de code.
  }
  if (code === "") {
    code = $security.randomStringWithAlphabet(8, "ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
    // Octets du texte (le code n'a que des lettres et des chiffres simples).
    const octets = (code + "\n").split("").map((c) => c.charCodeAt(0))
    $os.writeFile(chemin, octets, 0o644)
  }
  console.log("Serveur ÉLAN : code d'installation " + code + " (aussi dans donnees/code-premier-compte.txt)")
})

routerAdd("POST", "/api/elan/premier-compte", (e) => {
  const corps = e.requestInfo().body
  const email = String(corps.email || "").trim()
  const motDePasse = String(corps.password || "")
  if (email.indexOf("@") < 1 || motDePasse.length < 8) {
    throw new BadRequestError("Adresse e-mail ou mot de passe (8 caractères au moins) invalide.")
  }
  const chemin = e.app.dataDir() + "/code-premier-compte.txt"
  let attendu = ""
  try {
    attendu = toString($os.readFile(chemin)).trim()
  } catch (_) {
    // Fichier absent : refusé ci-dessous (un redémarrage du serveur en crée un).
  }
  const code = String(corps.code || "").trim().toUpperCase()
  if (attendu === "" || code !== attendu) {
    throw new UnauthorizedError("Code d'installation incorrect : il est dans le fichier code-premier-compte.txt du dossier donnees.")
  }

  let cree = false
  e.app.runInTransaction((tx) => {
    if (tx.countRecords("users") > 0) return
    const compte = new Record(tx.findCollectionByNameOrId("users"))
    compte.set("email", email)
    compte.set("password", motDePasse)
    compte.set("verified", true)
    compte.set("proprietaire", true)
    tx.save(compte)
    cree = true
  })
  if (!cree) throw new ForbiddenError("Ce serveur a déjà un compte : connecte-toi, ou demande un compte à son propriétaire.")
  try {
    $os.remove(chemin)
  } catch (_) {
    // Déjà retiré.
  }
  return e.noContent(204)
})

// Envoi : { courses: [ { id, modifie_ms, donnees: { ...la course } } ] }
// Une version plus ancienne que celle du serveur est ignorée (la plus récente gagne).
routerAdd(
  "POST",
  "/api/elan/courses",
  (e) => {
    const courses = e.requestInfo().body.courses || []
    const compte = e.auth.id
    // L'app envoie par lots de 200 ; au-delà, l'envoi est refusé (disque du NAS protégé).
    if (courses.length > 500) throw new BadRequestError("Trop de courses dans un seul envoi (500 au plus).")
    // Une horloge d'appareil en avance ne doit pas bloquer les modifications faites ailleurs.
    const plafond = Date.now() + 5 * 60 * 1000
    // Au plus 20 000 courses par compte.
    let place = 20000 - e.app.countRecords("courses", $dbx.hashExp({ proprietaire: compte }))
    e.app.runInTransaction((tx) => {
      const collection = tx.findCollectionByNameOrId("courses")
      // Horloge du serveur, strictement croissante : aucune modification ne peut échapper à une synchro.
      const derniere = tx.findRecordsByFilter("courses", "serveur_ms > 0", "-serveur_ms", 1, 0)
      let horloge = Math.max(Date.now(), derniere.length > 0 ? derniere[0].getInt("serveur_ms") + 1 : 0)

      for (let i = 0; i < courses.length; i++) {
        const cle = String(courses[i].id || "")
        if (cle === "") continue
        const modifie = Math.min(Number(courses[i].modifie_ms) || 0, plafond)

        let ligne = null
        try {
          ligne = tx.findFirstRecordByFilter("courses", "proprietaire = {:compte} && cle = {:cle}", { compte: compte, cle: cle })
        } catch (_) {
          // Première fois que le serveur voit cette course.
        }
        if (ligne && modifie < ligne.getInt("modifie_ms")) continue

        if (!ligne) {
          if (place-- <= 0) throw new BadRequestError("Ce compte a atteint 20 000 courses.")
          ligne = new Record(collection)
          ligne.set("proprietaire", compte)
          ligne.set("cle", cle)
        }
        ligne.set("donnees", courses[i].donnees)
        ligne.set("modifie_ms", modifie)
        ligne.set("serveur_ms", horloge++)
        tx.save(ligne)
      }
    })
    return e.noContent(204)
  },
  $apis.requireAuth("users"),
)

// Réception : ?depuis=<serveur_ms de la dernière course reçue>&limite=500
// Réponse : { courses: [ { serveur_ms, donnees } ] }, dans l'ordre d'arrivée sur le serveur.
routerAdd(
  "GET",
  "/api/elan/courses",
  (e) => {
    const requete = e.request.url.query()
    const depuis = parseInt(requete.get("depuis") || "0", 10) || 0
    const limite = Math.min(parseInt(requete.get("limite") || "500", 10) || 500, 1000)
    const lignes = e.app.findRecordsByFilter(
      "courses",
      "proprietaire = {:compte} && serveur_ms > {:depuis}",
      "serveur_ms",
      limite,
      0,
      { compte: e.auth.id, depuis: depuis },
    )
    const courses = []
    for (let i = 0; i < lignes.length; i++) {
      courses.push({
        serveur_ms: lignes[i].getInt("serveur_ms"),
        donnees: JSON.parse(lignes[i].getString("donnees")),
      })
    }
    return e.json(200, { courses: courses })
  },
  $apis.requireAuth("users"),
)

// Ferme toutes les sessions du compte, sauf celle de l'appareil qui le demande (renvoyée à neuf).
routerAdd(
  "POST",
  "/api/elan/deconnecter-partout",
  (e) => {
    const compte = e.app.findRecordById("users", e.auth.id)
    compte.refreshTokenKey()
    e.app.save(compte)
    return $apis.recordAuthResponse(e, compte, "")
  },
  $apis.requireAuth("users"),
)

// Au plus 10 000 photos et justificatifs par compte (disque du NAS protégé).
onRecordCreateRequest((e) => {
  const compte = e.auth ? e.auth.id : ""
  if (compte !== "" && e.app.countRecords("fichiers", $dbx.hashExp({ proprietaire: compte })) >= 10000) {
    throw new BadRequestError("Ce compte a atteint 10 000 fichiers.")
  }
  e.next()
}, "fichiers")

// Commande de secours : nouveau mot de passe pour le propriétaire du serveur, sans passer par le
// panneau d'administration (aucun compte « superuser » à créer, donc aucun à oublier).
$app.rootCmd.addCommand(
  new Command({
    use: "mot-de-passe-proprietaire",
    short: "Donne un nouveau mot de passe au propriétaire du serveur ÉLAN",
    run: (cmd, args) => {
      const motDePasse = String(args[0] || "")
      if (motDePasse.length < 8) {
        console.log("Indique le nouveau mot de passe (8 caractères au moins) après la commande.")
        return
      }
      const proprietaire = $app.findFirstRecordByFilter("users", "proprietaire = true")
      proprietaire.setPassword(motDePasse)
      $app.save(proprietaire)
      console.log("Mot de passe changé pour " + proprietaire.getString("email") + ". Connecte-toi dans l'app avec lui.")
    },
  }),
)

// Commande de secours : ferme le panneau d'administration de PocketBase. Chaque compte
// d'administration (créé par l'ancienne procédure « mot de passe perdu », par exemple) reçoit un
// mot de passe aléatoire que personne ne connaît. PocketBase interdit de supprimer le dernier :
// c'est la façon sûre de le neutraliser.
$app.rootCmd.addCommand(
  new Command({
    use: "fermer-administration",
    short: "Neutralise les comptes d'administration de PocketBase (mot de passe aléatoire)",
    run: (cmd, args) => {
      const comptes = $app.findAllRecords("_superusers")
      for (let i = 0; i < comptes.length; i++) {
        comptes[i].setPassword($security.randomString(48))
        $app.save(comptes[i])
      }
      console.log("Administration fermée : " + comptes.length + " compte(s) neutralisé(s). Les comptes de l'app ne changent pas.")
    },
  }),
)
