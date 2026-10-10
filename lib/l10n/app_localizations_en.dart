// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ÉLAN';

  @override
  String get appTagline => 'Sport & Impact';

  @override
  String get signInTitle => 'Sign in';

  @override
  String get signInIntro => 'Sign in with the account created for you on ÉLAN.';

  @override
  String get emailLabel => 'Email address';

  @override
  String get passwordLabel => 'Password';

  @override
  String get signInButton => 'Sign in';

  @override
  String get signInInvalidEmail => 'Invalid email address.';

  @override
  String get signInMissingPassword => 'Enter your password.';

  @override
  String get signInWrongCredentials => 'Wrong email or password.';

  @override
  String get signInRateLimited => 'Too many attempts. Wait a minute before trying again.';

  @override
  String get signInOffline => 'Cannot reach the server. Check your connection.';

  @override
  String get signInForgotten => 'Forgot your password? Ask the ÉLAN administrator to reset it.';

  @override
  String get navCourses => 'Races';

  @override
  String get navImpact => 'Impact';

  @override
  String get navEvolution => 'Progress';

  @override
  String get navRecords => 'Records';

  @override
  String get navSettings => 'Settings';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get typeOfficial => 'Official race';

  @override
  String get typeConqueror => 'The Conqueror challenge';

  @override
  String get statusUpcoming => 'Upcoming';

  @override
  String get statusAwaiting => 'Result to enter';

  @override
  String get statusAwaitingShort => 'To enter';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get causeSante => 'Health & research';

  @override
  String get causeEnvironnement => 'Environment & climate';

  @override
  String get causePrecarite => 'Poverty & hunger';

  @override
  String get causeEnfance => 'Children & education';

  @override
  String get causeAnimaux => 'Animal protection';

  @override
  String get causeHandicap => 'Disability & inclusion';

  @override
  String get causeAutre => 'Other cause';

  @override
  String get metricTrees => 'Trees planted';

  @override
  String get metricOceanBottles => 'Plastic bottles removed';

  @override
  String get metricCareSessions => 'Care sessions';

  @override
  String get metricResearchHours => 'Research hours';

  @override
  String get metricMeals => 'Meals served';

  @override
  String get metricCareKits => 'Care kits';

  @override
  String get metricAnimalMeals => 'Meals for animals';

  @override
  String get metricNone => 'No equivalence';

  @override
  String get distance5k => '5 km';

  @override
  String get distance10k => '10 km';

  @override
  String get distanceHalf => 'Half marathon';

  @override
  String get distanceMarathon => 'Marathon';

  @override
  String get statDistance => 'Distance';

  @override
  String get statDonations => 'Funds raised';

  @override
  String get statRaces => 'Races';

  @override
  String get statTime => 'Race time';

  @override
  String get statElevation => 'Elevation +';

  @override
  String get statPace => 'Average pace';

  @override
  String get coursesEmpty => 'No race yet. Add your first race or register an upcoming one.';

  @override
  String get coursesNoMatch => 'No race matches.';

  @override
  String get coursesAdd => 'New race';

  @override
  String get coursesSearch => 'Search a race, a charity…';

  @override
  String get filterAll => 'All';

  @override
  String get filterCharity => 'Charity';

  @override
  String get kindAll => 'All';

  @override
  String get kindOfficial => 'Official';

  @override
  String get kindChallenge => 'Virtual';

  @override
  String get filterReset => 'Clear filters';

  @override
  String get filterSolidarity => 'Charity side';

  @override
  String get filterSolidarityAll => 'Charity or not';

  @override
  String get filterSolidarityOnly => 'Charity only';

  @override
  String summaryCourses(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count races',
      one: '1 race',
      zero: 'No race',
    );
    return '$_temp0';
  }

  @override
  String summaryOfficial(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count official races',
      one: '1 official race',
      zero: 'No official race',
    );
    return '$_temp0';
  }

  @override
  String summaryChallenges(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count challenges',
      one: '1 challenge',
      zero: 'No challenge',
    );
    return '$_temp0';
  }

  @override
  String summarySolidarity(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'for charity', one: 'for charity');
    return '$_temp0';
  }

  @override
  String get sectionAwaiting => 'Result to enter';

  @override
  String get sectionUpcoming => 'Upcoming';

  @override
  String get sectionDone => 'Completed';

  @override
  String sectionSummary(int count, String distance) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count races', one: '1 race');
    return '$_temp0 · $distance';
  }

  @override
  String get filterCause => 'Cause';

  @override
  String get sortRaceDate => 'Race date';

  @override
  String get sortAddedDate => 'Date added';

  @override
  String get sortTooltip => 'Sort';

  @override
  String get sortAscending => 'Oldest first';

  @override
  String get sortDescending => 'Newest first';

  @override
  String awaitingBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count races are waiting for your result',
      one: '1 race is waiting for your result',
    );
    return '$_temp0';
  }

  @override
  String get recordBadge => 'Record';

  @override
  String get nextRace => 'Next race';

  @override
  String get last12Months => 'Kilometres over the last 12 months';

  @override
  String get formNewTitle => 'New race';

  @override
  String get formEditTitle => 'Edit race';

  @override
  String get formPlanned => 'Upcoming race';

  @override
  String get formPlannedHint => 'Register it now, you will enter your time after the race.';

  @override
  String get formName => 'Race name';

  @override
  String get formDate => 'Date';

  @override
  String get formDistance => 'Distance (km)';

  @override
  String get formDuration => 'Time (h:mm:ss)';

  @override
  String get formElevation => 'Elevation gain (m)';

  @override
  String get formImportGpx => 'Import a GPX file';

  @override
  String formGpxImported(String distance, String duration) {
    return 'Track imported: $distance, $duration.';
  }

  @override
  String get formGpxError => 'This GPX file cannot be read.';

  @override
  String get formTeam => 'Team challenge';

  @override
  String get formChallengeDistance => 'Total challenge distance (km)';

  @override
  String get formTeamSize => 'Number of members';

  @override
  String formPersonalShare(String distance) {
    return 'Your share: $distance';
  }

  @override
  String get formCharity => 'Charity race';

  @override
  String get formCharityHint => 'Linked to a charity and to donations.';

  @override
  String get formAssociation => 'Charity';

  @override
  String get formChooseAssociation => 'Choose a charity';

  @override
  String get formSponsor => 'Sponsorship (€ per km)';

  @override
  String get formRegistration => 'Donation in the entry fee (€)';

  @override
  String get formFundraising => 'Fundraising (€)';

  @override
  String formDonationTotal(String amount) {
    return 'Total raised: $amount';
  }

  @override
  String get formImpact => 'Equivalence announced by the organiser';

  @override
  String get formImpactHint => 'Optional. Only if the organiser announces it (e.g. 4 trees planted).';

  @override
  String get formImpactUnit => 'Unit';

  @override
  String get formImpactQuantity => 'Quantity';

  @override
  String get formPhotos => 'Keepsakes';

  @override
  String get formMedal => 'Medal';

  @override
  String get formBib => 'Bib';

  @override
  String get formAddPhoto => 'Add a photo';

  @override
  String get formNotes => 'Notes';

  @override
  String get issueMissingTitle => 'Give the race a name.';

  @override
  String get issueDistance => 'The distance must be greater than 0.';

  @override
  String get issueNegative => 'A negative value is not possible.';

  @override
  String get issueCompletedInFuture => 'This date is in the future: tick “Upcoming race”.';

  @override
  String get issuePlannedWithResult => 'An upcoming race has no time yet.';

  @override
  String get issueTeamSize => 'Invalid number of members.';

  @override
  String get issueImpactQuantity => 'The quantity must be positive.';

  @override
  String issueImpactCap(String max) {
    return 'Above the announced cap ($max maximum).';
  }

  @override
  String get issueInvalidNumber => 'Invalid number.';

  @override
  String get issueInvalidDuration => 'Expected format: h:mm:ss';

  @override
  String get assoSearchHint => 'Charity name';

  @override
  String get assoCatalog => 'Common charities';

  @override
  String get assoOfficial => 'Official register';

  @override
  String get assoSearching => 'Searching the official register…';

  @override
  String get assoSearchOffline => 'Online search unavailable. Choose from the list or type the name.';

  @override
  String assoFree(String name) {
    return 'Use “$name”';
  }

  @override
  String get assoCause => 'Cause supported';

  @override
  String get assoNoResult => 'No result.';

  @override
  String get detailNotFound => 'This race no longer exists.';

  @override
  String get detailPerformance => 'Performance';

  @override
  String get detailTime => 'Time';

  @override
  String get detailPace => 'Pace';

  @override
  String get detailSpeed => 'Speed';

  @override
  String get detailUpcomingInfo => 'Race planned. You can enter your result from race day.';

  @override
  String get detailAwaitingInfo => 'The race has taken place: enter your time to add it to your totals and records.';

  @override
  String get detailEnterResult => 'Enter my result';

  @override
  String detailTeam(int count, String distance) {
    return 'Team of $count · $distance challenge';
  }

  @override
  String get detailSolidarity => 'Charity side';

  @override
  String get detailSponsor => 'Sponsorship';

  @override
  String get detailRegistration => 'Entry fee';

  @override
  String get detailFundraising => 'Fundraising';

  @override
  String get detailDonationTotal => 'Total raised';

  @override
  String get detailDeclaredImpact => 'Announced impact';

  @override
  String get deleteCourseTitle => 'Delete this race?';

  @override
  String get deleteCourseBody => 'It will be deleted on all your devices.';

  @override
  String get resultTitle => 'My result';

  @override
  String get shareTitle => 'Share the race';

  @override
  String get shareSave => 'Save the image';

  @override
  String get shareShare => 'Share';

  @override
  String get shareSaved => 'Image saved.';

  @override
  String shareFor(String association) {
    return 'for $association';
  }

  @override
  String get impactTitle => 'My impact';

  @override
  String get impactHonesty => 'Only money actually raised and equivalences announced by organisers are counted.';

  @override
  String impactCharityRaces(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count charity races',
      one: '1 charity race',
      zero: 'No charity race',
    );
    return '$_temp0';
  }

  @override
  String impactCharityDistance(String distance) {
    return '$distance run for a cause';
  }

  @override
  String get impactDeclared => 'Announced impact';

  @override
  String impactKmFor(String cause) {
    return 'Run for $cause';
  }

  @override
  String get reportTitle => 'Commitment report';

  @override
  String get reportAction => 'Prepare a summary for a report';

  @override
  String get reportPresetSchool => 'School year';

  @override
  String reportPresetYear(int year) {
    return 'Year $year';
  }

  @override
  String get reportPresetLast12 => 'Last 12 months';

  @override
  String get reportPresetCustom => 'Custom dates';

  @override
  String reportFrom(String date) {
    return 'From $date';
  }

  @override
  String reportTo(String date) {
    return 'To $date';
  }

  @override
  String get reportCharityOnly => 'Charity races only';

  @override
  String get reportTextTitle => 'Text for your report';

  @override
  String get reportCopyText => 'Copy the text';

  @override
  String get reportCopyTable => 'Copy the table';

  @override
  String get reportCopied => 'Text copied: paste it into your report.';

  @override
  String get reportTableCopied => 'Table copied: paste it into Word or Excel.';

  @override
  String get reportImageTitle => 'Summary image';

  @override
  String get reportEmpty => 'No completed race over this period.';

  @override
  String reportHeading(String from, String to) {
    return 'ÉLAN summary from $from to $to';
  }

  @override
  String get reportSectionSolidarity => 'CHARITY COMMITMENT';

  @override
  String reportCharityLine(int count, String distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count charity races, that is $distance run for causes.',
      one: '1 charity race, that is $distance run for a cause.',
    );
    return '$_temp0';
  }

  @override
  String reportDonationLine(String amount) {
    return '$amount raised (donations, sponsorships and fundraising).';
  }

  @override
  String reportDeclaredLine(String list) {
    return 'Impact announced by the organisers: $list.';
  }

  @override
  String reportCausesLine(String list) {
    return 'Causes supported: $list.';
  }

  @override
  String reportAssociationsLine(String list) {
    return 'Charities supported: $list.';
  }

  @override
  String get reportNoCharity => 'No charity race over the period.';

  @override
  String get reportSectionCourses => 'RACE DETAILS';

  @override
  String get reportSectionSport => 'SPORTING ACTIVITY';

  @override
  String reportSportLine(int count, String distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count races completed',
      one: '1 race completed',
    );
    return '$_temp0, $distance in total.';
  }

  @override
  String reportTimeLine(String time) {
    return 'Race time: $time.';
  }

  @override
  String reportElevationLine(String elevation) {
    return 'Elevation gain: $elevation.';
  }

  @override
  String reportPeriod(String from, String to) {
    return 'From $from to $to';
  }

  @override
  String get reportAnd => 'and';

  @override
  String get reportStyleProse => 'Written';

  @override
  String get reportStyleBullets => 'Key points';

  @override
  String get reportExcel => 'Excel file';

  @override
  String get reportTotal => 'Total';

  @override
  String get reportSheetName => 'Summary';

  @override
  String reportSheetSubtitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count races', one: '1 race');
    return 'Generated by ÉLAN · $_temp0';
  }

  @override
  String get fileSaved => 'File saved.';

  @override
  String get datePickerToday => 'Today';

  @override
  String reportProseIntro(int count, String from, String to, String distance) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count races', one: 'one race');
    return 'From $from to $to, I took part in $_temp0, covering $distance in total.';
  }

  @override
  String get reportProseNoCharity => 'None of these races was for charity.';

  @override
  String reportProseAllCharity(int count, String distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'All of them were charity races',
      one: 'It was a charity race',
    );
    return '$_temp0, that is $distance run for causes.';
  }

  @override
  String reportProseCharity(int count, String distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count of them were charity races',
      one: 'One of them was a charity race',
    );
    return '$_temp0, that is $distance run for causes.';
  }

  @override
  String reportProseChallenges(int count, String distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'This total includes $count long-running challenges (The Conqueror), which account for $distance on their own.',
      one: 'This total includes one long-running challenge (The Conqueror), which accounts for $distance on its own.',
    );
    return '$_temp0';
  }

  @override
  String reportProseDonations(String amount) {
    return 'These races raised $amount for charities (donations, sponsorships and fundraising).';
  }

  @override
  String reportProseDonationsCauses(String amount, String causes) {
    return 'These races raised $amount for charities (donations, sponsorships and fundraising), in particular for $causes.';
  }

  @override
  String reportProseDeclared(String list) {
    return 'The organisers also announce a concrete impact: $list.';
  }

  @override
  String reportProseAssociations(int count, String list) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'The charities supported are $list.',
      one: 'The charity supported is $list.',
    );
    return '$_temp0';
  }

  @override
  String reportProseRaces(String list) {
    return 'Charity races: $list.';
  }

  @override
  String reportProseSport(String parts) {
    return 'On the sporting side, this represents $parts.';
  }

  @override
  String reportProseTime(String time) {
    return '$time of racing';
  }

  @override
  String reportProseElevation(String elevation) {
    return '$elevation of elevation gain';
  }

  @override
  String reportProsePace(String pace) {
    return 'an average pace of $pace';
  }

  @override
  String reportPaceLine(String pace) {
    return 'Average pace: $pace.';
  }

  @override
  String get reportChallengeTag => 'challenge';

  @override
  String reportDistanceTime(String distance, String time) {
    return '$distance in $time';
  }

  @override
  String get reportTableHeader =>
      'Date\tRace\tType\tDistance (km)\tTime\tPace (min/km)\tElev. + (m)\tCharity\tCause\tFunds raised (€)\tAnnounced impact';

  @override
  String get reportWordHeader => 'Date\tRace\tDistance and time\tCharity and cause\tFunds raised\tAnnounced impact';

  @override
  String get reportCopyForWord => 'For Word (compact table)';

  @override
  String get reportCopyForExcel => 'For Excel (all columns)';

  @override
  String get reportCardTitle => 'Commitment report';

  @override
  String reportCardFor(String list) {
    return 'For $list';
  }

  @override
  String get impactCharityDistanceLabel => 'Charity distance';

  @override
  String get impactByCause => 'By cause';

  @override
  String get impactAssociations => 'Charities supported';

  @override
  String get impactByYear => 'Funds raised per year';

  @override
  String get impactByYearHint => 'Donations, sponsorships and fundraising of completed charity races.';

  @override
  String get legendDonations => 'Funds raised (€)';

  @override
  String get impactEmpty => 'No completed charity race yet.';

  @override
  String get docTitle => 'Supporting documents';

  @override
  String get docAdd => 'Add a document';

  @override
  String docAdded(String course) {
    return 'Document added to “$course”.';
  }

  @override
  String get docTooBig => 'File too large: 10 MB maximum.';

  @override
  String get docUnavailable => 'Document unavailable for now: check your connection.';

  @override
  String get docRemoveTitle => 'Remove this document?';

  @override
  String docRemoveBody(String name) {
    return '“$name” will be deleted on all your devices.';
  }

  @override
  String docAddedOn(String date) {
    return 'added on $date';
  }

  @override
  String get docActions => 'Actions';

  @override
  String get docOpen => 'Open';

  @override
  String get docSave => 'Save';

  @override
  String get docRemove => 'Remove';

  @override
  String get docEmptyCourse => 'No document. Add the entry invoice or the donation receipt (PDF or photo).';

  @override
  String get docZip => 'Export all (ZIP)';

  @override
  String docZipMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unavailable documents were left out (offline?).',
      one: '1 unavailable document was left out (offline?).',
    );
    return '$_temp0';
  }

  @override
  String get docAllDates => 'All dates';

  @override
  String get docSearch => 'Search a race, a charity, a file…';

  @override
  String docCount(int count, int courses) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count documents', one: '1 document');
    String _temp1 = intl.Intl.pluralLogic(courses, locale: localeName, other: '$courses races', one: '1 race');
    return '$_temp0 · $_temp1';
  }

  @override
  String get docEmpty => 'No document yet. Add them from a race page or with the button below.';

  @override
  String get docNoMatch => 'No document over this period.';

  @override
  String get docChooseCourse => 'Attach to which race?';

  @override
  String get docKindConfirmation => 'Confirmation email';

  @override
  String get docKindInvoice => 'Invoice';

  @override
  String get docKindReceipt => 'Donation receipt';

  @override
  String get docKindResult => 'Race result';

  @override
  String get docKindOther => 'Other document';

  @override
  String get docChooseKind => 'What kind of document?';

  @override
  String get docChangeKind => 'Change the type';

  @override
  String get reportDocsZip => 'Documents (ZIP)';

  @override
  String get assoTitle => 'Charity';

  @override
  String get assoNotFound => 'No completed charity race for this charity.';

  @override
  String get assoCourses => 'Races for this charity';

  @override
  String get assoExport => 'Summary to share';

  @override
  String get assoCardTitle => 'Summary';

  @override
  String assoRecapTitle(String name) {
    return 'ÉLAN summary: $name';
  }

  @override
  String assoRecapLine(int count, String from, String to, String distance) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count charity races',
      one: '1 charity race',
    );
    return '$_temp0 from $from to $to, that is $distance run for the charity.';
  }

  @override
  String assoRecapLineOne(String date, String distance) {
    return '1 charity race on $date, that is $distance run for the charity.';
  }

  @override
  String assoCauses(int count, String list) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: 'Causes supported', one: 'Cause supported');
    return '$_temp0: $list.';
  }

  @override
  String assoOpen(String name) {
    return 'See the summary for $name';
  }

  @override
  String docCountShort(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count documents', one: '1 document');
    return '$_temp0';
  }

  @override
  String get evolutionTitle => 'Progress';

  @override
  String get rangeLast12 => 'Last 12 months';

  @override
  String get rangeLast12Short => '12 months';

  @override
  String get rangeByMonth => 'By month';

  @override
  String get rangeByYear => 'By year';

  @override
  String get summaryLast12 => 'Over the last 12 months';

  @override
  String summaryYear(int year) {
    return 'In $year';
  }

  @override
  String summaryAll(int year) {
    return 'Since $year';
  }

  @override
  String get compareLast12 => 'Arrows: change from the previous 12 months.';

  @override
  String compareYearToDate(int year, String date) {
    return 'Arrows: change from $year at the same date ($date).';
  }

  @override
  String compareYear(int year) {
    return 'Arrows: change from $year.';
  }

  @override
  String get deltaNew => 'new';

  @override
  String get periodEmpty => 'No completed race over this period.';

  @override
  String periodCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count races',
      one: '1 race',
      zero: 'no race',
    );
    return '$_temp0';
  }

  @override
  String get chartKmByMonth => 'Kilometres per month';

  @override
  String get chartKmByYear => 'Kilometres per year';

  @override
  String get chartKmHint => 'Distance of completed races. Tap a bar to see its races.';

  @override
  String get legendDistance => 'Distance run (km)';

  @override
  String chartCumulativeTitle(int year) {
    return 'Running total for $year';
  }

  @override
  String get chartCumulativeHint =>
      'Kilometres accumulated since 1 January, compared with the previous year. Each step is a race.';

  @override
  String cumulativeAt(String date) {
    return 'as of $date';
  }

  @override
  String get cumulativeYear => 'over the year';

  @override
  String get chartPaceTitle => 'Pace of each official race';

  @override
  String get legendPace => 'A timed race';

  @override
  String get viewChart => 'Chart';

  @override
  String get viewTable => 'Table';

  @override
  String get chartPaceHint => 'In minutes per kilometre. The higher the dot, the faster you ran.';

  @override
  String get chartEmpty => 'Not enough completed races yet to plot your progress.';

  @override
  String get tablePeriod => 'Period';

  @override
  String get tableRaces => 'Races';

  @override
  String get recordsTitle => 'Records';

  @override
  String get recordsEmpty => 'Complete at least one timed race to see your records.';

  @override
  String get recordsByDistance => 'Best times';

  @override
  String get recordsLongest => 'Longest distances';

  @override
  String get recordsElevation => 'Biggest climbs';

  @override
  String get recordsAllTime => 'All time';

  @override
  String recordsEmptyYear(int year) {
    return 'No timed race in $year.';
  }

  @override
  String get galleryTitle => 'Medals and bibs';

  @override
  String get galleryAll => 'All';

  @override
  String get galleryMedals => 'Medals';

  @override
  String get galleryBibs => 'Bibs';

  @override
  String get galleryEmpty => 'No photo yet. Add the medal or the bib in a race form.';

  @override
  String galleryCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count photos', one: '1 photo');
    return '$_temp0';
  }

  @override
  String get settingsAccount => 'Account';

  @override
  String settingsSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get settingsChangePassword => 'Change password';

  @override
  String get settingsNewPassword => 'New password';

  @override
  String get settingsPasswordTooShort => '8 characters minimum.';

  @override
  String get settingsPasswordChanged => 'Password changed.';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsSignOutTitle => 'Sign out?';

  @override
  String settingsSignOutPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count changes have not been sent yet. They stay on this device and will be sent the next time you sign in.',
      one: '1 change has not been sent yet. It stays on this device and will be sent the next time you sign in.',
    );
    return '$_temp0';
  }

  @override
  String get settingsSignOutClean => 'Your races stay in the cloud and on this device.';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get backupSection => 'Backup';

  @override
  String get backupHint =>
      'A copy of all your races (every column), independent of the cloud, to keep wherever you like.';

  @override
  String get backupExcel => 'Export to Excel';

  @override
  String get backupCsv => 'Export to CSV';

  @override
  String backupTitle(String date) {
    return 'ÉLAN backup of $date';
  }

  @override
  String get backupSheetName => 'Races';

  @override
  String get backupDate => 'Date';

  @override
  String get backupCourse => 'Race';

  @override
  String get backupType => 'Type';

  @override
  String get backupStatus => 'Status';

  @override
  String get backupDistance => 'Distance (km)';

  @override
  String get backupTime => 'Time';

  @override
  String get backupPace => 'Pace (min/km)';

  @override
  String get backupElevation => 'Elev. + (m)';

  @override
  String get backupTeam => 'Team (members)';

  @override
  String get backupChallenge => 'Challenge distance (km)';

  @override
  String get backupCharity => 'Charity';

  @override
  String get backupAssociation => 'Charity name';

  @override
  String get backupCause => 'Cause';

  @override
  String get backupSponsor => 'Sponsorship (€/km)';

  @override
  String get backupRegistration => 'Donation in entry fee (€)';

  @override
  String get backupFundraising => 'Fundraising (€)';

  @override
  String get backupTotal => 'Total raised (€)';

  @override
  String get backupMetric => 'Announced equivalence';

  @override
  String get backupQuantity => 'Quantity';

  @override
  String get backupDocuments => 'Documents';

  @override
  String get backupNotes => 'Notes';

  @override
  String get backupCreated => 'Added on';

  @override
  String get backupUpdated => 'Changed on';

  @override
  String get backupYes => 'Yes';

  @override
  String get backupNo => 'No';

  @override
  String get reminderSetting => 'Reminder on race evening';

  @override
  String reminderSettingHint(String time) {
    return 'A notification at $time on race day to enter your time.';
  }

  @override
  String get reminderTime => 'Reminder time';

  @override
  String reminderTitle(String title) {
    return 'Your race: $title';
  }

  @override
  String get reminderBody => 'Enter your time to add it to your totals and records.';

  @override
  String get settingsWallpaperColors => 'Wallpaper colours';

  @override
  String get settingsWallpaperColorsHint =>
      'Material You: the app takes your phone\'s colours. Turn off to keep the ÉLAN colours.';

  @override
  String get syncTitle => 'Sync';

  @override
  String get syncNow => 'Sync now';

  @override
  String get syncUpToDate => 'Everything is synced';

  @override
  String get syncRunning => 'Sync in progress';

  @override
  String syncPending(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count changes pending',
      one: '1 change pending',
    );
    return '$_temp0';
  }

  @override
  String get syncFailed => 'Sync failed';

  @override
  String syncLast(String date) {
    return 'Last sync: $date';
  }

  @override
  String syncImported(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count races imported from the old version.',
      one: '1 race imported from the old version.',
    );
    return '$_temp0';
  }

  @override
  String get serverTitle => 'Server';

  @override
  String get serverIntro =>
      'ÉLAN stores your races on a server. By default it is the ÉLAN one; you can also use your own server, for example installed on a NAS.';

  @override
  String get serverIntroCustomOnly => 'Enter the server where ÉLAN stores your races, for example installed on a NAS.';

  @override
  String get serverBuiltIn => 'ÉLAN server';

  @override
  String get serverBuiltInHint => 'Default';

  @override
  String get serverCustom => 'My server';

  @override
  String get serverCustomHint => 'Installed at home, for example on a NAS';

  @override
  String get serverAddress => 'Server address';

  @override
  String get serverAddressHint => 'http://192.168.1.20:8000';

  @override
  String get serverPaste => 'Paste';

  @override
  String get serverSave => 'Check and save';

  @override
  String get serverChecking => 'Checking the server…';

  @override
  String get serverErrorAddress => 'Invalid address. Example: http://192.168.1.20:8000';

  @override
  String get serverErrorHttp =>
      'On the Internet, the address must start with https:// (over http, the password would travel unencrypted). http is only accepted on the local network or the VPN.';

  @override
  String get serverUnreachable =>
      'Server unreachable. Check the address, that the VPN is on and that the server is running.';

  @override
  String serverLabel(String name) {
    return 'Server: $name';
  }

  @override
  String get autoBackupTitle => 'Automatic backup';

  @override
  String get autoBackupHint =>
      'Every week, a copy of the races (Excel) and of the photos and documents in a folder of your choice: Proton Drive, external drive… The last 8 Excel copies are kept.';

  @override
  String get autoBackupEnable => 'Back up every week';

  @override
  String autoBackupFolder(String path) {
    return 'Folder: $path';
  }

  @override
  String get autoBackupNoFolder => 'No folder chosen';

  @override
  String get autoBackupChoose => 'Choose the folder';

  @override
  String get autoBackupNow => 'Back up now';

  @override
  String autoBackupLast(String date) {
    return 'Last backup: $date';
  }

  @override
  String get autoBackupNever => 'No backup yet';

  @override
  String get autoBackupRunning => 'Backup in progress…';

  @override
  String autoBackupCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new files copied',
      one: '1 new file copied',
      zero: 'No new file',
    );
    return '$_temp0';
  }

  @override
  String autoBackupMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count files not found for now, retried next time',
      one: '1 file not found for now, retried next time',
    );
    return '$_temp0';
  }

  @override
  String autoBackupError(String error) {
    return 'Backup failed: $error';
  }

  @override
  String get gpxBatchAction => 'Import GPX files';

  @override
  String get gpxBatchTitle => 'GPX import';

  @override
  String gpxBatchDefaultTitle(String date) {
    return 'Race of $date';
  }

  @override
  String gpxBatchCreated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count races added.',
      one: '1 race added.',
      zero: 'No race added.',
    );
    return '$_temp0';
  }

  @override
  String gpxBatchDuplicates(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks already present, skipped.',
      one: '1 track already present, skipped.',
    );
    return '$_temp0';
  }

  @override
  String gpxBatchUndated(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tracks without a date, skipped.',
      one: '1 track without a date, skipped.',
    );
    return '$_temp0';
  }

  @override
  String gpxBatchUnreadable(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count unreadable files.',
      one: '1 unreadable file.',
    );
    return '$_temp0';
  }

  @override
  String get gpxBatchHint => 'They are filed as official races: open them to complete the title, the charity…';

  @override
  String updateAvailable(String version) {
    return 'ÉLAN $version is available.';
  }

  @override
  String get updateDownload => 'Download';

  @override
  String get updateLater => 'Later';

  @override
  String get updateUpToDate => 'You have the latest version.';

  @override
  String get updateCheck => 'Check for updates';

  @override
  String get settingsAbout => 'About';

  @override
  String settingsVersion(String version) {
    return 'ÉLAN $version';
  }

  @override
  String get signInShowPassword => 'Show password';

  @override
  String get signInHidePassword => 'Hide password';

  @override
  String get signInForgottenCustom =>
      'Forgot your password? The server owner can give you a new one, in Settings > Server accounts.';

  @override
  String get serverAddressHelp => 'It is the address shown on your server\'s home page (“Copy the address” button).';

  @override
  String get serverNotElan => 'This address answers, but it is not an ÉLAN server. Check the port (8000 by default).';

  @override
  String get serverTooRecent => 'This server is newer than the app. Update the app, then try again.';

  @override
  String get signInIntroCustom => 'Sign in with the account created for you on this server.';

  @override
  String get firstAccountTitle => 'First account';

  @override
  String get firstAccountIntro =>
      'This server is brand new. Create the first account: it will own the server and will be able to add accounts for family and friends.';

  @override
  String get firstAccountButton => 'Create my account';

  @override
  String get firstAccountTaken => 'This server already has an account. Sign in, or ask its owner for an account.';

  @override
  String get passwordConfirmLabel => 'Confirm password';

  @override
  String get passwordMismatch => 'The two passwords are different.';

  @override
  String get settingsCurrentPassword => 'Current password';

  @override
  String get settingsWrongCurrentPassword => 'Wrong current password.';

  @override
  String get accountsTitle => 'Server accounts';

  @override
  String get accountsIntro => 'Each person has their own account and only sees their own races.';

  @override
  String get accountsManage => 'Manage accounts';

  @override
  String get accountsOwner => 'Server owner';

  @override
  String get accountsYou => 'You';

  @override
  String get accountsAdd => 'Add an account';

  @override
  String get accountsAddIntro =>
      'Choose their email and a temporary password, then pass them on. The person can change their password in Settings.';

  @override
  String get accountsCreated => 'Account created.';

  @override
  String get accountsEmailTaken => 'An account already exists with this address.';

  @override
  String get accountsReset => 'Give a new password';

  @override
  String get accountsResetDone => 'Password replaced.';

  @override
  String get accountsDelete => 'Delete the account';

  @override
  String accountsDeleteConfirm(String email) {
    return 'Delete the account $email? Their races, photos and documents stored on the server will be erased permanently.';
  }

  @override
  String get accountsDeleted => 'Account deleted.';

  @override
  String get accountsError => 'Action failed. Check the connection to the server.';

  @override
  String accountsActions(String email) {
    return 'Actions for $email';
  }

  @override
  String get typeMultisport => 'Triathlon, duathlon, aquathlon';

  @override
  String get typeShortOfficial => 'Race';

  @override
  String get typeShortConqueror => 'Challenge';

  @override
  String get typeShortMultisport => 'Triathlon';

  @override
  String get kindMultisport => 'Triathlons';

  @override
  String get kindMultisportHint => 'Triathlons, duathlons and aquathlons';

  @override
  String get multisportTriathlon => 'Triathlon';

  @override
  String get multisportDuathlon => 'Duathlon';

  @override
  String get multisportAquathlon => 'Aquathlon';

  @override
  String get sportSwim => 'Swim';

  @override
  String get sportBike => 'Bike';

  @override
  String get sportRun => 'Run';

  @override
  String sportRunNumbered(int number) {
    return 'Run $number';
  }

  @override
  String get multisportFormat => 'Format';

  @override
  String get multisportFormatFree => 'Custom';

  @override
  String get multisportFormatHint => 'The format fills in the distances. Correct them if your event was different.';

  @override
  String get multisportLegDistance => 'Distance';

  @override
  String get multisportLegTime => 'Time';

  @override
  String multisportTransition(int number) {
    return 'Transition $number';
  }

  @override
  String get multisportTransitionsIncluded => 'Transitions counted in the disciplines';

  @override
  String get multisportTransitionsIncludedHint =>
      'Tick this if your timing does not isolate transitions: each one is then included in the time of the discipline before it.';

  @override
  String get multisportTotalTime => 'Total time';

  @override
  String multisportTotalComputed(String time) {
    return 'Leave empty: computed from the times above ($time).';
  }

  @override
  String get multisportTotalOnly => 'You can enter the total time only if you do not have the details.';

  @override
  String get multisportTransitionIncludedNote => 'transition included';

  @override
  String get multisportTransitions => 'Transitions';

  @override
  String get multisportBreakdown => 'Time breakdown';

  @override
  String multisportRunShare(String run) {
    return '$run of running counted in your kilometres run.';
  }

  @override
  String get multisportEditResult => 'Enter my times';

  @override
  String get issueLegDistance => 'Enter the distance of each discipline.';

  @override
  String get issueLegTimes => 'Enter the time of every discipline, or none (total time only).';

  @override
  String issueTotalBelowSplits(String time) {
    return 'The total time is lower than the sum of the disciplines ($time).';
  }

  @override
  String get recordsMultisport => 'Triathlons, duathlons, aquathlons';

  @override
  String get recordsMultisportBest => 'Best time';

  @override
  String get swimPaceUnit => '/100 m';

  @override
  String get shareMultisportTotal => 'Total time';

  @override
  String summaryMultisport(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count multisport events',
      one: '1 multisport event',
      zero: 'No multisport event',
    );
    return '$_temp0';
  }

  @override
  String get backupDisciplines => 'Disciplines (triathlon, duathlon, aquathlon)';

  @override
  String get evolutionSportsTitle => 'Triathlons: by discipline';

  @override
  String get evolutionSportsHint => 'Total distance and time of your triathlons, duathlons and aquathlons.';

  @override
  String get evolutionSportsEvents => 'Events';

  @override
  String get chartSportTitle => 'Pace by discipline in triathlon';

  @override
  String get chartSportHintSwim => 'In minutes per 100 m. The higher the dot, the faster you swam.';

  @override
  String get chartSportHintBike => 'In km/h. The higher the dot, the faster you rode.';

  @override
  String get chartSportHintRun => 'In minutes per kilometre. The higher the dot, the faster you ran.';

  @override
  String get chartSportNeedsTwo => 'Two timed events over the period are needed to plot this discipline.';

  @override
  String get legendSport => 'A timed event';

  @override
  String get recordsBySport => 'Best paces in triathlon';

  @override
  String get recordsBySportHint => 'By discipline, all formats together (triathlons, duathlons, aquathlons).';

  @override
  String get formTarget => 'Target time (optional)';

  @override
  String get formTargetHint => 'Your goal for this race. It stays shown afterwards, to compare.';

  @override
  String get formRanking => 'Ranking';

  @override
  String get formRankingHint => 'Optional. Copy what the results sheet says.';

  @override
  String get formRank => 'Place';

  @override
  String get formFinishers => 'Finishers';

  @override
  String get formCategoryRank => 'Place in category';

  @override
  String get formCategoryFinishers => 'Category finishers';

  @override
  String get formCategoryName => 'Category';

  @override
  String get formCategoryNameHint => 'M35, SEH…';

  @override
  String get issueRankAboveFinishers => 'The place cannot exceed the number of finishers.';

  @override
  String targetPlanned(String time) {
    return 'Target $time';
  }

  @override
  String targetBeaten(String time) {
    return 'Target beaten by $time';
  }

  @override
  String targetMissed(String time) {
    return 'Target missed by $time';
  }

  @override
  String get targetMet => 'Target met';

  @override
  String get rankingOverall => 'Overall';

  @override
  String get rankingCategory => 'Category';

  @override
  String rankingOf(String rank, String total) {
    return '$rank of $total';
  }

  @override
  String rankingTop(int percent) {
    return 'top $percent%';
  }

  @override
  String get ordinalFirst => '1st';

  @override
  String ordinalOther(int n) {
    return '${n}th';
  }

  @override
  String get chartRankTitle => 'Ranking of each race';

  @override
  String get chartRankHint => 'Share of finishers ranked ahead of you. The higher the dot, the better your ranking.';

  @override
  String get legendRank => 'A ranked race';

  @override
  String goalYearTitle(int year) {
    return '$year goal';
  }

  @override
  String get goalSet => 'Set a yearly goal';

  @override
  String get goalEdit => 'Edit the goal';

  @override
  String goalDialogField(int year) {
    return 'Kilometres to run in $year';
  }

  @override
  String get goalDialogHint => 'Leave empty to remove the goal. It is stored on this device.';

  @override
  String goalProgress(String done, String goal) {
    return '$done of $goal';
  }

  @override
  String goalAhead(String km) {
    return '$km ahead of the pace for the year.';
  }

  @override
  String goalBehind(String km) {
    return '$km behind the pace for the year.';
  }

  @override
  String get goalOnTrack => 'Right on pace for the year.';

  @override
  String get goalReached => 'Goal reached, well done!';

  @override
  String get backupTarget => 'Target time';

  @override
  String get backupRanking => 'Ranking';

  @override
  String get recapTitle => 'Year in review';

  @override
  String get recapAction => 'Year in review to share';

  @override
  String recapKicker(int year) {
    return '$year in review';
  }

  @override
  String get recapRun => 'run';

  @override
  String get recapRecords => 'Records';

  @override
  String get recapLongest => 'Longest race';

  @override
  String recapDonations(String amount, int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '$count charities', one: '1 charity');
    return '$amount for $_temp0';
  }

  @override
  String recapDonationsOnly(String amount) {
    return '$amount donated';
  }

  @override
  String recapEmpty(int year) {
    return 'No completed race in $year.';
  }

  @override
  String recapBanner(int year) {
    return 'Your $year review is ready';
  }

  @override
  String get recapBannerHint => 'An image to share: kilometres, races, records and donations.';

  @override
  String get recapBannerOpen => 'View';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get formImportFile => 'Import a watch file (GPX or FIT)';

  @override
  String formFitImported(String summary) {
    return 'File imported: $summary.';
  }

  @override
  String get formFitError => 'This FIT file cannot be read.';

  @override
  String get formFitUnknown =>
      'Unrecognised sequence: only the disciplines of a triathlon, duathlon or aquathlon are imported. Enter the times by hand.';
}
