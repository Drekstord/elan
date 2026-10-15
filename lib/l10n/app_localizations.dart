import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('fr')];

  /// No description provided for @appTitle.
  ///
  /// In fr, this message translates to:
  /// **'ÉLAN'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In fr, this message translates to:
  /// **'Sport & Impact'**
  String get appTagline;

  /// No description provided for @signInTitle.
  ///
  /// In fr, this message translates to:
  /// **'Connexion'**
  String get signInTitle;

  /// No description provided for @signInIntro.
  ///
  /// In fr, this message translates to:
  /// **'Connecte-toi avec le compte créé pour toi sur ÉLAN.'**
  String get signInIntro;

  /// No description provided for @emailLabel.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe'**
  String get passwordLabel;

  /// No description provided for @signInButton.
  ///
  /// In fr, this message translates to:
  /// **'Se connecter'**
  String get signInButton;

  /// No description provided for @signInInvalidEmail.
  ///
  /// In fr, this message translates to:
  /// **'Adresse e-mail invalide.'**
  String get signInInvalidEmail;

  /// No description provided for @signInMissingPassword.
  ///
  /// In fr, this message translates to:
  /// **'Saisis ton mot de passe.'**
  String get signInMissingPassword;

  /// No description provided for @signInWrongCredentials.
  ///
  /// In fr, this message translates to:
  /// **'E-mail ou mot de passe incorrect.'**
  String get signInWrongCredentials;

  /// No description provided for @signInRateLimited.
  ///
  /// In fr, this message translates to:
  /// **'Trop de tentatives. Patiente une minute avant de réessayer.'**
  String get signInRateLimited;

  /// No description provided for @signInOffline.
  ///
  /// In fr, this message translates to:
  /// **'Impossible de joindre le serveur. Vérifie ta connexion.'**
  String get signInOffline;

  /// No description provided for @signInForgotten.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ? Demande à l\'administrateur d\'ÉLAN de le réinitialiser.'**
  String get signInForgotten;

  /// No description provided for @navCourses.
  ///
  /// In fr, this message translates to:
  /// **'Courses'**
  String get navCourses;

  /// No description provided for @navImpact.
  ///
  /// In fr, this message translates to:
  /// **'Impact'**
  String get navImpact;

  /// No description provided for @navEvolution.
  ///
  /// In fr, this message translates to:
  /// **'Évolution'**
  String get navEvolution;

  /// No description provided for @navRecords.
  ///
  /// In fr, this message translates to:
  /// **'Records'**
  String get navRecords;

  /// No description provided for @navSettings.
  ///
  /// In fr, this message translates to:
  /// **'Réglages'**
  String get navSettings;

  /// No description provided for @cancel.
  ///
  /// In fr, this message translates to:
  /// **'Annuler'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In fr, this message translates to:
  /// **'Fermer'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In fr, this message translates to:
  /// **'Réessayer'**
  String get retry;

  /// No description provided for @typeOfficial.
  ///
  /// In fr, this message translates to:
  /// **'Course officielle'**
  String get typeOfficial;

  /// No description provided for @typeConqueror.
  ///
  /// In fr, this message translates to:
  /// **'Défi The Conqueror'**
  String get typeConqueror;

  /// No description provided for @statusUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get statusUpcoming;

  /// No description provided for @statusAwaiting.
  ///
  /// In fr, this message translates to:
  /// **'Résultat à saisir'**
  String get statusAwaiting;

  /// No description provided for @statusAwaitingShort.
  ///
  /// In fr, this message translates to:
  /// **'À saisir'**
  String get statusAwaitingShort;

  /// No description provided for @statusCompleted.
  ///
  /// In fr, this message translates to:
  /// **'Terminée'**
  String get statusCompleted;

  /// No description provided for @causeSante.
  ///
  /// In fr, this message translates to:
  /// **'Santé & recherche'**
  String get causeSante;

  /// No description provided for @causeEnvironnement.
  ///
  /// In fr, this message translates to:
  /// **'Environnement & climat'**
  String get causeEnvironnement;

  /// No description provided for @causePrecarite.
  ///
  /// In fr, this message translates to:
  /// **'Précarité & faim'**
  String get causePrecarite;

  /// No description provided for @causeEnfance.
  ///
  /// In fr, this message translates to:
  /// **'Enfance & éducation'**
  String get causeEnfance;

  /// No description provided for @causeAnimaux.
  ///
  /// In fr, this message translates to:
  /// **'Protection animale'**
  String get causeAnimaux;

  /// No description provided for @causeHandicap.
  ///
  /// In fr, this message translates to:
  /// **'Handicap & inclusion'**
  String get causeHandicap;

  /// No description provided for @causeAutre.
  ///
  /// In fr, this message translates to:
  /// **'Autre cause'**
  String get causeAutre;

  /// No description provided for @metricTrees.
  ///
  /// In fr, this message translates to:
  /// **'Arbres plantés'**
  String get metricTrees;

  /// No description provided for @metricOceanBottles.
  ///
  /// In fr, this message translates to:
  /// **'Bouteilles plastiques retirées'**
  String get metricOceanBottles;

  /// No description provided for @metricCareSessions.
  ///
  /// In fr, this message translates to:
  /// **'Séances de soins'**
  String get metricCareSessions;

  /// No description provided for @metricResearchHours.
  ///
  /// In fr, this message translates to:
  /// **'Heures de recherche'**
  String get metricResearchHours;

  /// No description provided for @metricMeals.
  ///
  /// In fr, this message translates to:
  /// **'Repas distribués'**
  String get metricMeals;

  /// No description provided for @metricCareKits.
  ///
  /// In fr, this message translates to:
  /// **'Kits de soins'**
  String get metricCareKits;

  /// No description provided for @metricAnimalMeals.
  ///
  /// In fr, this message translates to:
  /// **'Repas pour animaux'**
  String get metricAnimalMeals;

  /// No description provided for @metricNone.
  ///
  /// In fr, this message translates to:
  /// **'Aucune équivalence'**
  String get metricNone;

  /// No description provided for @distance5k.
  ///
  /// In fr, this message translates to:
  /// **'5 km'**
  String get distance5k;

  /// No description provided for @distance10k.
  ///
  /// In fr, this message translates to:
  /// **'10 km'**
  String get distance10k;

  /// No description provided for @distanceHalf.
  ///
  /// In fr, this message translates to:
  /// **'Semi-marathon'**
  String get distanceHalf;

  /// No description provided for @distanceMarathon.
  ///
  /// In fr, this message translates to:
  /// **'Marathon'**
  String get distanceMarathon;

  /// No description provided for @statDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance'**
  String get statDistance;

  /// No description provided for @statDonations.
  ///
  /// In fr, this message translates to:
  /// **'Fonds engagés'**
  String get statDonations;

  /// No description provided for @statRaces.
  ///
  /// In fr, this message translates to:
  /// **'Courses'**
  String get statRaces;

  /// No description provided for @statTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps de course'**
  String get statTime;

  /// No description provided for @statElevation.
  ///
  /// In fr, this message translates to:
  /// **'Dénivelé +'**
  String get statElevation;

  /// No description provided for @statPace.
  ///
  /// In fr, this message translates to:
  /// **'Allure moyenne'**
  String get statPace;

  /// No description provided for @coursesEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune course pour l\'instant. Ajoute ta première course ou inscris une course à venir.'**
  String get coursesEmpty;

  /// No description provided for @coursesNoMatch.
  ///
  /// In fr, this message translates to:
  /// **'Aucune course ne correspond.'**
  String get coursesNoMatch;

  /// No description provided for @coursesAdd.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle course'**
  String get coursesAdd;

  /// No description provided for @coursesSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une course, une association…'**
  String get coursesSearch;

  /// No description provided for @filterAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get filterAll;

  /// No description provided for @filterCharity.
  ///
  /// In fr, this message translates to:
  /// **'Solidaires'**
  String get filterCharity;

  /// No description provided for @kindAll.
  ///
  /// In fr, this message translates to:
  /// **'Toutes'**
  String get kindAll;

  /// No description provided for @kindOfficial.
  ///
  /// In fr, this message translates to:
  /// **'Officielles'**
  String get kindOfficial;

  /// No description provided for @kindChallenge.
  ///
  /// In fr, this message translates to:
  /// **'Défis'**
  String get kindChallenge;

  /// No description provided for @filterReset.
  ///
  /// In fr, this message translates to:
  /// **'Effacer les filtres'**
  String get filterReset;

  /// No description provided for @filterSolidarity.
  ///
  /// In fr, this message translates to:
  /// **'Volet solidaire'**
  String get filterSolidarity;

  /// No description provided for @filterSolidarityAll.
  ///
  /// In fr, this message translates to:
  /// **'Solidaires ou non'**
  String get filterSolidarityAll;

  /// No description provided for @filterSolidarityOnly.
  ///
  /// In fr, this message translates to:
  /// **'Solidaires uniquement'**
  String get filterSolidarityOnly;

  /// No description provided for @summaryCourses.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune course} =1{1 course} other{{count} courses}}'**
  String summaryCourses(int count);

  /// No description provided for @summaryOfficial.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune course officielle} =1{1 course officielle} other{{count} courses officielles}}'**
  String summaryOfficial(int count);

  /// No description provided for @summaryChallenges.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun défi} =1{1 défi} other{{count} défis}}'**
  String summaryChallenges(int count);

  /// No description provided for @summarySolidarity.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{solidaire} other{solidaires}}'**
  String summarySolidarity(int count);

  /// No description provided for @sectionAwaiting.
  ///
  /// In fr, this message translates to:
  /// **'Résultat à saisir'**
  String get sectionAwaiting;

  /// No description provided for @sectionUpcoming.
  ///
  /// In fr, this message translates to:
  /// **'À venir'**
  String get sectionUpcoming;

  /// No description provided for @sectionDone.
  ///
  /// In fr, this message translates to:
  /// **'Terminées'**
  String get sectionDone;

  /// No description provided for @sectionSummary.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 course} other{{count} courses}} · {distance}'**
  String sectionSummary(int count, String distance);

  /// No description provided for @filterCause.
  ///
  /// In fr, this message translates to:
  /// **'Cause'**
  String get filterCause;

  /// No description provided for @sortRaceDate.
  ///
  /// In fr, this message translates to:
  /// **'Date de course'**
  String get sortRaceDate;

  /// No description provided for @sortAddedDate.
  ///
  /// In fr, this message translates to:
  /// **'Date d\'ajout'**
  String get sortAddedDate;

  /// No description provided for @sortTooltip.
  ///
  /// In fr, this message translates to:
  /// **'Trier'**
  String get sortTooltip;

  /// No description provided for @sortAscending.
  ///
  /// In fr, this message translates to:
  /// **'Plus anciennes d\'abord'**
  String get sortAscending;

  /// No description provided for @sortDescending.
  ///
  /// In fr, this message translates to:
  /// **'Plus récentes d\'abord'**
  String get sortDescending;

  /// No description provided for @awaitingBanner.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 course attend ton résultat} other{{count} courses attendent ton résultat}}'**
  String awaitingBanner(int count);

  /// No description provided for @recordBadge.
  ///
  /// In fr, this message translates to:
  /// **'Record'**
  String get recordBadge;

  /// No description provided for @nextRace.
  ///
  /// In fr, this message translates to:
  /// **'Prochaine course'**
  String get nextRace;

  /// No description provided for @last12Months.
  ///
  /// In fr, this message translates to:
  /// **'Kilomètres sur les 12 derniers mois'**
  String get last12Months;

  /// No description provided for @formNewTitle.
  ///
  /// In fr, this message translates to:
  /// **'Nouvelle course'**
  String get formNewTitle;

  /// No description provided for @formEditTitle.
  ///
  /// In fr, this message translates to:
  /// **'Modifier la course'**
  String get formEditTitle;

  /// No description provided for @formPlanned.
  ///
  /// In fr, this message translates to:
  /// **'Course à venir'**
  String get formPlanned;

  /// No description provided for @formPlannedHint.
  ///
  /// In fr, this message translates to:
  /// **'Inscris-la maintenant, tu saisiras ton temps après la course.'**
  String get formPlannedHint;

  /// No description provided for @formName.
  ///
  /// In fr, this message translates to:
  /// **'Nom de la course'**
  String get formName;

  /// No description provided for @formDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get formDate;

  /// No description provided for @formDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance (km)'**
  String get formDistance;

  /// No description provided for @formDuration.
  ///
  /// In fr, this message translates to:
  /// **'Temps (h:mm:ss)'**
  String get formDuration;

  /// No description provided for @formElevation.
  ///
  /// In fr, this message translates to:
  /// **'Dénivelé positif (m)'**
  String get formElevation;

  /// No description provided for @formImportGpx.
  ///
  /// In fr, this message translates to:
  /// **'Importer un fichier GPX'**
  String get formImportGpx;

  /// No description provided for @formGpxImported.
  ///
  /// In fr, this message translates to:
  /// **'Trace importée : {distance}, {duration}.'**
  String formGpxImported(String distance, String duration);

  /// No description provided for @formGpxError.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier GPX est illisible.'**
  String get formGpxError;

  /// No description provided for @formTeam.
  ///
  /// In fr, this message translates to:
  /// **'Défi en équipe'**
  String get formTeam;

  /// No description provided for @formChallengeDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance totale du défi (km)'**
  String get formChallengeDistance;

  /// No description provided for @formTeamSize.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de membres'**
  String get formTeamSize;

  /// No description provided for @formPersonalShare.
  ///
  /// In fr, this message translates to:
  /// **'Ta part : {distance}'**
  String formPersonalShare(String distance);

  /// No description provided for @formCharity.
  ///
  /// In fr, this message translates to:
  /// **'Course solidaire'**
  String get formCharity;

  /// No description provided for @formCharityHint.
  ///
  /// In fr, this message translates to:
  /// **'Liée à une association et à des dons.'**
  String get formCharityHint;

  /// No description provided for @formAssociation.
  ///
  /// In fr, this message translates to:
  /// **'Association'**
  String get formAssociation;

  /// No description provided for @formChooseAssociation.
  ///
  /// In fr, this message translates to:
  /// **'Choisir une association'**
  String get formChooseAssociation;

  /// No description provided for @formSponsor.
  ///
  /// In fr, this message translates to:
  /// **'Parrainage (€ par km)'**
  String get formSponsor;

  /// No description provided for @formRegistration.
  ///
  /// In fr, this message translates to:
  /// **'Don sur l\'inscription (€)'**
  String get formRegistration;

  /// No description provided for @formFundraising.
  ///
  /// In fr, this message translates to:
  /// **'Collecte / cagnotte (€)'**
  String get formFundraising;

  /// No description provided for @formDonationTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total engagé : {amount}'**
  String formDonationTotal(String amount);

  /// No description provided for @formImpact.
  ///
  /// In fr, this message translates to:
  /// **'Équivalence annoncée par l\'organisateur'**
  String get formImpact;

  /// No description provided for @formImpactHint.
  ///
  /// In fr, this message translates to:
  /// **'Facultatif. Uniquement si l\'organisateur l\'annonce (ex. 5 arbres plantés).'**
  String get formImpactHint;

  /// No description provided for @formImpactUnit.
  ///
  /// In fr, this message translates to:
  /// **'Unité'**
  String get formImpactUnit;

  /// No description provided for @formImpactQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get formImpactQuantity;

  /// No description provided for @formPhotos.
  ///
  /// In fr, this message translates to:
  /// **'Souvenirs'**
  String get formPhotos;

  /// No description provided for @formMedal.
  ///
  /// In fr, this message translates to:
  /// **'Médaille'**
  String get formMedal;

  /// No description provided for @formBib.
  ///
  /// In fr, this message translates to:
  /// **'Dossard'**
  String get formBib;

  /// No description provided for @formAddPhoto.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter une photo'**
  String get formAddPhoto;

  /// No description provided for @formNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get formNotes;

  /// No description provided for @issueMissingTitle.
  ///
  /// In fr, this message translates to:
  /// **'Donne un nom à la course.'**
  String get issueMissingTitle;

  /// No description provided for @issueDistance.
  ///
  /// In fr, this message translates to:
  /// **'La distance doit être supérieure à 0.'**
  String get issueDistance;

  /// No description provided for @issueNegative.
  ///
  /// In fr, this message translates to:
  /// **'Une valeur négative est impossible.'**
  String get issueNegative;

  /// No description provided for @issueCompletedInFuture.
  ///
  /// In fr, this message translates to:
  /// **'Cette date est dans le futur : coche « Course à venir ».'**
  String get issueCompletedInFuture;

  /// No description provided for @issuePlannedWithResult.
  ///
  /// In fr, this message translates to:
  /// **'Une course à venir n\'a pas encore de temps.'**
  String get issuePlannedWithResult;

  /// No description provided for @issueTeamSize.
  ///
  /// In fr, this message translates to:
  /// **'Nombre de membres invalide.'**
  String get issueTeamSize;

  /// No description provided for @issueImpactQuantity.
  ///
  /// In fr, this message translates to:
  /// **'La quantité doit être positive.'**
  String get issueImpactQuantity;

  /// No description provided for @issueImpactCap.
  ///
  /// In fr, this message translates to:
  /// **'Au-delà du plafond annoncé ({max} maximum).'**
  String issueImpactCap(String max);

  /// No description provided for @issueInvalidNumber.
  ///
  /// In fr, this message translates to:
  /// **'Nombre invalide.'**
  String get issueInvalidNumber;

  /// No description provided for @issueInvalidDuration.
  ///
  /// In fr, this message translates to:
  /// **'Format attendu : h:mm:ss'**
  String get issueInvalidDuration;

  /// No description provided for @assoSearchHint.
  ///
  /// In fr, this message translates to:
  /// **'Nom de l\'association'**
  String get assoSearchHint;

  /// No description provided for @assoCatalog.
  ///
  /// In fr, this message translates to:
  /// **'Associations courantes'**
  String get assoCatalog;

  /// No description provided for @assoOfficial.
  ///
  /// In fr, this message translates to:
  /// **'Répertoire officiel'**
  String get assoOfficial;

  /// No description provided for @assoSearching.
  ///
  /// In fr, this message translates to:
  /// **'Recherche dans le répertoire officiel…'**
  String get assoSearching;

  /// No description provided for @assoSearchOffline.
  ///
  /// In fr, this message translates to:
  /// **'Recherche en ligne indisponible. Choisis dans la liste ou saisis le nom.'**
  String get assoSearchOffline;

  /// No description provided for @assoFree.
  ///
  /// In fr, this message translates to:
  /// **'Utiliser « {name} »'**
  String assoFree(String name);

  /// No description provided for @assoCause.
  ///
  /// In fr, this message translates to:
  /// **'Cause soutenue'**
  String get assoCause;

  /// No description provided for @assoNoResult.
  ///
  /// In fr, this message translates to:
  /// **'Aucun résultat.'**
  String get assoNoResult;

  /// No description provided for @detailNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Cette course n\'existe plus.'**
  String get detailNotFound;

  /// No description provided for @detailPerformance.
  ///
  /// In fr, this message translates to:
  /// **'Performance'**
  String get detailPerformance;

  /// No description provided for @detailTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps'**
  String get detailTime;

  /// No description provided for @detailPace.
  ///
  /// In fr, this message translates to:
  /// **'Allure'**
  String get detailPace;

  /// No description provided for @detailSpeed.
  ///
  /// In fr, this message translates to:
  /// **'Vitesse'**
  String get detailSpeed;

  /// No description provided for @detailUpcomingInfo.
  ///
  /// In fr, this message translates to:
  /// **'Course prévue. Tu pourras saisir ton résultat à partir du jour J.'**
  String get detailUpcomingInfo;

  /// No description provided for @detailAwaitingInfo.
  ///
  /// In fr, this message translates to:
  /// **'La course a eu lieu : saisis ton temps pour l\'ajouter à tes totaux et records.'**
  String get detailAwaitingInfo;

  /// No description provided for @detailEnterResult.
  ///
  /// In fr, this message translates to:
  /// **'Saisir mon résultat'**
  String get detailEnterResult;

  /// No description provided for @detailTeam.
  ///
  /// In fr, this message translates to:
  /// **'En équipe de {count} · défi de {distance}'**
  String detailTeam(int count, String distance);

  /// No description provided for @detailSolidarity.
  ///
  /// In fr, this message translates to:
  /// **'Volet solidaire'**
  String get detailSolidarity;

  /// No description provided for @detailSponsor.
  ///
  /// In fr, this message translates to:
  /// **'Parrainage'**
  String get detailSponsor;

  /// No description provided for @detailRegistration.
  ///
  /// In fr, this message translates to:
  /// **'Inscription'**
  String get detailRegistration;

  /// No description provided for @detailFundraising.
  ///
  /// In fr, this message translates to:
  /// **'Collecte'**
  String get detailFundraising;

  /// No description provided for @detailDonationTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total engagé'**
  String get detailDonationTotal;

  /// No description provided for @detailDeclaredImpact.
  ///
  /// In fr, this message translates to:
  /// **'Impact annoncé'**
  String get detailDeclaredImpact;

  /// No description provided for @deleteCourseTitle.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer cette course ?'**
  String get deleteCourseTitle;

  /// No description provided for @deleteCourseBody.
  ///
  /// In fr, this message translates to:
  /// **'Elle sera supprimée sur tous tes appareils.'**
  String get deleteCourseBody;

  /// No description provided for @resultTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon résultat'**
  String get resultTitle;

  /// No description provided for @shareTitle.
  ///
  /// In fr, this message translates to:
  /// **'Partager la course'**
  String get shareTitle;

  /// No description provided for @shareSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer l\'image'**
  String get shareSave;

  /// No description provided for @shareShare.
  ///
  /// In fr, this message translates to:
  /// **'Partager'**
  String get shareShare;

  /// No description provided for @shareSaved.
  ///
  /// In fr, this message translates to:
  /// **'Image enregistrée.'**
  String get shareSaved;

  /// No description provided for @shareFor.
  ///
  /// In fr, this message translates to:
  /// **'pour {association}'**
  String shareFor(String association);

  /// No description provided for @impactTitle.
  ///
  /// In fr, this message translates to:
  /// **'Mon impact'**
  String get impactTitle;

  /// No description provided for @impactHonesty.
  ///
  /// In fr, this message translates to:
  /// **'Seuls l\'argent réellement engagé et les équivalences annoncées par les organisateurs sont comptés.'**
  String get impactHonesty;

  /// No description provided for @impactCharityRaces.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune course solidaire} =1{1 course solidaire} other{{count} courses solidaires}}'**
  String impactCharityRaces(int count);

  /// No description provided for @impactCharityDistance.
  ///
  /// In fr, this message translates to:
  /// **'{distance} courus pour une cause'**
  String impactCharityDistance(String distance);

  /// No description provided for @impactDeclared.
  ///
  /// In fr, this message translates to:
  /// **'Impact annoncé'**
  String get impactDeclared;

  /// No description provided for @impactKmFor.
  ///
  /// In fr, this message translates to:
  /// **'Courus pour {cause}'**
  String impactKmFor(String cause);

  /// No description provided for @reportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bilan d\'engagement'**
  String get reportTitle;

  /// No description provided for @reportAction.
  ///
  /// In fr, this message translates to:
  /// **'Faire un bilan pour un rapport'**
  String get reportAction;

  /// No description provided for @reportPresetSchool.
  ///
  /// In fr, this message translates to:
  /// **'Année scolaire'**
  String get reportPresetSchool;

  /// No description provided for @reportPresetYear.
  ///
  /// In fr, this message translates to:
  /// **'Année {year}'**
  String reportPresetYear(int year);

  /// No description provided for @reportPresetLast12.
  ///
  /// In fr, this message translates to:
  /// **'12 derniers mois'**
  String get reportPresetLast12;

  /// No description provided for @reportPresetCustom.
  ///
  /// In fr, this message translates to:
  /// **'Dates choisies'**
  String get reportPresetCustom;

  /// No description provided for @reportFrom.
  ///
  /// In fr, this message translates to:
  /// **'Du {date}'**
  String reportFrom(String date);

  /// No description provided for @reportTo.
  ///
  /// In fr, this message translates to:
  /// **'Au {date}'**
  String reportTo(String date);

  /// No description provided for @reportCharityOnly.
  ///
  /// In fr, this message translates to:
  /// **'Seulement les courses solidaires'**
  String get reportCharityOnly;

  /// No description provided for @reportTextTitle.
  ///
  /// In fr, this message translates to:
  /// **'Texte pour ton rapport'**
  String get reportTextTitle;

  /// No description provided for @reportCopyText.
  ///
  /// In fr, this message translates to:
  /// **'Copier le texte'**
  String get reportCopyText;

  /// No description provided for @reportCopyTable.
  ///
  /// In fr, this message translates to:
  /// **'Copier le tableau'**
  String get reportCopyTable;

  /// No description provided for @reportCopied.
  ///
  /// In fr, this message translates to:
  /// **'Texte copié : colle-le dans ton rapport.'**
  String get reportCopied;

  /// No description provided for @reportTableCopied.
  ///
  /// In fr, this message translates to:
  /// **'Tableau copié : colle-le dans Word ou Excel.'**
  String get reportTableCopied;

  /// No description provided for @reportImageTitle.
  ///
  /// In fr, this message translates to:
  /// **'Image du bilan'**
  String get reportImageTitle;

  /// No description provided for @reportEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune course terminée sur cette période.'**
  String get reportEmpty;

  /// No description provided for @reportHeading.
  ///
  /// In fr, this message translates to:
  /// **'Bilan ÉLAN du {from} au {to}'**
  String reportHeading(String from, String to);

  /// No description provided for @reportSectionSolidarity.
  ///
  /// In fr, this message translates to:
  /// **'ENGAGEMENT SOLIDAIRE'**
  String get reportSectionSolidarity;

  /// No description provided for @reportCharityLine.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 course solidaire, soit {distance} courus pour une cause.} other{{count} courses solidaires, soit {distance} courus pour des causes.}}'**
  String reportCharityLine(int count, String distance);

  /// No description provided for @reportDonationLine.
  ///
  /// In fr, this message translates to:
  /// **'{amount} engagés (dons, parrainages et collectes).'**
  String reportDonationLine(String amount);

  /// No description provided for @reportDeclaredLine.
  ///
  /// In fr, this message translates to:
  /// **'Impact annoncé par les organisateurs : {list}.'**
  String reportDeclaredLine(String list);

  /// No description provided for @reportCausesLine.
  ///
  /// In fr, this message translates to:
  /// **'Causes soutenues : {list}.'**
  String reportCausesLine(String list);

  /// No description provided for @reportAssociationsLine.
  ///
  /// In fr, this message translates to:
  /// **'Associations soutenues : {list}.'**
  String reportAssociationsLine(String list);

  /// No description provided for @reportNoCharity.
  ///
  /// In fr, this message translates to:
  /// **'Aucune course solidaire sur la période.'**
  String get reportNoCharity;

  /// No description provided for @reportSectionCourses.
  ///
  /// In fr, this message translates to:
  /// **'DÉTAIL DES COURSES'**
  String get reportSectionCourses;

  /// No description provided for @reportSectionSport.
  ///
  /// In fr, this message translates to:
  /// **'ACTIVITÉ SPORTIVE'**
  String get reportSectionSport;

  /// No description provided for @reportSportLine.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 course terminée} other{{count} courses terminées}}, {distance} au total.'**
  String reportSportLine(int count, String distance);

  /// No description provided for @reportTimeLine.
  ///
  /// In fr, this message translates to:
  /// **'Temps de course : {time}.'**
  String reportTimeLine(String time);

  /// No description provided for @reportElevationLine.
  ///
  /// In fr, this message translates to:
  /// **'Dénivelé positif : {elevation}.'**
  String reportElevationLine(String elevation);

  /// No description provided for @reportPeriod.
  ///
  /// In fr, this message translates to:
  /// **'Du {from} au {to}'**
  String reportPeriod(String from, String to);

  /// No description provided for @reportAnd.
  ///
  /// In fr, this message translates to:
  /// **'et'**
  String get reportAnd;

  /// No description provided for @reportStyleProse.
  ///
  /// In fr, this message translates to:
  /// **'Rédigé'**
  String get reportStyleProse;

  /// No description provided for @reportStyleBullets.
  ///
  /// In fr, this message translates to:
  /// **'Points clés'**
  String get reportStyleBullets;

  /// No description provided for @reportExcel.
  ///
  /// In fr, this message translates to:
  /// **'Fichier Excel'**
  String get reportExcel;

  /// No description provided for @reportTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total'**
  String get reportTotal;

  /// No description provided for @reportSheetName.
  ///
  /// In fr, this message translates to:
  /// **'Bilan'**
  String get reportSheetName;

  /// No description provided for @reportSheetSubtitle.
  ///
  /// In fr, this message translates to:
  /// **'Généré par ÉLAN · {count, plural, =1{1 course} other{{count} courses}}'**
  String reportSheetSubtitle(int count);

  /// No description provided for @fileSaved.
  ///
  /// In fr, this message translates to:
  /// **'Fichier enregistré.'**
  String get fileSaved;

  /// No description provided for @datePickerToday.
  ///
  /// In fr, this message translates to:
  /// **'Aujourd\'hui'**
  String get datePickerToday;

  /// No description provided for @reportProseIntro.
  ///
  /// In fr, this message translates to:
  /// **'Du {from} au {to}, j\'ai participé à {count, plural, =1{une course} other{{count} courses}}, pour un total de {distance} parcourus.'**
  String reportProseIntro(int count, String from, String to, String distance);

  /// No description provided for @reportProseNoCharity.
  ///
  /// In fr, this message translates to:
  /// **'Aucune de ces courses n\'était solidaire.'**
  String get reportProseNoCharity;

  /// No description provided for @reportProseAllCharity.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Elle était solidaire} other{Toutes étaient solidaires}}, soit {distance} courus au profit de causes.'**
  String reportProseAllCharity(int count, String distance);

  /// No description provided for @reportProseCharity.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{L\'une d\'elles était solidaire} other{{count} d\'entre elles étaient solidaires}}, soit {distance} courus au profit de causes.'**
  String reportProseCharity(int count, String distance);

  /// No description provided for @reportProseChallenges.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Ce total comprend un défi au long cours (The Conqueror), qui représente {distance} à lui seul.} other{Ce total comprend {count} défis au long cours (The Conqueror), qui représentent {distance} à eux seuls.}}'**
  String reportProseChallenges(int count, String distance);

  /// No description provided for @reportProseDonations.
  ///
  /// In fr, this message translates to:
  /// **'Ces courses ont permis d\'engager {amount} en faveur d\'associations (dons, parrainages et collectes).'**
  String reportProseDonations(String amount);

  /// No description provided for @reportProseDonationsCauses.
  ///
  /// In fr, this message translates to:
  /// **'Ces courses ont permis d\'engager {amount} en faveur d\'associations (dons, parrainages et collectes), notamment pour {causes}.'**
  String reportProseDonationsCauses(String amount, String causes);

  /// No description provided for @reportProseDeclared.
  ///
  /// In fr, this message translates to:
  /// **'Les organisateurs annoncent par ailleurs un impact concret : {list}.'**
  String reportProseDeclared(String list);

  /// No description provided for @reportProseAssociations.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{L\'association soutenue est {list}.} other{Les associations soutenues sont {list}.}}'**
  String reportProseAssociations(int count, String list);

  /// No description provided for @reportProseRaces.
  ///
  /// In fr, this message translates to:
  /// **'Courses solidaires : {list}.'**
  String reportProseRaces(String list);

  /// No description provided for @reportProseSport.
  ///
  /// In fr, this message translates to:
  /// **'Sur le plan sportif, cela représente {parts}.'**
  String reportProseSport(String parts);

  /// No description provided for @reportProseTime.
  ///
  /// In fr, this message translates to:
  /// **'{time} de course'**
  String reportProseTime(String time);

  /// No description provided for @reportProseElevation.
  ///
  /// In fr, this message translates to:
  /// **'{elevation} de dénivelé positif'**
  String reportProseElevation(String elevation);

  /// No description provided for @reportProsePace.
  ///
  /// In fr, this message translates to:
  /// **'une allure moyenne de {pace}'**
  String reportProsePace(String pace);

  /// No description provided for @reportPaceLine.
  ///
  /// In fr, this message translates to:
  /// **'Allure moyenne : {pace}.'**
  String reportPaceLine(String pace);

  /// No description provided for @reportChallengeTag.
  ///
  /// In fr, this message translates to:
  /// **'défi'**
  String get reportChallengeTag;

  /// No description provided for @reportDistanceTime.
  ///
  /// In fr, this message translates to:
  /// **'{distance} en {time}'**
  String reportDistanceTime(String distance, String time);

  /// No description provided for @reportTableHeader.
  ///
  /// In fr, this message translates to:
  /// **'Date\tCourse\tType\tDistance (km)\tTemps\tAllure (min/km)\tD+ (m)\tAssociation\tCause\tFonds engagés (€)\tImpact annoncé'**
  String get reportTableHeader;

  /// No description provided for @reportWordHeader.
  ///
  /// In fr, this message translates to:
  /// **'Date\tCourse\tDistance et temps\tAssociation et cause\tFonds engagés\tImpact annoncé'**
  String get reportWordHeader;

  /// No description provided for @reportCopyForWord.
  ///
  /// In fr, this message translates to:
  /// **'Pour Word (tableau compact)'**
  String get reportCopyForWord;

  /// No description provided for @reportCopyForExcel.
  ///
  /// In fr, this message translates to:
  /// **'Pour Excel (toutes les colonnes)'**
  String get reportCopyForExcel;

  /// No description provided for @reportCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bilan d\'engagement'**
  String get reportCardTitle;

  /// No description provided for @reportCardFor.
  ///
  /// In fr, this message translates to:
  /// **'Pour {list}'**
  String reportCardFor(String list);

  /// No description provided for @impactCharityDistanceLabel.
  ///
  /// In fr, this message translates to:
  /// **'Distance solidaire'**
  String get impactCharityDistanceLabel;

  /// No description provided for @impactByCause.
  ///
  /// In fr, this message translates to:
  /// **'Par cause'**
  String get impactByCause;

  /// No description provided for @impactAssociations.
  ///
  /// In fr, this message translates to:
  /// **'Associations soutenues'**
  String get impactAssociations;

  /// No description provided for @impactByYear.
  ///
  /// In fr, this message translates to:
  /// **'Fonds engagés par année'**
  String get impactByYear;

  /// No description provided for @impactByYearHint.
  ///
  /// In fr, this message translates to:
  /// **'Dons, parrainages et collectes des courses solidaires terminées.'**
  String get impactByYearHint;

  /// No description provided for @legendDonations.
  ///
  /// In fr, this message translates to:
  /// **'Fonds engagés (€)'**
  String get legendDonations;

  /// No description provided for @impactEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune course solidaire terminée pour l\'instant.'**
  String get impactEmpty;

  /// No description provided for @docTitle.
  ///
  /// In fr, this message translates to:
  /// **'Justificatifs'**
  String get docTitle;

  /// No description provided for @docAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un justificatif'**
  String get docAdd;

  /// No description provided for @docAdded.
  ///
  /// In fr, this message translates to:
  /// **'Justificatif ajouté à « {course} ».'**
  String docAdded(String course);

  /// No description provided for @docTooBig.
  ///
  /// In fr, this message translates to:
  /// **'Fichier trop lourd : 10 Mo maximum.'**
  String get docTooBig;

  /// No description provided for @docUnavailable.
  ///
  /// In fr, this message translates to:
  /// **'Justificatif indisponible pour le moment : vérifie ta connexion.'**
  String get docUnavailable;

  /// No description provided for @docRemoveTitle.
  ///
  /// In fr, this message translates to:
  /// **'Retirer ce justificatif ?'**
  String get docRemoveTitle;

  /// No description provided for @docRemoveBody.
  ///
  /// In fr, this message translates to:
  /// **'« {name} » sera supprimé sur tous tes appareils.'**
  String docRemoveBody(String name);

  /// No description provided for @docAddedOn.
  ///
  /// In fr, this message translates to:
  /// **'ajouté le {date}'**
  String docAddedOn(String date);

  /// No description provided for @docActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions'**
  String get docActions;

  /// No description provided for @docOpen.
  ///
  /// In fr, this message translates to:
  /// **'Ouvrir'**
  String get docOpen;

  /// No description provided for @docSave.
  ///
  /// In fr, this message translates to:
  /// **'Enregistrer'**
  String get docSave;

  /// No description provided for @docRemove.
  ///
  /// In fr, this message translates to:
  /// **'Retirer'**
  String get docRemove;

  /// No description provided for @docEmptyCourse.
  ///
  /// In fr, this message translates to:
  /// **'Aucun justificatif. Ajoute la facture d\'inscription ou le reçu de don (PDF ou photo).'**
  String get docEmptyCourse;

  /// No description provided for @docZip.
  ///
  /// In fr, this message translates to:
  /// **'Tout exporter (ZIP)'**
  String get docZip;

  /// No description provided for @docZipMissing.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 justificatif indisponible n\'a pas été inclus (hors connexion ?).} other{{count} justificatifs indisponibles n\'ont pas été inclus (hors connexion ?).}}'**
  String docZipMissing(int count);

  /// No description provided for @docAllDates.
  ///
  /// In fr, this message translates to:
  /// **'Toutes les dates'**
  String get docAllDates;

  /// No description provided for @docSearch.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une course, une association, un fichier…'**
  String get docSearch;

  /// No description provided for @docCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 justificatif} other{{count} justificatifs}} · {courses, plural, =1{1 course} other{{courses} courses}}'**
  String docCount(int count, int courses);

  /// No description provided for @docEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucun justificatif pour l\'instant. Ajoute-les depuis la fiche d\'une course ou avec le bouton ci-dessous.'**
  String get docEmpty;

  /// No description provided for @docNoMatch.
  ///
  /// In fr, this message translates to:
  /// **'Aucun justificatif sur cette période.'**
  String get docNoMatch;

  /// No description provided for @docChooseCourse.
  ///
  /// In fr, this message translates to:
  /// **'Rattacher à quelle course ?'**
  String get docChooseCourse;

  /// No description provided for @docKindConfirmation.
  ///
  /// In fr, this message translates to:
  /// **'Mail de confirmation'**
  String get docKindConfirmation;

  /// No description provided for @docKindInvoice.
  ///
  /// In fr, this message translates to:
  /// **'Facture'**
  String get docKindInvoice;

  /// No description provided for @docKindReceipt.
  ///
  /// In fr, this message translates to:
  /// **'Reçu de don'**
  String get docKindReceipt;

  /// No description provided for @docKindResult.
  ///
  /// In fr, this message translates to:
  /// **'Résultat de course'**
  String get docKindResult;

  /// No description provided for @docKindOther.
  ///
  /// In fr, this message translates to:
  /// **'Autre document'**
  String get docKindOther;

  /// No description provided for @docChooseKind.
  ///
  /// In fr, this message translates to:
  /// **'Quel type de justificatif ?'**
  String get docChooseKind;

  /// No description provided for @docChangeKind.
  ///
  /// In fr, this message translates to:
  /// **'Changer le type'**
  String get docChangeKind;

  /// No description provided for @reportDocsZip.
  ///
  /// In fr, this message translates to:
  /// **'Justificatifs (ZIP)'**
  String get reportDocsZip;

  /// No description provided for @assoTitle.
  ///
  /// In fr, this message translates to:
  /// **'Association'**
  String get assoTitle;

  /// No description provided for @assoNotFound.
  ///
  /// In fr, this message translates to:
  /// **'Aucune course solidaire terminée pour cette association.'**
  String get assoNotFound;

  /// No description provided for @assoCourses.
  ///
  /// In fr, this message translates to:
  /// **'Courses pour cette association'**
  String get assoCourses;

  /// No description provided for @assoExport.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif à partager'**
  String get assoExport;

  /// No description provided for @assoCardTitle.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif'**
  String get assoCardTitle;

  /// No description provided for @assoRecapTitle.
  ///
  /// In fr, this message translates to:
  /// **'Récapitulatif ÉLAN : {name}'**
  String assoRecapTitle(String name);

  /// No description provided for @assoRecapLine.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 course solidaire} other{{count} courses solidaires}} du {from} au {to}, soit {distance} courus pour l\'association.'**
  String assoRecapLine(int count, String from, String to, String distance);

  /// No description provided for @assoRecapLineOne.
  ///
  /// In fr, this message translates to:
  /// **'1 course solidaire le {date}, soit {distance} courus pour l\'association.'**
  String assoRecapLineOne(String date, String distance);

  /// No description provided for @assoCauses.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{Cause soutenue} other{Causes soutenues}} : {list}.'**
  String assoCauses(int count, String list);

  /// No description provided for @assoOpen.
  ///
  /// In fr, this message translates to:
  /// **'Voir le récapitulatif de {name}'**
  String assoOpen(String name);

  /// No description provided for @docCountShort.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 justificatif} other{{count} justificatifs}}'**
  String docCountShort(int count);

  /// No description provided for @evolutionTitle.
  ///
  /// In fr, this message translates to:
  /// **'Évolution'**
  String get evolutionTitle;

  /// No description provided for @rangeLast12.
  ///
  /// In fr, this message translates to:
  /// **'12 derniers mois'**
  String get rangeLast12;

  /// No description provided for @rangeLast12Short.
  ///
  /// In fr, this message translates to:
  /// **'12 mois'**
  String get rangeLast12Short;

  /// No description provided for @rangeByMonth.
  ///
  /// In fr, this message translates to:
  /// **'Par mois'**
  String get rangeByMonth;

  /// No description provided for @rangeByYear.
  ///
  /// In fr, this message translates to:
  /// **'Par année'**
  String get rangeByYear;

  /// No description provided for @summaryLast12.
  ///
  /// In fr, this message translates to:
  /// **'Sur les 12 derniers mois'**
  String get summaryLast12;

  /// No description provided for @summaryYear.
  ///
  /// In fr, this message translates to:
  /// **'En {year}'**
  String summaryYear(int year);

  /// No description provided for @summaryAll.
  ///
  /// In fr, this message translates to:
  /// **'Depuis {year}'**
  String summaryAll(int year);

  /// No description provided for @compareLast12.
  ///
  /// In fr, this message translates to:
  /// **'Flèches : variation par rapport aux 12 mois précédents.'**
  String get compareLast12;

  /// No description provided for @compareYearToDate.
  ///
  /// In fr, this message translates to:
  /// **'Flèches : variation par rapport à {year} à la même date ({date}).'**
  String compareYearToDate(int year, String date);

  /// No description provided for @compareYear.
  ///
  /// In fr, this message translates to:
  /// **'Flèches : variation par rapport à {year}.'**
  String compareYear(int year);

  /// No description provided for @deltaNew.
  ///
  /// In fr, this message translates to:
  /// **'nouveau'**
  String get deltaNew;

  /// No description provided for @periodEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune course terminée sur cette période.'**
  String get periodEmpty;

  /// No description provided for @periodCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{aucune course} =1{1 course} other{{count} courses}}'**
  String periodCount(int count);

  /// No description provided for @chartKmByMonth.
  ///
  /// In fr, this message translates to:
  /// **'Kilomètres par mois'**
  String get chartKmByMonth;

  /// No description provided for @chartKmByYear.
  ///
  /// In fr, this message translates to:
  /// **'Kilomètres par année'**
  String get chartKmByYear;

  /// No description provided for @chartKmHint.
  ///
  /// In fr, this message translates to:
  /// **'Distance des courses terminées. Touche une barre pour voir ses courses.'**
  String get chartKmHint;

  /// No description provided for @legendDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance courue (km)'**
  String get legendDistance;

  /// No description provided for @chartCumulativeTitle.
  ///
  /// In fr, this message translates to:
  /// **'Cumul de l\'année {year}'**
  String chartCumulativeTitle(int year);

  /// No description provided for @chartCumulativeHint.
  ///
  /// In fr, this message translates to:
  /// **'Kilomètres accumulés depuis le 1er janvier, comparés à l\'année précédente. Chaque marche est une course.'**
  String get chartCumulativeHint;

  /// No description provided for @cumulativeAt.
  ///
  /// In fr, this message translates to:
  /// **'au {date}'**
  String cumulativeAt(String date);

  /// No description provided for @cumulativeYear.
  ///
  /// In fr, this message translates to:
  /// **'sur l\'année'**
  String get cumulativeYear;

  /// No description provided for @chartPaceTitle.
  ///
  /// In fr, this message translates to:
  /// **'Allure de chaque course officielle'**
  String get chartPaceTitle;

  /// No description provided for @legendPace.
  ///
  /// In fr, this message translates to:
  /// **'Une course chronométrée'**
  String get legendPace;

  /// No description provided for @viewChart.
  ///
  /// In fr, this message translates to:
  /// **'Graphique'**
  String get viewChart;

  /// No description provided for @viewTable.
  ///
  /// In fr, this message translates to:
  /// **'Tableau'**
  String get viewTable;

  /// No description provided for @chartPaceHint.
  ///
  /// In fr, this message translates to:
  /// **'En minutes par kilomètre. Plus le point est haut, plus tu as couru vite.'**
  String get chartPaceHint;

  /// No description provided for @chartEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore assez de courses terminées pour tracer une évolution.'**
  String get chartEmpty;

  /// No description provided for @tablePeriod.
  ///
  /// In fr, this message translates to:
  /// **'Période'**
  String get tablePeriod;

  /// No description provided for @tableRaces.
  ///
  /// In fr, this message translates to:
  /// **'Courses'**
  String get tableRaces;

  /// No description provided for @recordsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Records'**
  String get recordsTitle;

  /// No description provided for @recordsEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Termine au moins une course chronométrée pour voir tes records.'**
  String get recordsEmpty;

  /// No description provided for @recordsByDistance.
  ///
  /// In fr, this message translates to:
  /// **'Meilleurs temps'**
  String get recordsByDistance;

  /// No description provided for @recordsLongest.
  ///
  /// In fr, this message translates to:
  /// **'Plus longues distances'**
  String get recordsLongest;

  /// No description provided for @recordsElevation.
  ///
  /// In fr, this message translates to:
  /// **'Plus gros dénivelés'**
  String get recordsElevation;

  /// No description provided for @recordsAllTime.
  ///
  /// In fr, this message translates to:
  /// **'Tous les temps'**
  String get recordsAllTime;

  /// No description provided for @recordsEmptyYear.
  ///
  /// In fr, this message translates to:
  /// **'Aucune course chronométrée en {year}.'**
  String recordsEmptyYear(int year);

  /// No description provided for @galleryTitle.
  ///
  /// In fr, this message translates to:
  /// **'Médailles et dossards'**
  String get galleryTitle;

  /// No description provided for @galleryAll.
  ///
  /// In fr, this message translates to:
  /// **'Tout'**
  String get galleryAll;

  /// No description provided for @galleryMedals.
  ///
  /// In fr, this message translates to:
  /// **'Médailles'**
  String get galleryMedals;

  /// No description provided for @galleryBibs.
  ///
  /// In fr, this message translates to:
  /// **'Dossards'**
  String get galleryBibs;

  /// No description provided for @galleryEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune photo pour l\'instant. Ajoute la médaille ou le dossard dans le formulaire d\'une course.'**
  String get galleryEmpty;

  /// No description provided for @galleryCount.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 photo} other{{count} photos}}'**
  String galleryCount(int count);

  /// No description provided for @settingsAccount.
  ///
  /// In fr, this message translates to:
  /// **'Compte'**
  String get settingsAccount;

  /// No description provided for @settingsSignedInAs.
  ///
  /// In fr, this message translates to:
  /// **'Connecté en tant que {email}'**
  String settingsSignedInAs(String email);

  /// No description provided for @settingsChangePassword.
  ///
  /// In fr, this message translates to:
  /// **'Changer de mot de passe'**
  String get settingsChangePassword;

  /// No description provided for @settingsNewPassword.
  ///
  /// In fr, this message translates to:
  /// **'Nouveau mot de passe'**
  String get settingsNewPassword;

  /// No description provided for @settingsPasswordTooShort.
  ///
  /// In fr, this message translates to:
  /// **'8 caractères minimum.'**
  String get settingsPasswordTooShort;

  /// No description provided for @settingsPasswordChanged.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe modifié.'**
  String get settingsPasswordChanged;

  /// No description provided for @settingsSignOut.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter'**
  String get settingsSignOut;

  /// No description provided for @settingsSignOutTitle.
  ///
  /// In fr, this message translates to:
  /// **'Se déconnecter ?'**
  String get settingsSignOutTitle;

  /// No description provided for @settingsSignOutPending.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 modification n\'est pas encore envoyée. Elle reste sur cet appareil et partira à ta prochaine connexion.} other{{count} modifications ne sont pas encore envoyées. Elles restent sur cet appareil et partiront à ta prochaine connexion.}}'**
  String settingsSignOutPending(int count);

  /// No description provided for @settingsSignOutClean.
  ///
  /// In fr, this message translates to:
  /// **'Tes courses restent sur le cloud et sur cet appareil.'**
  String get settingsSignOutClean;

  /// No description provided for @settingsAppearance.
  ///
  /// In fr, this message translates to:
  /// **'Apparence'**
  String get settingsAppearance;

  /// No description provided for @themeSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In fr, this message translates to:
  /// **'Clair'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In fr, this message translates to:
  /// **'Sombre'**
  String get themeDark;

  /// No description provided for @backupSection.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde'**
  String get backupSection;

  /// No description provided for @backupHint.
  ///
  /// In fr, this message translates to:
  /// **'Une copie de toutes tes courses (toutes les colonnes), indépendante du cloud, à garder où tu veux.'**
  String get backupHint;

  /// No description provided for @backupExcel.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en Excel'**
  String get backupExcel;

  /// No description provided for @backupCsv.
  ///
  /// In fr, this message translates to:
  /// **'Exporter en CSV'**
  String get backupCsv;

  /// No description provided for @backupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde ÉLAN du {date}'**
  String backupTitle(String date);

  /// No description provided for @backupSheetName.
  ///
  /// In fr, this message translates to:
  /// **'Courses'**
  String get backupSheetName;

  /// No description provided for @backupDate.
  ///
  /// In fr, this message translates to:
  /// **'Date'**
  String get backupDate;

  /// No description provided for @backupCourse.
  ///
  /// In fr, this message translates to:
  /// **'Course'**
  String get backupCourse;

  /// No description provided for @backupType.
  ///
  /// In fr, this message translates to:
  /// **'Type'**
  String get backupType;

  /// No description provided for @backupStatus.
  ///
  /// In fr, this message translates to:
  /// **'Statut'**
  String get backupStatus;

  /// No description provided for @backupDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance (km)'**
  String get backupDistance;

  /// No description provided for @backupTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps'**
  String get backupTime;

  /// No description provided for @backupPace.
  ///
  /// In fr, this message translates to:
  /// **'Allure (min/km)'**
  String get backupPace;

  /// No description provided for @backupElevation.
  ///
  /// In fr, this message translates to:
  /// **'D+ (m)'**
  String get backupElevation;

  /// No description provided for @backupTeam.
  ///
  /// In fr, this message translates to:
  /// **'Équipe (membres)'**
  String get backupTeam;

  /// No description provided for @backupChallenge.
  ///
  /// In fr, this message translates to:
  /// **'Distance du défi (km)'**
  String get backupChallenge;

  /// No description provided for @backupCharity.
  ///
  /// In fr, this message translates to:
  /// **'Solidaire'**
  String get backupCharity;

  /// No description provided for @backupAssociation.
  ///
  /// In fr, this message translates to:
  /// **'Association'**
  String get backupAssociation;

  /// No description provided for @backupCause.
  ///
  /// In fr, this message translates to:
  /// **'Cause'**
  String get backupCause;

  /// No description provided for @backupSponsor.
  ///
  /// In fr, this message translates to:
  /// **'Parrainage (€/km)'**
  String get backupSponsor;

  /// No description provided for @backupRegistration.
  ///
  /// In fr, this message translates to:
  /// **'Don à l\'inscription (€)'**
  String get backupRegistration;

  /// No description provided for @backupFundraising.
  ///
  /// In fr, this message translates to:
  /// **'Collecte (€)'**
  String get backupFundraising;

  /// No description provided for @backupTotal.
  ///
  /// In fr, this message translates to:
  /// **'Total engagé (€)'**
  String get backupTotal;

  /// No description provided for @backupMetric.
  ///
  /// In fr, this message translates to:
  /// **'Équivalence annoncée'**
  String get backupMetric;

  /// No description provided for @backupQuantity.
  ///
  /// In fr, this message translates to:
  /// **'Quantité'**
  String get backupQuantity;

  /// No description provided for @backupDocuments.
  ///
  /// In fr, this message translates to:
  /// **'Justificatifs'**
  String get backupDocuments;

  /// No description provided for @backupNotes.
  ///
  /// In fr, this message translates to:
  /// **'Notes'**
  String get backupNotes;

  /// No description provided for @backupCreated.
  ///
  /// In fr, this message translates to:
  /// **'Ajoutée le'**
  String get backupCreated;

  /// No description provided for @backupUpdated.
  ///
  /// In fr, this message translates to:
  /// **'Modifiée le'**
  String get backupUpdated;

  /// No description provided for @backupYes.
  ///
  /// In fr, this message translates to:
  /// **'Oui'**
  String get backupYes;

  /// No description provided for @backupNo.
  ///
  /// In fr, this message translates to:
  /// **'Non'**
  String get backupNo;

  /// No description provided for @reminderSetting.
  ///
  /// In fr, this message translates to:
  /// **'Rappel le soir de la course'**
  String get reminderSetting;

  /// No description provided for @reminderSettingHint.
  ///
  /// In fr, this message translates to:
  /// **'Une notification à {time} le jour J pour saisir ton temps.'**
  String reminderSettingHint(String time);

  /// No description provided for @reminderTime.
  ///
  /// In fr, this message translates to:
  /// **'Heure du rappel'**
  String get reminderTime;

  /// No description provided for @reminderTitle.
  ///
  /// In fr, this message translates to:
  /// **'Ta course : {title}'**
  String reminderTitle(String title);

  /// No description provided for @reminderBody.
  ///
  /// In fr, this message translates to:
  /// **'Saisis ton temps pour l\'ajouter à tes totaux et à tes records.'**
  String get reminderBody;

  /// No description provided for @settingsWallpaperColors.
  ///
  /// In fr, this message translates to:
  /// **'Couleurs du fond d\'écran'**
  String get settingsWallpaperColors;

  /// No description provided for @settingsWallpaperColorsHint.
  ///
  /// In fr, this message translates to:
  /// **'Material You : l\'app prend les couleurs de ton téléphone. Désactive pour garder les couleurs ÉLAN.'**
  String get settingsWallpaperColorsHint;

  /// No description provided for @syncTitle.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation'**
  String get syncTitle;

  /// No description provided for @syncNow.
  ///
  /// In fr, this message translates to:
  /// **'Synchroniser maintenant'**
  String get syncNow;

  /// No description provided for @syncUpToDate.
  ///
  /// In fr, this message translates to:
  /// **'Tout est synchronisé'**
  String get syncUpToDate;

  /// No description provided for @syncRunning.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation en cours'**
  String get syncRunning;

  /// No description provided for @syncPending.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 modification en attente} other{{count} modifications en attente}}'**
  String syncPending(int count);

  /// No description provided for @syncFailed.
  ///
  /// In fr, this message translates to:
  /// **'Synchronisation en échec'**
  String get syncFailed;

  /// No description provided for @syncLast.
  ///
  /// In fr, this message translates to:
  /// **'Dernière synchronisation : {date}'**
  String syncLast(String date);

  /// No description provided for @syncImported.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 course de l\'ancienne version importée.} other{{count} courses de l\'ancienne version importées.}}'**
  String syncImported(int count);

  /// No description provided for @serverTitle.
  ///
  /// In fr, this message translates to:
  /// **'Serveur'**
  String get serverTitle;

  /// No description provided for @serverIntro.
  ///
  /// In fr, this message translates to:
  /// **'ÉLAN enregistre tes courses sur un serveur. Par défaut, c\'est celui d\'ÉLAN ; tu peux aussi utiliser ton propre serveur, par exemple installé sur un NAS.'**
  String get serverIntro;

  /// No description provided for @serverIntroCustomOnly.
  ///
  /// In fr, this message translates to:
  /// **'Indique le serveur où ÉLAN enregistre tes courses : ton serveur personnel (par exemple sur un NAS) ou ton projet Supabase.'**
  String get serverIntroCustomOnly;

  /// No description provided for @serverBuiltIn.
  ///
  /// In fr, this message translates to:
  /// **'Serveur ÉLAN'**
  String get serverBuiltIn;

  /// No description provided for @serverBuiltInHint.
  ///
  /// In fr, this message translates to:
  /// **'Par défaut'**
  String get serverBuiltInHint;

  /// No description provided for @serverCustom.
  ///
  /// In fr, this message translates to:
  /// **'Mon serveur'**
  String get serverCustom;

  /// No description provided for @serverCustomHint.
  ///
  /// In fr, this message translates to:
  /// **'Installé chez toi, par exemple sur un NAS'**
  String get serverCustomHint;

  /// No description provided for @serverAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse du serveur'**
  String get serverAddress;

  /// No description provided for @serverAddressHint.
  ///
  /// In fr, this message translates to:
  /// **'http://192.168.1.20:8000'**
  String get serverAddressHint;

  /// No description provided for @serverPaste.
  ///
  /// In fr, this message translates to:
  /// **'Coller'**
  String get serverPaste;

  /// No description provided for @serverSave.
  ///
  /// In fr, this message translates to:
  /// **'Vérifier et enregistrer'**
  String get serverSave;

  /// No description provided for @serverChecking.
  ///
  /// In fr, this message translates to:
  /// **'Vérification du serveur…'**
  String get serverChecking;

  /// No description provided for @serverErrorAddress.
  ///
  /// In fr, this message translates to:
  /// **'Adresse invalide. Exemple : http://192.168.1.20:8000'**
  String get serverErrorAddress;

  /// No description provided for @serverErrorHttp.
  ///
  /// In fr, this message translates to:
  /// **'Sur Internet, l\'adresse doit commencer par https:// (en http, le mot de passe circulerait en clair). http n\'est accepté que sur le réseau local ou le VPN.'**
  String get serverErrorHttp;

  /// No description provided for @serverUnreachable.
  ///
  /// In fr, this message translates to:
  /// **'Serveur injoignable. Vérifie l\'adresse, que le VPN est actif et que le serveur est démarré.'**
  String get serverUnreachable;

  /// No description provided for @serverLabel.
  ///
  /// In fr, this message translates to:
  /// **'Serveur : {name}'**
  String serverLabel(String name);

  /// No description provided for @autoBackupTitle.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde automatique'**
  String get autoBackupTitle;

  /// No description provided for @autoBackupHint.
  ///
  /// In fr, this message translates to:
  /// **'Chaque semaine, une copie des courses (Excel) et des photos et justificatifs dans un dossier de ton choix : Proton Drive, disque externe… Les 8 dernières copies Excel sont gardées.'**
  String get autoBackupHint;

  /// No description provided for @autoBackupEnable.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder chaque semaine'**
  String get autoBackupEnable;

  /// No description provided for @autoBackupFolder.
  ///
  /// In fr, this message translates to:
  /// **'Dossier : {path}'**
  String autoBackupFolder(String path);

  /// No description provided for @autoBackupNoFolder.
  ///
  /// In fr, this message translates to:
  /// **'Aucun dossier choisi'**
  String get autoBackupNoFolder;

  /// No description provided for @autoBackupChoose.
  ///
  /// In fr, this message translates to:
  /// **'Choisir le dossier'**
  String get autoBackupChoose;

  /// No description provided for @autoBackupNow.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarder maintenant'**
  String get autoBackupNow;

  /// No description provided for @autoBackupLast.
  ///
  /// In fr, this message translates to:
  /// **'Dernière sauvegarde : {date}'**
  String autoBackupLast(String date);

  /// No description provided for @autoBackupNever.
  ///
  /// In fr, this message translates to:
  /// **'Pas encore de sauvegarde'**
  String get autoBackupNever;

  /// No description provided for @autoBackupRunning.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde en cours…'**
  String get autoBackupRunning;

  /// No description provided for @autoBackupCopied.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucun nouveau fichier} =1{1 nouveau fichier copié} other{{count} nouveaux fichiers copiés}}'**
  String autoBackupCopied(int count);

  /// No description provided for @autoBackupMissing.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 fichier introuvable pour l\'instant, réessayé la prochaine fois} other{{count} fichiers introuvables pour l\'instant, réessayés la prochaine fois}}'**
  String autoBackupMissing(int count);

  /// No description provided for @autoBackupError.
  ///
  /// In fr, this message translates to:
  /// **'Sauvegarde impossible : {error}'**
  String autoBackupError(String error);

  /// No description provided for @gpxBatchAction.
  ///
  /// In fr, this message translates to:
  /// **'Importer des fichiers GPX'**
  String get gpxBatchAction;

  /// No description provided for @gpxBatchTitle.
  ///
  /// In fr, this message translates to:
  /// **'Import GPX'**
  String get gpxBatchTitle;

  /// No description provided for @gpxBatchDefaultTitle.
  ///
  /// In fr, this message translates to:
  /// **'Course du {date}'**
  String gpxBatchDefaultTitle(String date);

  /// No description provided for @gpxBatchCreated.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune course ajoutée.} =1{1 course ajoutée.} other{{count} courses ajoutées.}}'**
  String gpxBatchCreated(int count);

  /// No description provided for @gpxBatchDuplicates.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 trace déjà présente, ignorée.} other{{count} traces déjà présentes, ignorées.}}'**
  String gpxBatchDuplicates(int count);

  /// No description provided for @gpxBatchUndated.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 trace sans date, ignorée.} other{{count} traces sans date, ignorées.}}'**
  String gpxBatchUndated(int count);

  /// No description provided for @gpxBatchUnreadable.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =1{1 fichier illisible.} other{{count} fichiers illisibles.}}'**
  String gpxBatchUnreadable(int count);

  /// No description provided for @gpxBatchHint.
  ///
  /// In fr, this message translates to:
  /// **'Elles sont rangées en courses officielles : ouvre-les pour compléter le titre, l\'association…'**
  String get gpxBatchHint;

  /// No description provided for @updateAvailable.
  ///
  /// In fr, this message translates to:
  /// **'ÉLAN {version} est disponible.'**
  String updateAvailable(String version);

  /// No description provided for @updateDownload.
  ///
  /// In fr, this message translates to:
  /// **'Télécharger'**
  String get updateDownload;

  /// No description provided for @updateLater.
  ///
  /// In fr, this message translates to:
  /// **'Plus tard'**
  String get updateLater;

  /// No description provided for @updateUpToDate.
  ///
  /// In fr, this message translates to:
  /// **'Tu as la dernière version.'**
  String get updateUpToDate;

  /// No description provided for @updateCheck.
  ///
  /// In fr, this message translates to:
  /// **'Rechercher une mise à jour'**
  String get updateCheck;

  /// No description provided for @settingsAbout.
  ///
  /// In fr, this message translates to:
  /// **'À propos'**
  String get settingsAbout;

  /// No description provided for @settingsVersion.
  ///
  /// In fr, this message translates to:
  /// **'ÉLAN {version}'**
  String settingsVersion(String version);

  /// No description provided for @signInShowPassword.
  ///
  /// In fr, this message translates to:
  /// **'Afficher le mot de passe'**
  String get signInShowPassword;

  /// No description provided for @signInHidePassword.
  ///
  /// In fr, this message translates to:
  /// **'Masquer le mot de passe'**
  String get signInHidePassword;

  /// No description provided for @signInForgottenCustom.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe oublié ? Le propriétaire du serveur peut t\'en donner un nouveau, dans Réglages > Comptes du serveur.'**
  String get signInForgottenCustom;

  /// No description provided for @serverAddressHelp.
  ///
  /// In fr, this message translates to:
  /// **'C\'est l\'adresse affichée sur la page d\'accueil de ton serveur (bouton « Copier l\'adresse »).'**
  String get serverAddressHelp;

  /// No description provided for @serverNotElan.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse répond, mais ce n\'est pas un serveur ÉLAN. Vérifie le port (8000 par défaut).'**
  String get serverNotElan;

  /// No description provided for @serverTooRecent.
  ///
  /// In fr, this message translates to:
  /// **'Ce serveur est plus récent que l\'app. Mets l\'app à jour, puis réessaie.'**
  String get serverTooRecent;

  /// No description provided for @signInIntroCustom.
  ///
  /// In fr, this message translates to:
  /// **'Connecte-toi avec le compte créé pour toi sur ce serveur.'**
  String get signInIntroCustom;

  /// No description provided for @firstAccountTitle.
  ///
  /// In fr, this message translates to:
  /// **'Premier compte'**
  String get firstAccountTitle;

  /// No description provided for @firstAccountIntro.
  ///
  /// In fr, this message translates to:
  /// **'Ce serveur est tout neuf. Crée le premier compte : il sera le propriétaire du serveur et pourra ajouter les comptes de ses proches.'**
  String get firstAccountIntro;

  /// No description provided for @firstAccountButton.
  ///
  /// In fr, this message translates to:
  /// **'Créer mon compte'**
  String get firstAccountButton;

  /// No description provided for @firstAccountTaken.
  ///
  /// In fr, this message translates to:
  /// **'Ce serveur a déjà un compte. Connecte-toi, ou demande un compte à son propriétaire.'**
  String get firstAccountTaken;

  /// No description provided for @passwordConfirmLabel.
  ///
  /// In fr, this message translates to:
  /// **'Confirmer le mot de passe'**
  String get passwordConfirmLabel;

  /// No description provided for @passwordMismatch.
  ///
  /// In fr, this message translates to:
  /// **'Les deux mots de passe sont différents.'**
  String get passwordMismatch;

  /// No description provided for @settingsCurrentPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel'**
  String get settingsCurrentPassword;

  /// No description provided for @settingsWrongCurrentPassword.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe actuel incorrect.'**
  String get settingsWrongCurrentPassword;

  /// No description provided for @accountsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Comptes du serveur'**
  String get accountsTitle;

  /// No description provided for @accountsIntro.
  ///
  /// In fr, this message translates to:
  /// **'Chaque personne a son compte et ne voit que ses propres courses.'**
  String get accountsIntro;

  /// No description provided for @accountsManage.
  ///
  /// In fr, this message translates to:
  /// **'Gérer les comptes'**
  String get accountsManage;

  /// No description provided for @accountsOwner.
  ///
  /// In fr, this message translates to:
  /// **'Propriétaire du serveur'**
  String get accountsOwner;

  /// No description provided for @accountsYou.
  ///
  /// In fr, this message translates to:
  /// **'Toi'**
  String get accountsYou;

  /// No description provided for @accountsAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter un compte'**
  String get accountsAdd;

  /// No description provided for @accountsAddIntro.
  ///
  /// In fr, this message translates to:
  /// **'Choisis son e-mail et un mot de passe provisoire, puis transmets-les lui. La personne pourra changer son mot de passe dans Réglages.'**
  String get accountsAddIntro;

  /// No description provided for @accountsCreated.
  ///
  /// In fr, this message translates to:
  /// **'Compte créé.'**
  String get accountsCreated;

  /// No description provided for @accountsEmailTaken.
  ///
  /// In fr, this message translates to:
  /// **'Un compte existe déjà avec cette adresse.'**
  String get accountsEmailTaken;

  /// No description provided for @accountsReset.
  ///
  /// In fr, this message translates to:
  /// **'Donner un nouveau mot de passe'**
  String get accountsReset;

  /// No description provided for @accountsResetDone.
  ///
  /// In fr, this message translates to:
  /// **'Mot de passe remplacé.'**
  String get accountsResetDone;

  /// No description provided for @accountsDelete.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte'**
  String get accountsDelete;

  /// No description provided for @accountsDeleteConfirm.
  ///
  /// In fr, this message translates to:
  /// **'Supprimer le compte {email} ? Ses courses, photos et justificatifs enregistrés sur le serveur seront effacés définitivement.'**
  String accountsDeleteConfirm(String email);

  /// No description provided for @accountsDeleted.
  ///
  /// In fr, this message translates to:
  /// **'Compte supprimé.'**
  String get accountsDeleted;

  /// No description provided for @accountsError.
  ///
  /// In fr, this message translates to:
  /// **'Action impossible. Vérifie la connexion au serveur.'**
  String get accountsError;

  /// No description provided for @accountsActions.
  ///
  /// In fr, this message translates to:
  /// **'Actions pour {email}'**
  String accountsActions(String email);

  /// No description provided for @typeMultisport.
  ///
  /// In fr, this message translates to:
  /// **'Triathlon, duathlon, aquathlon'**
  String get typeMultisport;

  /// No description provided for @typeShortOfficial.
  ///
  /// In fr, this message translates to:
  /// **'Course'**
  String get typeShortOfficial;

  /// No description provided for @typeShortConqueror.
  ///
  /// In fr, this message translates to:
  /// **'Défi'**
  String get typeShortConqueror;

  /// No description provided for @typeShortMultisport.
  ///
  /// In fr, this message translates to:
  /// **'Triathlon'**
  String get typeShortMultisport;

  /// No description provided for @kindMultisport.
  ///
  /// In fr, this message translates to:
  /// **'Triathlons'**
  String get kindMultisport;

  /// No description provided for @kindMultisportHint.
  ///
  /// In fr, this message translates to:
  /// **'Triathlons, duathlons et aquathlons'**
  String get kindMultisportHint;

  /// No description provided for @multisportTriathlon.
  ///
  /// In fr, this message translates to:
  /// **'Triathlon'**
  String get multisportTriathlon;

  /// No description provided for @multisportDuathlon.
  ///
  /// In fr, this message translates to:
  /// **'Duathlon'**
  String get multisportDuathlon;

  /// No description provided for @multisportAquathlon.
  ///
  /// In fr, this message translates to:
  /// **'Aquathlon'**
  String get multisportAquathlon;

  /// No description provided for @sportSwim.
  ///
  /// In fr, this message translates to:
  /// **'Natation'**
  String get sportSwim;

  /// No description provided for @sportBike.
  ///
  /// In fr, this message translates to:
  /// **'Vélo'**
  String get sportBike;

  /// No description provided for @sportRun.
  ///
  /// In fr, this message translates to:
  /// **'Course à pied'**
  String get sportRun;

  /// No description provided for @sportRunNumbered.
  ///
  /// In fr, this message translates to:
  /// **'Course à pied {number}'**
  String sportRunNumbered(int number);

  /// No description provided for @multisportFormat.
  ///
  /// In fr, this message translates to:
  /// **'Format'**
  String get multisportFormat;

  /// No description provided for @multisportFormatFree.
  ///
  /// In fr, this message translates to:
  /// **'Libre'**
  String get multisportFormatFree;

  /// No description provided for @multisportFormatHint.
  ///
  /// In fr, this message translates to:
  /// **'Le format préremplit les distances. Corrige-les si ton épreuve était différente.'**
  String get multisportFormatHint;

  /// No description provided for @multisportLegDistance.
  ///
  /// In fr, this message translates to:
  /// **'Distance'**
  String get multisportLegDistance;

  /// No description provided for @multisportLegTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps'**
  String get multisportLegTime;

  /// No description provided for @multisportTransition.
  ///
  /// In fr, this message translates to:
  /// **'Transition {number}'**
  String multisportTransition(int number);

  /// No description provided for @multisportTransitionsIncluded.
  ///
  /// In fr, this message translates to:
  /// **'Transitions comptées dans les disciplines'**
  String get multisportTransitionsIncluded;

  /// No description provided for @multisportTransitionsIncludedHint.
  ///
  /// In fr, this message translates to:
  /// **'À cocher si ton chrono n\'isole pas les transitions : chacune est alors comprise dans le temps de la discipline qui la précède.'**
  String get multisportTransitionsIncludedHint;

  /// No description provided for @multisportTotalTime.
  ///
  /// In fr, this message translates to:
  /// **'Temps total'**
  String get multisportTotalTime;

  /// No description provided for @multisportTotalComputed.
  ///
  /// In fr, this message translates to:
  /// **'Laisse vide : calculé d\'après les temps ci-dessus ({time}).'**
  String multisportTotalComputed(String time);

  /// No description provided for @multisportTotalOnly.
  ///
  /// In fr, this message translates to:
  /// **'Tu peux saisir seulement le temps total si tu n\'as pas le détail.'**
  String get multisportTotalOnly;

  /// No description provided for @multisportTransitionIncludedNote.
  ///
  /// In fr, this message translates to:
  /// **'transition comprise'**
  String get multisportTransitionIncludedNote;

  /// No description provided for @multisportTransitions.
  ///
  /// In fr, this message translates to:
  /// **'Transitions'**
  String get multisportTransitions;

  /// No description provided for @multisportBreakdown.
  ///
  /// In fr, this message translates to:
  /// **'Répartition du temps'**
  String get multisportBreakdown;

  /// No description provided for @multisportRunShare.
  ///
  /// In fr, this message translates to:
  /// **'{run} de course à pied comptés dans tes kilomètres courus.'**
  String multisportRunShare(String run);

  /// No description provided for @multisportEditResult.
  ///
  /// In fr, this message translates to:
  /// **'Saisir mes temps'**
  String get multisportEditResult;

  /// No description provided for @issueLegDistance.
  ///
  /// In fr, this message translates to:
  /// **'Indique la distance de chaque discipline.'**
  String get issueLegDistance;

  /// No description provided for @issueLegTimes.
  ///
  /// In fr, this message translates to:
  /// **'Renseigne le temps de chaque discipline, ou aucun (temps total seul).'**
  String get issueLegTimes;

  /// No description provided for @issueTotalBelowSplits.
  ///
  /// In fr, this message translates to:
  /// **'Le temps total est inférieur à la somme des disciplines ({time}).'**
  String issueTotalBelowSplits(String time);

  /// No description provided for @recordsMultisport.
  ///
  /// In fr, this message translates to:
  /// **'Triathlons, duathlons, aquathlons'**
  String get recordsMultisport;

  /// No description provided for @recordsMultisportBest.
  ///
  /// In fr, this message translates to:
  /// **'Meilleur temps'**
  String get recordsMultisportBest;

  /// No description provided for @swimPaceUnit.
  ///
  /// In fr, this message translates to:
  /// **'/100 m'**
  String get swimPaceUnit;

  /// No description provided for @shareMultisportTotal.
  ///
  /// In fr, this message translates to:
  /// **'Temps total'**
  String get shareMultisportTotal;

  /// No description provided for @summaryMultisport.
  ///
  /// In fr, this message translates to:
  /// **'{count, plural, =0{Aucune épreuve enchaînée} =1{1 épreuve enchaînée} other{{count} épreuves enchaînées}}'**
  String summaryMultisport(int count);

  /// No description provided for @backupDisciplines.
  ///
  /// In fr, this message translates to:
  /// **'Disciplines (triathlon, duathlon, aquathlon)'**
  String get backupDisciplines;

  /// No description provided for @evolutionSportsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Triathlons : par discipline'**
  String get evolutionSportsTitle;

  /// No description provided for @evolutionSportsHint.
  ///
  /// In fr, this message translates to:
  /// **'Distance et temps cumulés de tes triathlons, duathlons et aquathlons.'**
  String get evolutionSportsHint;

  /// No description provided for @evolutionSportsEvents.
  ///
  /// In fr, this message translates to:
  /// **'Épreuves'**
  String get evolutionSportsEvents;

  /// No description provided for @chartSportTitle.
  ///
  /// In fr, this message translates to:
  /// **'Rythme par discipline en triathlon'**
  String get chartSportTitle;

  /// No description provided for @chartSportHintSwim.
  ///
  /// In fr, this message translates to:
  /// **'En minutes aux 100 m. Plus le point est haut, plus tu as nagé vite.'**
  String get chartSportHintSwim;

  /// No description provided for @chartSportHintBike.
  ///
  /// In fr, this message translates to:
  /// **'En km/h. Plus le point est haut, plus tu as roulé vite.'**
  String get chartSportHintBike;

  /// No description provided for @chartSportHintRun.
  ///
  /// In fr, this message translates to:
  /// **'En minutes par kilomètre. Plus le point est haut, plus tu as couru vite.'**
  String get chartSportHintRun;

  /// No description provided for @chartSportNeedsTwo.
  ///
  /// In fr, this message translates to:
  /// **'Il faut deux épreuves chronométrées sur la période pour tracer cette discipline.'**
  String get chartSportNeedsTwo;

  /// No description provided for @legendSport.
  ///
  /// In fr, this message translates to:
  /// **'Une épreuve chronométrée'**
  String get legendSport;

  /// No description provided for @recordsBySport.
  ///
  /// In fr, this message translates to:
  /// **'Meilleurs rythmes en triathlon'**
  String get recordsBySport;

  /// No description provided for @recordsBySportHint.
  ///
  /// In fr, this message translates to:
  /// **'Par discipline, tous formats confondus (triathlons, duathlons, aquathlons).'**
  String get recordsBySportHint;

  /// No description provided for @formTarget.
  ///
  /// In fr, this message translates to:
  /// **'Temps visé (facultatif)'**
  String get formTarget;

  /// No description provided for @formTargetHint.
  ///
  /// In fr, this message translates to:
  /// **'Ton objectif pour cette course. Il reste affiché après, pour comparer.'**
  String get formTargetHint;

  /// No description provided for @formRanking.
  ///
  /// In fr, this message translates to:
  /// **'Classement'**
  String get formRanking;

  /// No description provided for @formRankingHint.
  ///
  /// In fr, this message translates to:
  /// **'Facultatif. Recopie ce que donne la feuille de résultats.'**
  String get formRankingHint;

  /// No description provided for @formRank.
  ///
  /// In fr, this message translates to:
  /// **'Place'**
  String get formRank;

  /// No description provided for @formFinishers.
  ///
  /// In fr, this message translates to:
  /// **'Arrivants'**
  String get formFinishers;

  /// No description provided for @formCategoryRank.
  ///
  /// In fr, this message translates to:
  /// **'Place dans la catégorie'**
  String get formCategoryRank;

  /// No description provided for @formCategoryFinishers.
  ///
  /// In fr, this message translates to:
  /// **'Arrivants de la catégorie'**
  String get formCategoryFinishers;

  /// No description provided for @formCategoryName.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get formCategoryName;

  /// No description provided for @formCategoryNameHint.
  ///
  /// In fr, this message translates to:
  /// **'SEH, M1…'**
  String get formCategoryNameHint;

  /// No description provided for @issueRankAboveFinishers.
  ///
  /// In fr, this message translates to:
  /// **'La place ne peut pas dépasser le nombre d\'arrivants.'**
  String get issueRankAboveFinishers;

  /// No description provided for @targetPlanned.
  ///
  /// In fr, this message translates to:
  /// **'Objectif {time}'**
  String targetPlanned(String time);

  /// No description provided for @targetBeaten.
  ///
  /// In fr, this message translates to:
  /// **'Objectif battu de {time}'**
  String targetBeaten(String time);

  /// No description provided for @targetMissed.
  ///
  /// In fr, this message translates to:
  /// **'Objectif manqué de {time}'**
  String targetMissed(String time);

  /// No description provided for @targetMet.
  ///
  /// In fr, this message translates to:
  /// **'Objectif atteint'**
  String get targetMet;

  /// No description provided for @rankingOverall.
  ///
  /// In fr, this message translates to:
  /// **'Général'**
  String get rankingOverall;

  /// No description provided for @rankingCategory.
  ///
  /// In fr, this message translates to:
  /// **'Catégorie'**
  String get rankingCategory;

  /// No description provided for @rankingOf.
  ///
  /// In fr, this message translates to:
  /// **'{rank} sur {total}'**
  String rankingOf(String rank, String total);

  /// No description provided for @rankingTop.
  ///
  /// In fr, this message translates to:
  /// **'dans les {percent} % premiers'**
  String rankingTop(int percent);

  /// No description provided for @ordinalFirst.
  ///
  /// In fr, this message translates to:
  /// **'1er'**
  String get ordinalFirst;

  /// No description provided for @ordinalOther.
  ///
  /// In fr, this message translates to:
  /// **'{n}e'**
  String ordinalOther(int n);

  /// No description provided for @chartRankTitle.
  ///
  /// In fr, this message translates to:
  /// **'Classement de chaque course'**
  String get chartRankTitle;

  /// No description provided for @chartRankHint.
  ///
  /// In fr, this message translates to:
  /// **'Part des arrivants classés devant toi. Plus le point est haut, mieux tu es classé.'**
  String get chartRankHint;

  /// No description provided for @legendRank.
  ///
  /// In fr, this message translates to:
  /// **'Une course classée'**
  String get legendRank;

  /// No description provided for @goalYearTitle.
  ///
  /// In fr, this message translates to:
  /// **'Objectif {year}'**
  String goalYearTitle(int year);

  /// No description provided for @goalSet.
  ///
  /// In fr, this message translates to:
  /// **'Fixer un objectif annuel'**
  String get goalSet;

  /// No description provided for @goalEdit.
  ///
  /// In fr, this message translates to:
  /// **'Modifier l\'objectif'**
  String get goalEdit;

  /// No description provided for @goalDialogField.
  ///
  /// In fr, this message translates to:
  /// **'Kilomètres à courir en {year}'**
  String goalDialogField(int year);

  /// No description provided for @goalDialogHint.
  ///
  /// In fr, this message translates to:
  /// **'Laisse vide pour retirer l\'objectif. Il te suit sur tes autres appareils.'**
  String get goalDialogHint;

  /// No description provided for @goalProgress.
  ///
  /// In fr, this message translates to:
  /// **'{done} sur {goal}'**
  String goalProgress(String done, String goal);

  /// No description provided for @goalAhead.
  ///
  /// In fr, this message translates to:
  /// **'En avance de {km} sur le rythme de l\'année.'**
  String goalAhead(String km);

  /// No description provided for @goalBehind.
  ///
  /// In fr, this message translates to:
  /// **'En retard de {km} sur le rythme de l\'année.'**
  String goalBehind(String km);

  /// No description provided for @goalOnTrack.
  ///
  /// In fr, this message translates to:
  /// **'Pile dans le rythme de l\'année.'**
  String get goalOnTrack;

  /// No description provided for @goalReached.
  ///
  /// In fr, this message translates to:
  /// **'Objectif atteint, bravo !'**
  String get goalReached;

  /// No description provided for @backupTarget.
  ///
  /// In fr, this message translates to:
  /// **'Temps visé'**
  String get backupTarget;

  /// No description provided for @backupRanking.
  ///
  /// In fr, this message translates to:
  /// **'Classement'**
  String get backupRanking;

  /// No description provided for @recapTitle.
  ///
  /// In fr, this message translates to:
  /// **'Bilan de l\'année'**
  String get recapTitle;

  /// No description provided for @recapAction.
  ///
  /// In fr, this message translates to:
  /// **'Bilan de l\'année à partager'**
  String get recapAction;

  /// No description provided for @recapKicker.
  ///
  /// In fr, this message translates to:
  /// **'Bilan {year}'**
  String recapKicker(int year);

  /// No description provided for @recapRun.
  ///
  /// In fr, this message translates to:
  /// **'courus'**
  String get recapRun;

  /// No description provided for @recapRecords.
  ///
  /// In fr, this message translates to:
  /// **'Records'**
  String get recapRecords;

  /// No description provided for @recapLongest.
  ///
  /// In fr, this message translates to:
  /// **'Plus longue course'**
  String get recapLongest;

  /// No description provided for @recapDonations.
  ///
  /// In fr, this message translates to:
  /// **'{amount} pour {count, plural, =1{1 association} other{{count} associations}}'**
  String recapDonations(String amount, int count);

  /// No description provided for @recapDonationsOnly.
  ///
  /// In fr, this message translates to:
  /// **'{amount} versés'**
  String recapDonationsOnly(String amount);

  /// No description provided for @recapEmpty.
  ///
  /// In fr, this message translates to:
  /// **'Aucune course terminée en {year}.'**
  String recapEmpty(int year);

  /// No description provided for @recapBanner.
  ///
  /// In fr, this message translates to:
  /// **'Ton bilan {year} est prêt'**
  String recapBanner(int year);

  /// No description provided for @recapBannerHint.
  ///
  /// In fr, this message translates to:
  /// **'Une image à partager : kilomètres, courses, records et dons.'**
  String get recapBannerHint;

  /// No description provided for @recapBannerOpen.
  ///
  /// In fr, this message translates to:
  /// **'Voir'**
  String get recapBannerOpen;

  /// No description provided for @settingsLanguage.
  ///
  /// In fr, this message translates to:
  /// **'Langue'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In fr, this message translates to:
  /// **'Système'**
  String get languageSystem;

  /// No description provided for @formImportFile.
  ///
  /// In fr, this message translates to:
  /// **'Importer un fichier de montre (GPX ou FIT)'**
  String get formImportFile;

  /// No description provided for @formFitImported.
  ///
  /// In fr, this message translates to:
  /// **'Fichier importé : {summary}.'**
  String formFitImported(String summary);

  /// No description provided for @formFitError.
  ///
  /// In fr, this message translates to:
  /// **'Ce fichier FIT est illisible.'**
  String get formFitError;

  /// No description provided for @formFitUnknown.
  ///
  /// In fr, this message translates to:
  /// **'Enchaînement non reconnu : seules les disciplines d\'un triathlon, d\'un duathlon ou d\'un aquathlon sont importées. Saisis les temps à la main.'**
  String get formFitUnknown;

  /// No description provided for @editionsTitle.
  ///
  /// In fr, this message translates to:
  /// **'Éditions précédentes'**
  String get editionsTitle;

  /// No description provided for @editionsFaster.
  ///
  /// In fr, this message translates to:
  /// **'{time} de mieux qu\'en {year}'**
  String editionsFaster(String time, int year);

  /// No description provided for @editionsSlower.
  ///
  /// In fr, this message translates to:
  /// **'{time} de plus qu\'en {year}'**
  String editionsSlower(String time, int year);

  /// No description provided for @editionsSame.
  ///
  /// In fr, this message translates to:
  /// **'Même temps qu\'en {year}'**
  String editionsSame(int year);

  /// No description provided for @editionsHint.
  ///
  /// In fr, this message translates to:
  /// **'Courses du même nom et de distance voisine.'**
  String get editionsHint;

  /// No description provided for @calendarAdd.
  ///
  /// In fr, this message translates to:
  /// **'Ajouter à l\'agenda'**
  String get calendarAdd;

  /// No description provided for @calendarExportAll.
  ///
  /// In fr, this message translates to:
  /// **'Courses à venir vers l\'agenda (.ics)'**
  String get calendarExportAll;

  /// No description provided for @calendarSaved.
  ///
  /// In fr, this message translates to:
  /// **'Fichier d\'agenda enregistré : ouvre-le pour ajouter les courses.'**
  String get calendarSaved;

  /// No description provided for @calendarTarget.
  ///
  /// In fr, this message translates to:
  /// **'Temps visé : {time}'**
  String calendarTarget(String time);

  /// No description provided for @resultRanking.
  ///
  /// In fr, this message translates to:
  /// **'Classement (facultatif)'**
  String get resultRanking;

  /// No description provided for @setupCodeLabel.
  ///
  /// In fr, this message translates to:
  /// **'Code d\'installation'**
  String get setupCodeLabel;

  /// No description provided for @setupCodeHint.
  ///
  /// In fr, this message translates to:
  /// **'Dans le dossier « donnees » du serveur : fichier code-premier-compte.txt.'**
  String get setupCodeHint;

  /// No description provided for @setupCodeMissing.
  ///
  /// In fr, this message translates to:
  /// **'Saisis le code d\'installation du serveur.'**
  String get setupCodeMissing;

  /// No description provided for @setupCodeWrong.
  ///
  /// In fr, this message translates to:
  /// **'Code d\'installation incorrect. Il est dans le fichier code-premier-compte.txt du dossier « donnees ».'**
  String get setupCodeWrong;

  /// No description provided for @signOutOthers.
  ///
  /// In fr, this message translates to:
  /// **'Déconnecter mes autres appareils'**
  String get signOutOthers;

  /// No description provided for @signOutOthersBody.
  ///
  /// In fr, this message translates to:
  /// **'Tes autres téléphones et ordinateurs devront se reconnecter avec ton mot de passe. Cet appareil reste connecté.'**
  String get signOutOthersBody;

  /// No description provided for @signOutOthersDone.
  ///
  /// In fr, this message translates to:
  /// **'Tes autres appareils sont déconnectés.'**
  String get signOutOthersDone;

  /// No description provided for @signOutOthersFailed.
  ///
  /// In fr, this message translates to:
  /// **'Impossible pour le moment. Vérifie la connexion, ou mets le serveur à jour.'**
  String get signOutOthersFailed;

  /// No description provided for @serverOnline.
  ///
  /// In fr, this message translates to:
  /// **'Serveur en ligne (Supabase)'**
  String get serverOnline;

  /// No description provided for @serverOnlineHint.
  ///
  /// In fr, this message translates to:
  /// **'Ton propre projet Supabase'**
  String get serverOnlineHint;

  /// No description provided for @serverOnlineKey.
  ///
  /// In fr, this message translates to:
  /// **'Clé publique'**
  String get serverOnlineKey;

  /// No description provided for @serverOnlineKeyHelp.
  ///
  /// In fr, this message translates to:
  /// **'Dans Supabase : Project Settings > API Keys, la clé « publishable » (ou « anon »). Jamais la clé secrète.'**
  String get serverOnlineKeyHelp;

  /// No description provided for @serverOnlineAddressHint.
  ///
  /// In fr, this message translates to:
  /// **'https://ton-projet.supabase.co'**
  String get serverOnlineAddressHint;

  /// No description provided for @serverErrorKey.
  ///
  /// In fr, this message translates to:
  /// **'Colle la clé publique du projet : elle commence par sb_publishable_ (ou eyJ pour l\'ancienne clé « anon »).'**
  String get serverErrorKey;

  /// No description provided for @serverErrorSecretKey.
  ///
  /// In fr, this message translates to:
  /// **'C\'est une clé secrète : elle ouvrirait tous les comptes du projet. Colle la clé publique (publishable ou anon).'**
  String get serverErrorSecretKey;

  /// No description provided for @serverBadKey.
  ///
  /// In fr, this message translates to:
  /// **'Le serveur refuse cette clé. Vérifie la clé publique dans Supabase.'**
  String get serverBadKey;

  /// No description provided for @serverNotSupabase.
  ///
  /// In fr, this message translates to:
  /// **'Cette adresse répond, mais ce n\'est pas un projet Supabase.'**
  String get serverNotSupabase;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
