// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'ÉLAN';

  @override
  String get appTagline => 'Sport & Impact';

  @override
  String get signInTitle => 'Connexion';

  @override
  String get signInIntro => 'Connecte-toi avec le compte créé pour toi sur ÉLAN.';

  @override
  String get emailLabel => 'Adresse e-mail';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get signInButton => 'Se connecter';

  @override
  String get signInInvalidEmail => 'Adresse e-mail invalide.';

  @override
  String get signInMissingPassword => 'Saisis ton mot de passe.';

  @override
  String get signInWrongCredentials => 'E-mail ou mot de passe incorrect.';

  @override
  String get signInRateLimited => 'Trop de tentatives. Patiente une minute avant de réessayer.';

  @override
  String get signInOffline => 'Impossible de joindre le serveur. Vérifie ta connexion.';

  @override
  String get signInForgotten => 'Mot de passe oublié ? Demande à l\'administrateur d\'ÉLAN de le réinitialiser.';

  @override
  String get navCourses => 'Courses';

  @override
  String get navImpact => 'Impact';

  @override
  String get navEvolution => 'Évolution';

  @override
  String get navRecords => 'Records';

  @override
  String get navSettings => 'Réglages';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get close => 'Fermer';

  @override
  String get retry => 'Réessayer';

  @override
  String get typeOfficial => 'Course officielle';

  @override
  String get typeConqueror => 'Défi The Conqueror';

  @override
  String get statusUpcoming => 'À venir';

  @override
  String get statusAwaiting => 'Résultat à saisir';

  @override
  String get statusAwaitingShort => 'À saisir';

  @override
  String get statusCompleted => 'Terminée';

  @override
  String get causeSante => 'Santé & recherche';

  @override
  String get causeEnvironnement => 'Environnement & climat';

  @override
  String get causePrecarite => 'Précarité & faim';

  @override
  String get causeEnfance => 'Enfance & éducation';

  @override
  String get causeAnimaux => 'Protection animale';

  @override
  String get causeHandicap => 'Handicap & inclusion';

  @override
  String get causeAutre => 'Autre cause';

  @override
  String get metricTrees => 'Arbres plantés';

  @override
  String get metricOceanBottles => 'Bouteilles plastiques retirées';

  @override
  String get metricCareSessions => 'Séances de soins';

  @override
  String get metricResearchHours => 'Heures de recherche';

  @override
  String get metricMeals => 'Repas distribués';

  @override
  String get metricCareKits => 'Kits de soins';

  @override
  String get metricAnimalMeals => 'Repas pour animaux';

  @override
  String get metricNone => 'Aucune équivalence';

  @override
  String get distance5k => '5 km';

  @override
  String get distance10k => '10 km';

  @override
  String get distanceHalf => 'Semi-marathon';

  @override
  String get distanceMarathon => 'Marathon';

  @override
  String get statDistance => 'Distance';

  @override
  String get statDonations => 'Fonds engagés';

  @override
  String get statRaces => 'Courses';

  @override
  String get statTime => 'Temps de course';

  @override
  String get statElevation => 'Dénivelé +';

  @override
  String get statPace => 'Allure moyenne';

  @override
  String get coursesEmpty => 'Aucune course pour l\'instant. Ajoute ta première course ou inscris une course à venir.';

  @override
  String get coursesNoMatch => 'Aucune course ne correspond.';

  @override
  String get coursesAdd => 'Nouvelle course';

  @override
  String get coursesSearch => 'Rechercher une course, une association…';

  @override
  String get filterAll => 'Toutes';

  @override
  String get filterCharity => 'Solidaires';

  @override
  String get kindAll => 'Toutes';

  @override
  String get kindOfficial => 'Officielles';

  @override
  String get kindChallenge => 'Défis';

  @override
  String get filterReset => 'Effacer les filtres';

  @override
  String get filterSolidarity => 'Volet solidaire';

  @override
  String get filterSolidarityAll => 'Solidaires ou non';

  @override
  String get filterSolidarityOnly => 'Solidaires uniquement';

  @override
  String summaryCourses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses',
      one: '1 course',
      zero: 'Aucune course',
    );
    return '$_temp0';
  }

  @override
  String summaryOfficial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses officielles',
      one: '1 course officielle',
      zero: 'Aucune course officielle',
    );
    return '$_temp0';
  }

  @override
  String summaryChallenges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count défis',
      one: '1 défi',
      zero: 'Aucun défi',
    );
    return '$_temp0';
  }

  @override
  String summarySolidarity(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'solidaires', one: 'solidaire');
    return '$_temp0';
  }

  @override
  String get sectionAwaiting => 'Résultat à saisir';

  @override
  String get sectionUpcoming => 'À venir';

  @override
  String get sectionDone => 'Terminées';

  @override
  String sectionSummary(int count, String distance) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count courses', one: '1 course');
    return '$_temp0 · $distance';
  }

  @override
  String get filterCause => 'Cause';

  @override
  String get sortRaceDate => 'Date de course';

  @override
  String get sortAddedDate => 'Date d\'ajout';

  @override
  String get sortTooltip => 'Trier';

  @override
  String get sortAscending => 'Plus anciennes d\'abord';

  @override
  String get sortDescending => 'Plus récentes d\'abord';

  @override
  String awaitingBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses attendent ton résultat',
      one: '1 course attend ton résultat',
    );
    return '$_temp0';
  }

  @override
  String get recordBadge => 'Record';

  @override
  String get nextRace => 'Prochaine course';

  @override
  String get last12Months => 'Kilomètres sur les 12 derniers mois';

  @override
  String get formNewTitle => 'Nouvelle course';

  @override
  String get formEditTitle => 'Modifier la course';

  @override
  String get formPlanned => 'Course à venir';

  @override
  String get formPlannedHint => 'Inscris-la maintenant, tu saisiras ton temps après la course.';

  @override
  String get formName => 'Nom de la course';

  @override
  String get formDate => 'Date';

  @override
  String get formDistance => 'Distance (km)';

  @override
  String get formDuration => 'Temps (h:mm:ss)';

  @override
  String get formElevation => 'Dénivelé positif (m)';

  @override
  String get formImportGpx => 'Importer un fichier GPX';

  @override
  String formGpxImported(String distance, String duration) {
    return 'Trace importée : $distance, $duration.';
  }

  @override
  String get formGpxError => 'Ce fichier GPX est illisible.';

  @override
  String get formTeam => 'Défi en équipe';

  @override
  String get formChallengeDistance => 'Distance totale du défi (km)';

  @override
  String get formTeamSize => 'Nombre de membres';

  @override
  String formPersonalShare(String distance) {
    return 'Ta part : $distance';
  }

  @override
  String get formCharity => 'Course solidaire';

  @override
  String get formCharityHint => 'Liée à une association et à des dons.';

  @override
  String get formAssociation => 'Association';

  @override
  String get formChooseAssociation => 'Choisir une association';

  @override
  String get formSponsor => 'Parrainage (€ par km)';

  @override
  String get formRegistration => 'Don sur l\'inscription (€)';

  @override
  String get formFundraising => 'Collecte / cagnotte (€)';

  @override
  String formDonationTotal(String amount) {
    return 'Total engagé : $amount';
  }

  @override
  String get formImpact => 'Équivalence annoncée par l\'organisateur';

  @override
  String get formImpactHint => 'Facultatif. Uniquement si l\'organisateur l\'annonce (ex. 4 arbres plantés).';

  @override
  String get formImpactUnit => 'Unité';

  @override
  String get formImpactQuantity => 'Quantité';

  @override
  String get formPhotos => 'Souvenirs';

  @override
  String get formMedal => 'Médaille';

  @override
  String get formBib => 'Dossard';

  @override
  String get formAddPhoto => 'Ajouter une photo';

  @override
  String get formNotes => 'Notes';

  @override
  String get issueMissingTitle => 'Donne un nom à la course.';

  @override
  String get issueDistance => 'La distance doit être supérieure à 0.';

  @override
  String get issueNegative => 'Une valeur négative est impossible.';

  @override
  String get issueCompletedInFuture => 'Cette date est dans le futur : coche « Course à venir ».';

  @override
  String get issuePlannedWithResult => 'Une course à venir n\'a pas encore de temps.';

  @override
  String get issueTeamSize => 'Nombre de membres invalide.';

  @override
  String get issueImpactQuantity => 'La quantité doit être positive.';

  @override
  String issueImpactCap(String max) {
    return 'Au-delà du plafond annoncé ($max maximum).';
  }

  @override
  String get issueInvalidNumber => 'Nombre invalide.';

  @override
  String get issueInvalidDuration => 'Format attendu : h:mm:ss';

  @override
  String get assoSearchHint => 'Nom de l\'association';

  @override
  String get assoCatalog => 'Associations courantes';

  @override
  String get assoOfficial => 'Répertoire officiel';

  @override
  String get assoSearching => 'Recherche dans le répertoire officiel…';

  @override
  String get assoSearchOffline => 'Recherche en ligne indisponible. Choisis dans la liste ou saisis le nom.';

  @override
  String assoFree(String name) {
    return 'Utiliser « $name »';
  }

  @override
  String get assoCause => 'Cause soutenue';

  @override
  String get assoNoResult => 'Aucun résultat.';

  @override
  String get detailNotFound => 'Cette course n\'existe plus.';

  @override
  String get detailPerformance => 'Performance';

  @override
  String get detailTime => 'Temps';

  @override
  String get detailPace => 'Allure';

  @override
  String get detailSpeed => 'Vitesse';

  @override
  String get detailUpcomingInfo => 'Course prévue. Tu pourras saisir ton résultat à partir du jour J.';

  @override
  String get detailAwaitingInfo => 'La course a eu lieu : saisis ton temps pour l\'ajouter à tes totaux et records.';

  @override
  String get detailEnterResult => 'Saisir mon résultat';

  @override
  String detailTeam(int count, String distance) {
    return 'En équipe de $count · défi de $distance';
  }

  @override
  String get detailSolidarity => 'Volet solidaire';

  @override
  String get detailSponsor => 'Parrainage';

  @override
  String get detailRegistration => 'Inscription';

  @override
  String get detailFundraising => 'Collecte';

  @override
  String get detailDonationTotal => 'Total engagé';

  @override
  String get detailDeclaredImpact => 'Impact annoncé';

  @override
  String get deleteCourseTitle => 'Supprimer cette course ?';

  @override
  String get deleteCourseBody => 'Elle sera supprimée sur tous tes appareils.';

  @override
  String get resultTitle => 'Mon résultat';

  @override
  String get shareTitle => 'Partager la course';

  @override
  String get shareSave => 'Enregistrer l\'image';

  @override
  String get shareShare => 'Partager';

  @override
  String get shareSaved => 'Image enregistrée.';

  @override
  String shareFor(String association) {
    return 'pour $association';
  }

  @override
  String get impactTitle => 'Mon impact';

  @override
  String get impactHonesty =>
      'Seuls l\'argent réellement engagé et les équivalences annoncées par les organisateurs sont comptés.';

  @override
  String impactCharityRaces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses solidaires',
      one: '1 course solidaire',
      zero: 'Aucune course solidaire',
    );
    return '$_temp0';
  }

  @override
  String impactCharityDistance(String distance) {
    return '$distance courus pour une cause';
  }

  @override
  String get impactDeclared => 'Impact annoncé';

  @override
  String impactKmFor(String cause) {
    return 'Courus pour $cause';
  }

  @override
  String get reportTitle => 'Bilan d\'engagement';

  @override
  String get reportAction => 'Faire un bilan pour un rapport';

  @override
  String get reportPresetSchool => 'Année scolaire';

  @override
  String reportPresetYear(int year) {
    return 'Année $year';
  }

  @override
  String get reportPresetLast12 => '12 derniers mois';

  @override
  String get reportPresetCustom => 'Dates choisies';

  @override
  String reportFrom(String date) {
    return 'Du $date';
  }

  @override
  String reportTo(String date) {
    return 'Au $date';
  }

  @override
  String get reportCharityOnly => 'Seulement les courses solidaires';

  @override
  String get reportTextTitle => 'Texte pour ton rapport';

  @override
  String get reportCopyText => 'Copier le texte';

  @override
  String get reportCopyTable => 'Copier le tableau';

  @override
  String get reportCopied => 'Texte copié : colle-le dans ton rapport.';

  @override
  String get reportTableCopied => 'Tableau copié : colle-le dans Word ou Excel.';

  @override
  String get reportImageTitle => 'Image du bilan';

  @override
  String get reportEmpty => 'Aucune course terminée sur cette période.';

  @override
  String reportHeading(String from, String to) {
    return 'Bilan ÉLAN du $from au $to';
  }

  @override
  String get reportSectionSolidarity => 'ENGAGEMENT SOLIDAIRE';

  @override
  String reportCharityLine(int count, String distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses solidaires, soit $distance courus pour des causes.',
      one: '1 course solidaire, soit $distance courus pour une cause.',
    );
    return '$_temp0';
  }

  @override
  String reportDonationLine(String amount) {
    return '$amount engagés (dons, parrainages et collectes).';
  }

  @override
  String reportDeclaredLine(String list) {
    return 'Impact annoncé par les organisateurs : $list.';
  }

  @override
  String reportCausesLine(String list) {
    return 'Causes soutenues : $list.';
  }

  @override
  String reportAssociationsLine(String list) {
    return 'Associations soutenues : $list.';
  }

  @override
  String get reportNoCharity => 'Aucune course solidaire sur la période.';

  @override
  String get reportSectionCourses => 'DÉTAIL DES COURSES';

  @override
  String get reportSectionSport => 'ACTIVITÉ SPORTIVE';

  @override
  String reportSportLine(int count, String distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses terminées',
      one: '1 course terminée',
    );
    return '$_temp0, $distance au total.';
  }

  @override
  String reportTimeLine(String time) {
    return 'Temps de course : $time.';
  }

  @override
  String reportElevationLine(String elevation) {
    return 'Dénivelé positif : $elevation.';
  }

  @override
  String reportPeriod(String from, String to) {
    return 'Du $from au $to';
  }

  @override
  String get reportAnd => 'et';

  @override
  String get reportStyleProse => 'Rédigé';

  @override
  String get reportStyleBullets => 'Points clés';

  @override
  String get reportExcel => 'Fichier Excel';

  @override
  String get reportTotal => 'Total';

  @override
  String get reportSheetName => 'Bilan';

  @override
  String reportSheetSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count courses', one: '1 course');
    return 'Généré par ÉLAN · $_temp0';
  }

  @override
  String get fileSaved => 'Fichier enregistré.';

  @override
  String get datePickerToday => 'Aujourd\'hui';

  @override
  String reportProseIntro(int count, String from, String to, String distance) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count courses', one: 'une course');
    return 'Du $from au $to, j\'ai participé à $_temp0, pour un total de $distance parcourus.';
  }

  @override
  String get reportProseNoCharity => 'Aucune de ces courses n\'était solidaire.';

  @override
  String reportProseAllCharity(int count, String distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Toutes étaient solidaires',
      one: 'Elle était solidaire',
    );
    return '$_temp0, soit $distance courus au profit de causes.';
  }

  @override
  String reportProseCharity(int count, String distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count d\'entre elles étaient solidaires',
      one: 'L\'une d\'elles était solidaire',
    );
    return '$_temp0, soit $distance courus au profit de causes.';
  }

  @override
  String reportProseChallenges(int count, String distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ce total comprend $count défis au long cours (The Conqueror), qui représentent $distance à eux seuls.',
      one: 'Ce total comprend un défi au long cours (The Conqueror), qui représente $distance à lui seul.',
    );
    return '$_temp0';
  }

  @override
  String reportProseDonations(String amount) {
    return 'Ces courses ont permis d\'engager $amount en faveur d\'associations (dons, parrainages et collectes).';
  }

  @override
  String reportProseDonationsCauses(String amount, String causes) {
    return 'Ces courses ont permis d\'engager $amount en faveur d\'associations (dons, parrainages et collectes), notamment pour $causes.';
  }

  @override
  String reportProseDeclared(String list) {
    return 'Les organisateurs annoncent par ailleurs un impact concret : $list.';
  }

  @override
  String reportProseAssociations(int count, String list) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Les associations soutenues sont $list.',
      one: 'L\'association soutenue est $list.',
    );
    return '$_temp0';
  }

  @override
  String reportProseRaces(String list) {
    return 'Courses solidaires : $list.';
  }

  @override
  String reportProseSport(String parts) {
    return 'Sur le plan sportif, cela représente $parts.';
  }

  @override
  String reportProseTime(String time) {
    return '$time de course';
  }

  @override
  String reportProseElevation(String elevation) {
    return '$elevation de dénivelé positif';
  }

  @override
  String reportProsePace(String pace) {
    return 'une allure moyenne de $pace';
  }

  @override
  String reportPaceLine(String pace) {
    return 'Allure moyenne : $pace.';
  }

  @override
  String get reportChallengeTag => 'défi';

  @override
  String reportDistanceTime(String distance, String time) {
    return '$distance en $time';
  }

  @override
  String get reportTableHeader =>
      'Date\tCourse\tType\tDistance (km)\tTemps\tAllure (min/km)\tD+ (m)\tAssociation\tCause\tFonds engagés (€)\tImpact annoncé';

  @override
  String get reportWordHeader => 'Date\tCourse\tDistance et temps\tAssociation et cause\tFonds engagés\tImpact annoncé';

  @override
  String get reportCopyForWord => 'Pour Word (tableau compact)';

  @override
  String get reportCopyForExcel => 'Pour Excel (toutes les colonnes)';

  @override
  String get reportCardTitle => 'Bilan d\'engagement';

  @override
  String reportCardFor(String list) {
    return 'Pour $list';
  }

  @override
  String get impactCharityDistanceLabel => 'Distance solidaire';

  @override
  String get impactByCause => 'Par cause';

  @override
  String get impactAssociations => 'Associations soutenues';

  @override
  String get impactByYear => 'Fonds engagés par année';

  @override
  String get impactByYearHint => 'Dons, parrainages et collectes des courses solidaires terminées.';

  @override
  String get legendDonations => 'Fonds engagés (€)';

  @override
  String get impactEmpty => 'Aucune course solidaire terminée pour l\'instant.';

  @override
  String get docTitle => 'Justificatifs';

  @override
  String get docAdd => 'Ajouter un justificatif';

  @override
  String docAdded(String course) {
    return 'Justificatif ajouté à « $course ».';
  }

  @override
  String get docTooBig => 'Fichier trop lourd : 10 Mo maximum.';

  @override
  String get docUnavailable => 'Justificatif indisponible pour le moment : vérifie ta connexion.';

  @override
  String get docRemoveTitle => 'Retirer ce justificatif ?';

  @override
  String docRemoveBody(String name) {
    return '« $name » sera supprimé sur tous tes appareils.';
  }

  @override
  String docAddedOn(String date) {
    return 'ajouté le $date';
  }

  @override
  String get docActions => 'Actions';

  @override
  String get docOpen => 'Ouvrir';

  @override
  String get docSave => 'Enregistrer';

  @override
  String get docRemove => 'Retirer';

  @override
  String get docEmptyCourse => 'Aucun justificatif. Ajoute la facture d\'inscription ou le reçu de don (PDF ou photo).';

  @override
  String get docZip => 'Tout exporter (ZIP)';

  @override
  String docZipMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count justificatifs indisponibles n\'ont pas été inclus (hors connexion ?).',
      one: '1 justificatif indisponible n\'a pas été inclus (hors connexion ?).',
    );
    return '$_temp0';
  }

  @override
  String get docAllDates => 'Toutes les dates';

  @override
  String get docSearch => 'Rechercher une course, une association, un fichier…';

  @override
  String docCount(int count, int courses) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count justificatifs',
      one: '1 justificatif',
    );
    String _temp1 = intl.Intl.pluralLogic(courses, locale: localeName, other: '$courses courses', one: '1 course');
    return '$_temp0 · $_temp1';
  }

  @override
  String get docEmpty =>
      'Aucun justificatif pour l\'instant. Ajoute-les depuis la fiche d\'une course ou avec le bouton ci-dessous.';

  @override
  String get docNoMatch => 'Aucun justificatif sur cette période.';

  @override
  String get docChooseCourse => 'Rattacher à quelle course ?';

  @override
  String get docKindConfirmation => 'Mail de confirmation';

  @override
  String get docKindInvoice => 'Facture';

  @override
  String get docKindReceipt => 'Reçu de don';

  @override
  String get docKindResult => 'Résultat de course';

  @override
  String get docKindOther => 'Autre document';

  @override
  String get docChooseKind => 'Quel type de justificatif ?';

  @override
  String get docChangeKind => 'Changer le type';

  @override
  String get reportDocsZip => 'Justificatifs (ZIP)';

  @override
  String get assoTitle => 'Association';

  @override
  String get assoNotFound => 'Aucune course solidaire terminée pour cette association.';

  @override
  String get assoCourses => 'Courses pour cette association';

  @override
  String get assoExport => 'Récapitulatif à partager';

  @override
  String get assoCardTitle => 'Récapitulatif';

  @override
  String assoRecapTitle(String name) {
    return 'Récapitulatif ÉLAN : $name';
  }

  @override
  String assoRecapLine(int count, String from, String to, String distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses solidaires',
      one: '1 course solidaire',
    );
    return '$_temp0 du $from au $to, soit $distance courus pour l\'association.';
  }

  @override
  String assoRecapLineOne(String date, String distance) {
    return '1 course solidaire le $date, soit $distance courus pour l\'association.';
  }

  @override
  String assoCauses(int count, String list) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Causes soutenues', one: 'Cause soutenue');
    return '$_temp0 : $list.';
  }

  @override
  String assoOpen(String name) {
    return 'Voir le récapitulatif de $name';
  }

  @override
  String docCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count justificatifs',
      one: '1 justificatif',
    );
    return '$_temp0';
  }

  @override
  String get evolutionTitle => 'Évolution';

  @override
  String get rangeLast12 => '12 derniers mois';

  @override
  String get rangeLast12Short => '12 mois';

  @override
  String get rangeByMonth => 'Par mois';

  @override
  String get rangeByYear => 'Par année';

  @override
  String get summaryLast12 => 'Sur les 12 derniers mois';

  @override
  String summaryYear(int year) {
    return 'En $year';
  }

  @override
  String summaryAll(int year) {
    return 'Depuis $year';
  }

  @override
  String get compareLast12 => 'Flèches : variation par rapport aux 12 mois précédents.';

  @override
  String compareYearToDate(int year, String date) {
    return 'Flèches : variation par rapport à $year à la même date ($date).';
  }

  @override
  String compareYear(int year) {
    return 'Flèches : variation par rapport à $year.';
  }

  @override
  String get deltaNew => 'nouveau';

  @override
  String get periodEmpty => 'Aucune course terminée sur cette période.';

  @override
  String periodCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses',
      one: '1 course',
      zero: 'aucune course',
    );
    return '$_temp0';
  }

  @override
  String get chartKmByMonth => 'Kilomètres par mois';

  @override
  String get chartKmByYear => 'Kilomètres par année';

  @override
  String get chartKmHint => 'Distance des courses terminées. Touche une barre pour voir ses courses.';

  @override
  String get legendDistance => 'Distance courue (km)';

  @override
  String chartCumulativeTitle(int year) {
    return 'Cumul de l\'année $year';
  }

  @override
  String get chartCumulativeHint =>
      'Kilomètres accumulés depuis le 1er janvier, comparés à l\'année précédente. Chaque marche est une course.';

  @override
  String cumulativeAt(String date) {
    return 'au $date';
  }

  @override
  String get cumulativeYear => 'sur l\'année';

  @override
  String get chartPaceTitle => 'Allure de chaque course officielle';

  @override
  String get legendPace => 'Une course chronométrée';

  @override
  String get viewChart => 'Graphique';

  @override
  String get viewTable => 'Tableau';

  @override
  String get chartPaceHint => 'En minutes par kilomètre. Plus le point est haut, plus tu as couru vite.';

  @override
  String get chartEmpty => 'Pas encore assez de courses terminées pour tracer une évolution.';

  @override
  String get tablePeriod => 'Période';

  @override
  String get tableRaces => 'Courses';

  @override
  String get recordsTitle => 'Records';

  @override
  String get recordsEmpty => 'Termine au moins une course chronométrée pour voir tes records.';

  @override
  String get recordsByDistance => 'Meilleurs temps';

  @override
  String get recordsLongest => 'Plus longues distances';

  @override
  String get recordsElevation => 'Plus gros dénivelés';

  @override
  String get recordsAllTime => 'Tous les temps';

  @override
  String recordsEmptyYear(int year) {
    return 'Aucune course chronométrée en $year.';
  }

  @override
  String get galleryTitle => 'Médailles et dossards';

  @override
  String get galleryAll => 'Tout';

  @override
  String get galleryMedals => 'Médailles';

  @override
  String get galleryBibs => 'Dossards';

  @override
  String get galleryEmpty =>
      'Aucune photo pour l\'instant. Ajoute la médaille ou le dossard dans le formulaire d\'une course.';

  @override
  String galleryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count photos', one: '1 photo');
    return '$_temp0';
  }

  @override
  String get settingsAccount => 'Compte';

  @override
  String settingsSignedInAs(String email) {
    return 'Connecté en tant que $email';
  }

  @override
  String get settingsChangePassword => 'Changer de mot de passe';

  @override
  String get settingsNewPassword => 'Nouveau mot de passe';

  @override
  String get settingsPasswordTooShort => '8 caractères minimum.';

  @override
  String get settingsPasswordChanged => 'Mot de passe modifié.';

  @override
  String get settingsSignOut => 'Se déconnecter';

  @override
  String get settingsSignOutTitle => 'Se déconnecter ?';

  @override
  String settingsSignOutPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count modifications ne sont pas encore envoyées. Elles restent sur cet appareil et partiront à ta prochaine connexion.',
      one: '1 modification n\'est pas encore envoyée. Elle reste sur cet appareil et partira à ta prochaine connexion.',
    );
    return '$_temp0';
  }

  @override
  String get settingsSignOutClean => 'Tes courses restent sur le cloud et sur cet appareil.';

  @override
  String get settingsAppearance => 'Apparence';

  @override
  String get themeSystem => 'Système';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get backupSection => 'Sauvegarde';

  @override
  String get backupHint =>
      'Une copie de toutes tes courses (toutes les colonnes), indépendante du cloud, à garder où tu veux.';

  @override
  String get backupExcel => 'Exporter en Excel';

  @override
  String get backupCsv => 'Exporter en CSV';

  @override
  String backupTitle(String date) {
    return 'Sauvegarde ÉLAN du $date';
  }

  @override
  String get backupSheetName => 'Courses';

  @override
  String get backupDate => 'Date';

  @override
  String get backupCourse => 'Course';

  @override
  String get backupType => 'Type';

  @override
  String get backupStatus => 'Statut';

  @override
  String get backupDistance => 'Distance (km)';

  @override
  String get backupTime => 'Temps';

  @override
  String get backupPace => 'Allure (min/km)';

  @override
  String get backupElevation => 'D+ (m)';

  @override
  String get backupTeam => 'Équipe (membres)';

  @override
  String get backupChallenge => 'Distance du défi (km)';

  @override
  String get backupCharity => 'Solidaire';

  @override
  String get backupAssociation => 'Association';

  @override
  String get backupCause => 'Cause';

  @override
  String get backupSponsor => 'Parrainage (€/km)';

  @override
  String get backupRegistration => 'Don à l\'inscription (€)';

  @override
  String get backupFundraising => 'Collecte (€)';

  @override
  String get backupTotal => 'Total engagé (€)';

  @override
  String get backupMetric => 'Équivalence annoncée';

  @override
  String get backupQuantity => 'Quantité';

  @override
  String get backupDocuments => 'Justificatifs';

  @override
  String get backupNotes => 'Notes';

  @override
  String get backupCreated => 'Ajoutée le';

  @override
  String get backupUpdated => 'Modifiée le';

  @override
  String get backupYes => 'Oui';

  @override
  String get backupNo => 'Non';

  @override
  String get reminderSetting => 'Rappel le soir de la course';

  @override
  String reminderSettingHint(String time) {
    return 'Une notification à $time le jour J pour saisir ton temps.';
  }

  @override
  String get reminderTime => 'Heure du rappel';

  @override
  String reminderTitle(String title) {
    return 'Ta course : $title';
  }

  @override
  String get reminderBody => 'Saisis ton temps pour l\'ajouter à tes totaux et à tes records.';

  @override
  String get settingsWallpaperColors => 'Couleurs du fond d\'écran';

  @override
  String get settingsWallpaperColorsHint =>
      'Material You : l\'app prend les couleurs de ton téléphone. Désactive pour garder les couleurs ÉLAN.';

  @override
  String get syncTitle => 'Synchronisation';

  @override
  String get syncNow => 'Synchroniser maintenant';

  @override
  String get syncUpToDate => 'Tout est synchronisé';

  @override
  String get syncRunning => 'Synchronisation en cours';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count modifications en attente',
      one: '1 modification en attente',
    );
    return '$_temp0';
  }

  @override
  String get syncFailed => 'Synchronisation en échec';

  @override
  String syncLast(String date) {
    return 'Dernière synchronisation : $date';
  }

  @override
  String syncImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses de l\'ancienne version importées.',
      one: '1 course de l\'ancienne version importée.',
    );
    return '$_temp0';
  }

  @override
  String get serverTitle => 'Serveur';

  @override
  String get serverIntro =>
      'ÉLAN enregistre tes courses sur un serveur. Par défaut, c\'est celui d\'ÉLAN ; tu peux aussi utiliser ton propre serveur, par exemple installé sur un NAS.';

  @override
  String get serverIntroCustomOnly =>
      'Indique le serveur où ÉLAN enregistre tes courses, par exemple installé sur un NAS.';

  @override
  String get serverBuiltIn => 'Serveur ÉLAN';

  @override
  String get serverBuiltInHint => 'Par défaut';

  @override
  String get serverCustom => 'Mon serveur';

  @override
  String get serverCustomHint => 'Installé chez toi, par exemple sur un NAS';

  @override
  String get serverAddress => 'Adresse du serveur';

  @override
  String get serverAddressHint => 'http://192.168.1.20:8000';

  @override
  String get serverPaste => 'Coller';

  @override
  String get serverSave => 'Vérifier et enregistrer';

  @override
  String get serverChecking => 'Vérification du serveur…';

  @override
  String get serverErrorAddress => 'Adresse invalide. Exemple : http://192.168.1.20:8000';

  @override
  String get serverErrorHttp =>
      'Sur Internet, l\'adresse doit commencer par https:// (en http, le mot de passe circulerait en clair). http n\'est accepté que sur le réseau local ou le VPN.';

  @override
  String get serverUnreachable =>
      'Serveur injoignable. Vérifie l\'adresse, que le VPN est actif et que le serveur est démarré.';

  @override
  String serverLabel(String name) {
    return 'Serveur : $name';
  }

  @override
  String get autoBackupTitle => 'Sauvegarde automatique';

  @override
  String get autoBackupHint =>
      'Chaque semaine, une copie des courses (Excel) et des photos et justificatifs dans un dossier de ton choix : Proton Drive, disque externe… Les 8 dernières copies Excel sont gardées.';

  @override
  String get autoBackupEnable => 'Sauvegarder chaque semaine';

  @override
  String autoBackupFolder(String path) {
    return 'Dossier : $path';
  }

  @override
  String get autoBackupNoFolder => 'Aucun dossier choisi';

  @override
  String get autoBackupChoose => 'Choisir le dossier';

  @override
  String get autoBackupNow => 'Sauvegarder maintenant';

  @override
  String autoBackupLast(String date) {
    return 'Dernière sauvegarde : $date';
  }

  @override
  String get autoBackupNever => 'Pas encore de sauvegarde';

  @override
  String get autoBackupRunning => 'Sauvegarde en cours…';

  @override
  String autoBackupCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nouveaux fichiers copiés',
      one: '1 nouveau fichier copié',
      zero: 'Aucun nouveau fichier',
    );
    return '$_temp0';
  }

  @override
  String autoBackupMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers introuvables pour l\'instant, réessayés la prochaine fois',
      one: '1 fichier introuvable pour l\'instant, réessayé la prochaine fois',
    );
    return '$_temp0';
  }

  @override
  String autoBackupError(String error) {
    return 'Sauvegarde impossible : $error';
  }

  @override
  String get gpxBatchAction => 'Importer des fichiers GPX';

  @override
  String get gpxBatchTitle => 'Import GPX';

  @override
  String gpxBatchDefaultTitle(String date) {
    return 'Course du $date';
  }

  @override
  String gpxBatchCreated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count courses ajoutées.',
      one: '1 course ajoutée.',
      zero: 'Aucune course ajoutée.',
    );
    return '$_temp0';
  }

  @override
  String gpxBatchDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count traces déjà présentes, ignorées.',
      one: '1 trace déjà présente, ignorée.',
    );
    return '$_temp0';
  }

  @override
  String gpxBatchUndated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count traces sans date, ignorées.',
      one: '1 trace sans date, ignorée.',
    );
    return '$_temp0';
  }

  @override
  String gpxBatchUnreadable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fichiers illisibles.',
      one: '1 fichier illisible.',
    );
    return '$_temp0';
  }

  @override
  String get gpxBatchHint =>
      'Elles sont rangées en courses officielles : ouvre-les pour compléter le titre, l\'association…';

  @override
  String updateAvailable(String version) {
    return 'ÉLAN $version est disponible.';
  }

  @override
  String get updateDownload => 'Télécharger';

  @override
  String get updateLater => 'Plus tard';

  @override
  String get updateUpToDate => 'Tu as la dernière version.';

  @override
  String get updateCheck => 'Rechercher une mise à jour';

  @override
  String get settingsAbout => 'À propos';

  @override
  String settingsVersion(String version) {
    return 'ÉLAN $version';
  }

  @override
  String get signInShowPassword => 'Afficher le mot de passe';

  @override
  String get signInHidePassword => 'Masquer le mot de passe';

  @override
  String get signInForgottenCustom =>
      'Mot de passe oublié ? Le propriétaire du serveur peut t\'en donner un nouveau, dans Réglages > Comptes du serveur.';

  @override
  String get serverAddressHelp =>
      'C\'est l\'adresse affichée sur la page d\'accueil de ton serveur (bouton « Copier l\'adresse »).';

  @override
  String get serverNotElan =>
      'Cette adresse répond, mais ce n\'est pas un serveur ÉLAN. Vérifie le port (8000 par défaut).';

  @override
  String get serverTooRecent => 'Ce serveur est plus récent que l\'app. Mets l\'app à jour, puis réessaie.';

  @override
  String get signInIntroCustom => 'Connecte-toi avec le compte créé pour toi sur ce serveur.';

  @override
  String get firstAccountTitle => 'Premier compte';

  @override
  String get firstAccountIntro =>
      'Ce serveur est tout neuf. Crée le premier compte : il sera le propriétaire du serveur et pourra ajouter les comptes de ses proches.';

  @override
  String get firstAccountButton => 'Créer mon compte';

  @override
  String get firstAccountTaken => 'Ce serveur a déjà un compte. Connecte-toi, ou demande un compte à son propriétaire.';

  @override
  String get passwordConfirmLabel => 'Confirmer le mot de passe';

  @override
  String get passwordMismatch => 'Les deux mots de passe sont différents.';

  @override
  String get settingsCurrentPassword => 'Mot de passe actuel';

  @override
  String get settingsWrongCurrentPassword => 'Mot de passe actuel incorrect.';

  @override
  String get accountsTitle => 'Comptes du serveur';

  @override
  String get accountsIntro => 'Chaque personne a son compte et ne voit que ses propres courses.';

  @override
  String get accountsManage => 'Gérer les comptes';

  @override
  String get accountsOwner => 'Propriétaire du serveur';

  @override
  String get accountsYou => 'Toi';

  @override
  String get accountsAdd => 'Ajouter un compte';

  @override
  String get accountsAddIntro =>
      'Choisis son e-mail et un mot de passe provisoire, puis transmets-les lui. La personne pourra changer son mot de passe dans Réglages.';

  @override
  String get accountsCreated => 'Compte créé.';

  @override
  String get accountsEmailTaken => 'Un compte existe déjà avec cette adresse.';

  @override
  String get accountsReset => 'Donner un nouveau mot de passe';

  @override
  String get accountsResetDone => 'Mot de passe remplacé.';

  @override
  String get accountsDelete => 'Supprimer le compte';

  @override
  String accountsDeleteConfirm(String email) {
    return 'Supprimer le compte $email ? Ses courses, photos et justificatifs enregistrés sur le serveur seront effacés définitivement.';
  }

  @override
  String get accountsDeleted => 'Compte supprimé.';

  @override
  String get accountsError => 'Action impossible. Vérifie la connexion au serveur.';

  @override
  String accountsActions(String email) {
    return 'Actions pour $email';
  }

  @override
  String get typeMultisport => 'Triathlon, duathlon, aquathlon';

  @override
  String get typeShortOfficial => 'Course';

  @override
  String get typeShortConqueror => 'Défi';

  @override
  String get typeShortMultisport => 'Triathlon';

  @override
  String get kindMultisport => 'Triathlons';

  @override
  String get kindMultisportHint => 'Triathlons, duathlons et aquathlons';

  @override
  String get multisportTriathlon => 'Triathlon';

  @override
  String get multisportDuathlon => 'Duathlon';

  @override
  String get multisportAquathlon => 'Aquathlon';

  @override
  String get sportSwim => 'Natation';

  @override
  String get sportBike => 'Vélo';

  @override
  String get sportRun => 'Course à pied';

  @override
  String sportRunNumbered(int number) {
    return 'Course à pied $number';
  }

  @override
  String get multisportFormat => 'Format';

  @override
  String get multisportFormatFree => 'Libre';

  @override
  String get multisportFormatHint => 'Le format préremplit les distances. Corrige-les si ton épreuve était différente.';

  @override
  String get multisportLegDistance => 'Distance';

  @override
  String get multisportLegTime => 'Temps';

  @override
  String multisportTransition(int number) {
    return 'Transition $number';
  }

  @override
  String get multisportTransitionsIncluded => 'Transitions comptées dans les disciplines';

  @override
  String get multisportTransitionsIncludedHint =>
      'À cocher si ton chrono n\'isole pas les transitions : chacune est alors comprise dans le temps de la discipline qui la précède.';

  @override
  String get multisportTotalTime => 'Temps total';

  @override
  String multisportTotalComputed(String time) {
    return 'Laisse vide : calculé d\'après les temps ci-dessus ($time).';
  }

  @override
  String get multisportTotalOnly => 'Tu peux saisir seulement le temps total si tu n\'as pas le détail.';

  @override
  String get multisportTransitionIncludedNote => 'transition comprise';

  @override
  String get multisportTransitions => 'Transitions';

  @override
  String get multisportBreakdown => 'Répartition du temps';

  @override
  String multisportRunShare(String run) {
    return '$run de course à pied comptés dans tes kilomètres courus.';
  }

  @override
  String get multisportEditResult => 'Saisir mes temps';

  @override
  String get issueLegDistance => 'Indique la distance de chaque discipline.';

  @override
  String get issueLegTimes => 'Renseigne le temps de chaque discipline, ou aucun (temps total seul).';

  @override
  String issueTotalBelowSplits(String time) {
    return 'Le temps total est inférieur à la somme des disciplines ($time).';
  }

  @override
  String get recordsMultisport => 'Triathlons, duathlons, aquathlons';

  @override
  String get recordsMultisportBest => 'Meilleur temps';

  @override
  String get swimPaceUnit => '/100 m';

  @override
  String get shareMultisportTotal => 'Temps total';

  @override
  String summaryMultisport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count épreuves enchaînées',
      one: '1 épreuve enchaînée',
      zero: 'Aucune épreuve enchaînée',
    );
    return '$_temp0';
  }

  @override
  String get backupDisciplines => 'Disciplines (triathlon, duathlon, aquathlon)';

  @override
  String get evolutionSportsTitle => 'Triathlons : par discipline';

  @override
  String get evolutionSportsHint => 'Distance et temps cumulés de tes triathlons, duathlons et aquathlons.';

  @override
  String get evolutionSportsEvents => 'Épreuves';

  @override
  String get chartSportTitle => 'Rythme par discipline en triathlon';

  @override
  String get chartSportHintSwim => 'En minutes aux 100 m. Plus le point est haut, plus tu as nagé vite.';

  @override
  String get chartSportHintBike => 'En km/h. Plus le point est haut, plus tu as roulé vite.';

  @override
  String get chartSportHintRun => 'En minutes par kilomètre. Plus le point est haut, plus tu as couru vite.';

  @override
  String get chartSportNeedsTwo => 'Il faut deux épreuves chronométrées sur la période pour tracer cette discipline.';

  @override
  String get legendSport => 'Une épreuve chronométrée';

  @override
  String get recordsBySport => 'Meilleurs rythmes en triathlon';

  @override
  String get recordsBySportHint => 'Par discipline, tous formats confondus (triathlons, duathlons, aquathlons).';

  @override
  String get formTarget => 'Temps visé (facultatif)';

  @override
  String get formTargetHint => 'Ton objectif pour cette course. Il reste affiché après, pour comparer.';

  @override
  String get formRanking => 'Classement';

  @override
  String get formRankingHint => 'Facultatif. Recopie ce que donne la feuille de résultats.';

  @override
  String get formRank => 'Place';

  @override
  String get formFinishers => 'Arrivants';

  @override
  String get formCategoryRank => 'Place dans la catégorie';

  @override
  String get formCategoryFinishers => 'Arrivants de la catégorie';

  @override
  String get formCategoryName => 'Catégorie';

  @override
  String get formCategoryNameHint => 'SEH, M1…';

  @override
  String get issueRankAboveFinishers => 'La place ne peut pas dépasser le nombre d\'arrivants.';

  @override
  String targetPlanned(String time) {
    return 'Objectif $time';
  }

  @override
  String targetBeaten(String time) {
    return 'Objectif battu de $time';
  }

  @override
  String targetMissed(String time) {
    return 'Objectif manqué de $time';
  }

  @override
  String get targetMet => 'Objectif atteint';

  @override
  String get rankingOverall => 'Général';

  @override
  String get rankingCategory => 'Catégorie';

  @override
  String rankingOf(String rank, String total) {
    return '$rank sur $total';
  }

  @override
  String rankingTop(int percent) {
    return 'dans les $percent % premiers';
  }

  @override
  String get ordinalFirst => '1er';

  @override
  String ordinalOther(int n) {
    return '${n}e';
  }

  @override
  String get chartRankTitle => 'Classement de chaque course';

  @override
  String get chartRankHint => 'Part des arrivants classés devant toi. Plus le point est haut, mieux tu es classé.';

  @override
  String get legendRank => 'Une course classée';

  @override
  String goalYearTitle(int year) {
    return 'Objectif $year';
  }

  @override
  String get goalSet => 'Fixer un objectif annuel';

  @override
  String get goalEdit => 'Modifier l\'objectif';

  @override
  String goalDialogField(int year) {
    return 'Kilomètres à courir en $year';
  }

  @override
  String get goalDialogHint => 'Laisse vide pour retirer l\'objectif. Il te suit sur tes autres appareils.';

  @override
  String goalProgress(String done, String goal) {
    return '$done sur $goal';
  }

  @override
  String goalAhead(String km) {
    return 'En avance de $km sur le rythme de l\'année.';
  }

  @override
  String goalBehind(String km) {
    return 'En retard de $km sur le rythme de l\'année.';
  }

  @override
  String get goalOnTrack => 'Pile dans le rythme de l\'année.';

  @override
  String get goalReached => 'Objectif atteint, bravo !';

  @override
  String get backupTarget => 'Temps visé';

  @override
  String get backupRanking => 'Classement';

  @override
  String get recapTitle => 'Bilan de l\'année';

  @override
  String get recapAction => 'Bilan de l\'année à partager';

  @override
  String recapKicker(int year) {
    return 'Bilan $year';
  }

  @override
  String get recapRun => 'courus';

  @override
  String get recapRecords => 'Records';

  @override
  String get recapLongest => 'Plus longue course';

  @override
  String recapDonations(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count associations',
      one: '1 association',
    );
    return '$amount pour $_temp0';
  }

  @override
  String recapDonationsOnly(String amount) {
    return '$amount versés';
  }

  @override
  String recapEmpty(int year) {
    return 'Aucune course terminée en $year.';
  }

  @override
  String recapBanner(int year) {
    return 'Ton bilan $year est prêt';
  }

  @override
  String get recapBannerHint => 'Une image à partager : kilomètres, courses, records et dons.';

  @override
  String get recapBannerOpen => 'Voir';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get formImportFile => 'Importer un fichier de montre (GPX ou FIT)';

  @override
  String formFitImported(String summary) {
    return 'Fichier importé : $summary.';
  }

  @override
  String get formFitError => 'Ce fichier FIT est illisible.';

  @override
  String get formFitUnknown =>
      'Enchaînement non reconnu : seules les disciplines d\'un triathlon, d\'un duathlon ou d\'un aquathlon sont importées. Saisis les temps à la main.';

  @override
  String get editionsTitle => 'Éditions précédentes';

  @override
  String editionsFaster(String time, int year) {
    return '$time de mieux qu\'en $year';
  }

  @override
  String editionsSlower(String time, int year) {
    return '$time de plus qu\'en $year';
  }

  @override
  String editionsSame(int year) {
    return 'Même temps qu\'en $year';
  }

  @override
  String get editionsHint => 'Courses du même nom et de distance voisine.';

  @override
  String get calendarAdd => 'Ajouter à l\'agenda';

  @override
  String get calendarExportAll => 'Courses à venir vers l\'agenda (.ics)';

  @override
  String get calendarSaved => 'Fichier d\'agenda enregistré : ouvre-le pour ajouter les courses.';

  @override
  String calendarTarget(String time) {
    return 'Temps visé : $time';
  }

  @override
  String get resultRanking => 'Classement (facultatif)';
}
