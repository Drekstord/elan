/// <reference path="../pb_data/types.d.ts" />
//
// Serveur ÉLAN : structure des données et réglages, appliqués au premier démarrage.
//
//   users     les comptes. Le premier créé est « propriétaire » du serveur : lui seul
//             peut ajouter ou retirer des comptes. Pas d'inscription libre, pas d'e-mail.
//   courses   les courses de chacun, telles que l'app les envoie (voir pb_hooks/elan.pb.js).
//   fichiers  photos et justificatifs, chacun les siens.
//
// Une évolution de structure = un nouveau fichier ici (jamais de modification de celui-ci).
migrate((app) => {
  // ------------------------------------------------------------------
  // Comptes
  // ------------------------------------------------------------------
  const users = app.findCollectionByNameOrId("users")
  users.fields.add(new BoolField({ name: "proprietaire" }))

  const proprietaire = "@request.auth.proprietaire = true"
  users.listRule = `id = @request.auth.id || ${proprietaire}`
  users.viewRule = `id = @request.auth.id || ${proprietaire}`
  users.createRule = proprietaire
  // Chacun modifie son compte (sans pouvoir se nommer propriétaire) ; le propriétaire, tous.
  users.updateRule = `(id = @request.auth.id && @request.body.proprietaire:isset = false) || ${proprietaire}`
  users.deleteRule = `${proprietaire} && id != @request.auth.id`
  // Le propriétaire peut redonner un mot de passe sans connaître l'ancien.
  users.manageRule = proprietaire
  unmarshal(
    {
      // Session de 180 jours, renouvelée à chaque ouverture de l'app.
      authToken: { duration: 15552000 },
      // Aucun e-mail n'est envoyé par ce serveur.
      authAlert: { enabled: false },
    },
    users,
  )
  app.save(users)

  // ------------------------------------------------------------------
  // Courses : accès uniquement par les routes /api/elan/courses
  // ------------------------------------------------------------------
  app.save(
    new Collection({
      type: "base",
      name: "courses",
      fields: [
        { name: "proprietaire", type: "relation", required: true, collectionId: users.id, cascadeDelete: true, maxSelect: 1 },
        // Identifiant de la course dans l'app.
        { name: "cle", type: "text", required: true, max: 200 },
        // La course complète, au format de l'app : un champ ajouté dans l'app ne demande rien ici.
        { name: "donnees", type: "json", maxSize: 2000000 },
        // Dernière modification côté app : la plus récente gagne.
        { name: "modifie_ms", type: "number" },
        // Ordre d'arrivée sur le serveur : repère de synchronisation des appareils.
        { name: "serveur_ms", type: "number" },
      ],
      indexes: [
        "CREATE UNIQUE INDEX idx_courses_cle ON courses (proprietaire, cle)",
        "CREATE INDEX idx_courses_serveur ON courses (proprietaire, serveur_ms)",
      ],
    }),
  )

  // ------------------------------------------------------------------
  // Fichiers : photos et justificatifs
  // ------------------------------------------------------------------
  const lesSiens = "proprietaire = @request.auth.id"
  app.save(
    new Collection({
      type: "base",
      name: "fichiers",
      listRule: lesSiens,
      viewRule: lesSiens,
      createRule: `@request.auth.id != "" && ${lesSiens}`,
      updateRule: `${lesSiens} && @request.body.proprietaire:isset = false`,
      deleteRule: lesSiens,
      fields: [
        { name: "proprietaire", type: "relation", required: true, collectionId: users.id, cascadeDelete: true, maxSelect: 1 },
        // Nom du fichier dans l'app : « <compte>/<identifiant>.jpg ».
        { name: "cle", type: "text", required: true, max: 300 },
        // Lisible seulement avec un jeton de son propriétaire.
        { name: "fichier", type: "file", required: true, maxSelect: 1, maxSize: 15728640, protected: true },
      ],
      indexes: ["CREATE UNIQUE INDEX idx_fichiers_cle ON fichiers (proprietaire, cle)"],
    }),
  )

  // ------------------------------------------------------------------
  // Réglages du serveur
  // ------------------------------------------------------------------
  const reglages = app.settings()
  unmarshal(
    {
      meta: { appName: "ÉLAN", hideControls: true },
      // Copie complète (base et fichiers) chaque nuit dans donnees/backups, 7 gardées.
      backups: { cron: "0 3 * * *", cronMaxKeep: 7 },
      logs: { maxDays: 7 },
      // Frein aux essais de mots de passe en rafale.
      rateLimits: {
        enabled: true,
        rules: [
          { label: "*:auth", audience: "", duration: 10, maxRequests: 10 },
          { label: "/api/elan/premier-compte", audience: "", duration: 60, maxRequests: 5 },
          { label: "/api/", audience: "", duration: 10, maxRequests: 1000 },
        ],
      },
    },
    reglages,
  )
  app.save(reglages)
})
