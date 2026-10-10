/// <reference path="../pb_data/types.d.ts" />
//
// Serveur ÉLAN : les quatre routes propres à l'app.
//
//   GET  /api/elan/etat            le serveur est-il prêt ? reste-t-il à créer le premier compte ?
//   POST /api/elan/premier-compte  crée le compte propriétaire, tant qu'aucun compte n'existe
//   POST /api/elan/courses         l'app envoie ses courses modifiées
//   GET  /api/elan/courses         l'app demande ce qui a changé depuis sa dernière synchro
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
  })
})

routerAdd("POST", "/api/elan/premier-compte", (e) => {
  const corps = e.requestInfo().body
  const email = String(corps.email || "").trim()
  const motDePasse = String(corps.password || "")
  if (email.indexOf("@") < 1 || motDePasse.length < 8) {
    throw new BadRequestError("Adresse e-mail ou mot de passe (8 caractères au moins) invalide.")
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
    e.app.runInTransaction((tx) => {
      const collection = tx.findCollectionByNameOrId("courses")
      // Horloge du serveur, strictement croissante : aucune modification ne peut échapper à une synchro.
      const derniere = tx.findRecordsByFilter("courses", "serveur_ms > 0", "-serveur_ms", 1, 0)
      let horloge = Math.max(Date.now(), derniere.length > 0 ? derniere[0].getInt("serveur_ms") + 1 : 0)

      for (let i = 0; i < courses.length; i++) {
        const cle = String(courses[i].id || "")
        if (cle === "") continue
        const modifie = Number(courses[i].modifie_ms) || 0

        let ligne = null
        try {
          ligne = tx.findFirstRecordByFilter("courses", "proprietaire = {:compte} && cle = {:cle}", { compte: compte, cle: cle })
        } catch (_) {
          // Première fois que le serveur voit cette course.
        }
        if (ligne && modifie < ligne.getInt("modifie_ms")) continue

        if (!ligne) {
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
