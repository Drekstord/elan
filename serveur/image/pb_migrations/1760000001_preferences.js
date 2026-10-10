/// <reference path="../pb_data/types.d.ts" />
// Serveur ÉLAN 1.1 : préférences du compte.
//
// Un champ de plus sur les comptes, pour que les réglages personnels (objectif annuel…)
// suivent d'un appareil à l'autre. Chacun ne lit et ne modifie que les siens : les règles
// d'accès des comptes, posées à l'installation, s'appliquent telles quelles.
migrate(
  (app) => {
    const users = app.findCollectionByNameOrId("users")
    users.fields.add(new JSONField({ name: "preferences", maxSize: 20000 }))
    app.save(users)
  },
  (app) => {
    const users = app.findCollectionByNameOrId("users")
    users.fields.removeByName("preferences")
    app.save(users)
  },
)
