import '../../courses/domain/course.dart';
import '../domain/association.dart';

/// Associations et programmes courants, proposés sans connexion.
/// Les identifiants officiels (SIREN, RNA) ne sont renseignés que par la
/// recherche en ligne, depuis la source officielle.
const List<Association> associationCatalog = [
  Association(
    id: 'the-conqueror',
    name: 'The Conqueror (Eden Reforestation & Plastic Bank)',
    cause: CauseType.environnement,
    description:
        'Défis virtuels : chaque défi terminé finance la plantation d\'arbres (jusqu\'à 4) '
        'et le retrait de bouteilles plastiques (jusqu\'à 40).',
    declaredMetrics: [ImpactMetric.trees, ImpactMetric.oceanBottles],
  ),
  Association(
    id: 'afm-telethon',
    name: 'AFM-Téléthon',
    cause: CauseType.sante,
    description: 'Guérir les maladies rares génétiques et neuromusculaires grâce à la recherche biomédicale.',
  ),
  Association(
    id: 'wings-for-life',
    name: 'Wings for Life World Run',
    cause: CauseType.handicap,
    description:
        'Trouver un remède aux lésions de la moelle épinière. Les frais de participation sont reversés à la recherche.',
  ),
  Association(
    id: 'restos-du-coeur',
    name: 'Les Restos du Cœur',
    cause: CauseType.precarite,
    description: 'Aider les personnes démunies, notamment par l\'accès à des repas gratuits.',
    declaredMetrics: [ImpactMetric.meals],
  ),
  Association(
    id: 'ruban-rose-odyssea',
    name: 'Ruban Rose & Odysséa',
    cause: CauseType.sante,
    description: 'Sensibiliser au dépistage du cancer du sein et financer la recherche.',
  ),
  Association(
    id: 'msf',
    name: 'Médecins Sans Frontières (MSF)',
    cause: CauseType.sante,
    description:
        'Assistance médicale d\'urgence aux populations victimes de conflits, d\'épidémies ou de catastrophes.',
    declaredMetrics: [ImpactMetric.careKits],
  ),
  Association(
    id: 'wwf-france',
    name: 'WWF France',
    cause: CauseType.environnement,
    description: 'Protéger la biodiversité et lutter contre le changement climatique.',
  ),
  Association(
    id: 'secours-populaire',
    name: 'Secours Populaire Français',
    cause: CauseType.precarite,
    description: 'Agir contre la pauvreté et l\'exclusion en France et dans le monde.',
    declaredMetrics: [ImpactMetric.meals],
  ),
  Association(
    id: 'spa',
    name: 'Société Protectrice des Animaux (SPA)',
    cause: CauseType.animaux,
    description: 'Lutter contre la maltraitance animale, recueillir et faire adopter les animaux abandonnés.',
    declaredMetrics: [ImpactMetric.animalMeals],
  ),
  Association(
    id: 'action-contre-la-faim',
    name: 'Action contre la Faim',
    cause: CauseType.precarite,
    description: 'Prévenir, dépister et traiter la sous-nutrition dans le monde.',
    declaredMetrics: [ImpactMetric.meals],
  ),
  Association(
    id: 'snsm',
    name: 'SNSM (Sauveteurs en Mer)',
    cause: CauseType.sante,
    description: 'Sauvetage en mer et surveillance des plages, assurés par des bénévoles.',
  ),
  Association(
    id: 'afsr-syndrome-rett',
    name: 'Association Française du Syndrome de Rett (AFSR)',
    cause: CauseType.handicap,
    description:
        'Accompagner les familles, soutenir la prise en charge médicale et rééducative des personnes '
        'atteintes et financer la recherche sur le syndrome de Rett.',
  ),
];
