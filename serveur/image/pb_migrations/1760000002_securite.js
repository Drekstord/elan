/// <reference path="../pb_data/types.d.ts" />
// Serveur ÉLAN 1.2 : sécurité.
//
// - Sessions de 60 jours au lieu de 180. L'app renouvelle sa session à chaque ouverture : on reste
//   connecté tant qu'on s'en sert, mais un appareil perdu ou oublié n'ouvre plus le compte ensuite.
// - Création du premier compte : 10 essais par minute (le code d'installation la protège déjà).
migrate(
  (app) => {
    const users = app.findCollectionByNameOrId("users")
    unmarshal({ authToken: { duration: 5184000 } }, users)
    app.save(users)

    const reglages = app.settings()
    const regles = reglages.rateLimits.rules.map((r) => ({
      label: r.label,
      audience: r.audience,
      duration: r.duration,
      maxRequests: r.label === "/api/elan/premier-compte" ? 10 : r.maxRequests,
    }))
    unmarshal({ rateLimits: { enabled: true, rules: regles } }, reglages)
    app.save(reglages)
  },
  (app) => {
    const users = app.findCollectionByNameOrId("users")
    unmarshal({ authToken: { duration: 15552000 } }, users)
    app.save(users)
  },
)
