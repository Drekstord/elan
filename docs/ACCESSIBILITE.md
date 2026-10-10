# ÉLAN : déclaration d'accessibilité

Référentiel : **RGAA 4.1**, appliqué à une application (Windows, Android) à travers ses critères
transposables et la norme européenne **EN 301 549** (dont le RGAA est la déclinaison française).

**État : partiellement conforme.** La mise en conformité a été faite et vérifiée par des tests
automatiques ; aucun audit humain avec lecteurs d'écran (NVDA, TalkBack) n'a encore été mené.
Seul un tel audit permettrait d'annoncer un taux de conformité RGAA.

## Ce qui est en place

| Thème RGAA | Mesure dans ÉLAN | Vérification |
|---|---|---|
| Couleurs (3.2, 3.3) | Contraste ≥ 4,5:1 pour le texte, ≥ 3:1 pour les contrôles et les graphiques, en clair, en sombre et avec 5 fonds Material You | `test/design/contrast_test.dart` (calcul WCAG sur les vraies couleurs) |
| Couleurs (3.1) | Aucune information par la couleur seule : statuts, filtres et séries de graphique ont un texte ou une légende | Revue des écrans |
| Images (1.1 à 1.3) | Photos de médaille et de dossard décrites (« Médaille : Semi-marathon de Démoville ») ; miniatures et emblème décoratifs ignorés | `test/a11y/a11y_test.dart` |
| Graphiques (1.8, 1.9) | Barres lues mois par mois (« Mars 2026 : 21,2 km, 1 course ») ; courbe de cumul et allures décrites ; vue Tableau dans Évolution | `test/a11y/a11y_test.dart` |
| Structure (9.1) | Titres de section et titre de chaque course déclarés comme titres | `test/a11y/a11y_test.dart` |
| Liens et boutons (6.1, 11.9) | Chaque bouton et zone cliquable a un nom lisible (infobulles, libellés) | Contrôle automatique « nom » sur les 15 écrans |
| Cibles tactiles | Au moins 48 × 48 | Contrôle automatique « cible 48 » sur les 15 écrans |
| Agrandissement du texte (10.4) | Utilisable à 200 % : rien ne déborde, les lignes se resserrent ou passent à la ligne | Contrôle automatique à 200 % sur les 15 écrans |
| Lecture (8.3, 10.1) | Langue de l'app : français ; titres affichés en capitales lus en casse normale | Revue du code |
| Formulaires (11.1, 11.10) | Chaque champ a une étiquette ; erreurs affichées sous le champ concerné, toutes à la fois | Tests du formulaire |
| Animations (13.8) | Chiffres animés au lancement désactivés si le système demande de réduire les animations ; les lecteurs d'écran lisent la valeur finale | `test/features/count_up_test.dart` |
| Consultation (13.1) | Aucune limite de temps pour agir | Revue des écrans |

## Limites connues

- **Pas d'audit avec de vrais lecteurs d'écran.** Les tests vérifient ce que l'app annonce, pas
  l'expérience complète avec NVDA (Windows) ou TalkBack (Android).
- **Courbe et nuage de points** : décrits par un résumé (valeurs finales, liste des courses), pas
  explorables point par point ; la vue Tableau d'Évolution donne toutes les valeurs.
- **Carte de partage et image du bilan** : ce sont des images à publier ; leur texte n'est pas lisible
  par un lecteur d'écran une fois exportées. Le texte du bilan (« Copier le texte ») en est l'équivalent.
- **Messages de confirmation** (« Texte copié… ») : affichés quelques secondes en bas de l'écran.

## Garder la conformité

Les tests d'accessibilité font partie de la suite : `flutter test` échoue si un écran déborde à 200 %,
si un bouton perd son nom, si une cible devient trop petite ou si un contraste passe sous le seuil.
Ils tournent aussi à chaque construction automatique de l'APK sur GitHub.
