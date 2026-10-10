import 'dart:convert';
import 'dart:typed_data';

import 'package:intl/intl.dart';

import '../../app/format.dart';
import '../../app/labels.dart';
import '../../core/export/xlsx.dart';
import '../../l10n/app_localizations.dart';
import '../courses/domain/course.dart';
import '../documents/presentation/document_widgets.dart';
import '../report/report_text.dart';

/// Sauvegarde de toutes les courses, indépendante du cloud : mêmes colonnes en CSV et en Excel.

/// Une colonne : en-tête, valeur pour Excel (cellule typée), valeur pour CSV (texte).
class _Column {
  final String header;
  final double width;
  final XCell Function(Course) cell;
  const _Column(this.header, this.width, this.cell);
}

List<_Column> _columns(AppLocalizations t, DateTime today) {
  XCell txt(String? v) => XCell.text(v ?? '');
  XCell number(num? v, XFormat f) => v == null ? XCell.empty(f) : XCell.number(v, f);
  XCell euros(int cents, bool show) => show ? XCell.number(cents / 100, XFormat.euro) : const XCell.empty(XFormat.euro);
  return [
    _Column(t.backupDate, 12, (c) => XCell.date(c.raceDate)),
    _Column(t.backupCourse, 32, (c) => txt(c.title)),
    _Column(t.backupType, 20, (c) => txt(c.typeLabel(t))),
    _Column(t.backupStatus, 16, (c) => txt(c.statusOn(today).label(t))),
    _Column(t.backupDistance, 13, (c) => XCell.number(c.distanceM / 1000, XFormat.km)),
    _Column(
      t.backupTime,
      10,
      (c) => c.hasTime ? XCell.text(formatDuration(c.durationS), center: true) : const XCell.empty(XFormat.center),
    ),
    _Column(
      t.backupPace,
      12,
      (c) => c.paceSecondsPerKm != null
          ? XCell.text(formatPace(c.paceSecondsPerKm).replaceAll(' /km', ''), center: true)
          : const XCell.empty(XFormat.center),
    ),
    _Column(t.backupElevation, 9, (c) => number(c.elevationGainM, XFormat.integer)),
    _Column(t.backupTeam, 10, (c) => number(c.teamSize, XFormat.integer)),
    _Column(
      t.backupChallenge,
      14,
      (c) => number(c.challengeDistanceM == null ? null : c.challengeDistanceM! / 1000, XFormat.km),
    ),
    _Column(t.backupCharity, 10, (c) => XCell.text(c.isCharity ? t.backupYes : t.backupNo, center: true)),
    _Column(t.backupAssociation, 32, (c) => txt(c.associationName)),
    _Column(t.backupCause, 22, (c) => txt(c.associationCause?.label(t))),
    _Column(t.backupSponsor, 14, (c) => euros(c.sponsorCentsPerKm, c.sponsorCentsPerKm > 0)),
    _Column(t.backupRegistration, 14, (c) => euros(c.registrationDonationCents, c.registrationDonationCents > 0)),
    _Column(t.backupFundraising, 14, (c) => euros(c.fundraisingCents, c.fundraisingCents > 0)),
    _Column(t.backupTotal, 14, (c) => euros(c.donationCents, c.donationCents > 0)),
    _Column(t.backupMetric, 24, (c) => txt(c.impactMetric == ImpactMetric.euroDirect ? null : c.impactMetric.label(t))),
    _Column(t.backupQuantity, 10, (c) => number(c.impactQuantity, XFormat.km)),
    _Column(
      t.backupDocuments,
      30,
      (c) => txt(c.documents.map((d) => d.kind == null ? d.name : '${d.kind!.label(t)} (${d.name})').join(', ')),
    ),
    _Column(t.backupNotes, 40, (c) => txt(c.notes)),
    _Column(t.backupCreated, 12, (c) => XCell.date(c.createdAt)),
    _Column(t.backupUpdated, 12, (c) => XCell.date(c.updatedAt)),
    // En dernier : les colonnes existantes gardent leur place dans les classeurs déjà faits.
    _Column(t.backupDisciplines, 44, (c) => txt(c.multisport == null ? '' : multisportSummary(c.multisport!, t))),
    _Column(
      t.backupTarget,
      11,
      (c) => c.targetDurationS == null
          ? const XCell.empty(XFormat.center)
          : XCell.text(formatDuration(c.targetDurationS!), center: true),
    ),
    _Column(t.backupRanking, 30, (c) => txt(c.ranking == null ? '' : rankingSummary(c.ranking!, t))),
  ];
}

/// Courses sauvegardées : toutes sauf les supprimées, de la plus récente à la plus ancienne.
List<Course> _sorted(Iterable<Course> courses) =>
    courses.where((c) => !c.isDeleted).toList()..sort((a, b) => b.raceDate.compareTo(a.raceDate));

/// Classeur Excel mis en forme de toutes les courses.
Uint8List backupWorkbook(Iterable<Course> courses, AppLocalizations t, {required DateTime today}) {
  final cols = _columns(t, today);
  final list = _sorted(courses);
  return buildXlsx(
    sheetName: t.backupSheetName,
    title: t.backupTitle(formatFullDate(today)),
    subtitle: t.reportSheetSubtitle(list.length),
    headers: [for (final c in cols) c.header],
    widths: [for (final c in cols) c.width],
    rows: [
      for (final course in list) [for (final c in cols) c.cell(course)],
    ],
  );
}

/// CSV de toutes les courses, au format attendu par Excel en français : séparateur « ; »,
/// virgule décimale, dates jj/mm/aaaa, UTF-8 avec BOM (accents lisibles), fins de ligne CRLF.
Uint8List backupCsv(Iterable<Course> courses, AppLocalizations t, {required DateTime today}) {
  final cols = _columns(t, today);
  final decimal = NumberFormat('0.##', 'fr');
  final money = NumberFormat('0.00', 'fr');
  String value(XCell c) => switch (c.value) {
    null => '',
    final DateTime d => DateFormat('dd/MM/yyyy').format(d),
    final num n => c.format == XFormat.euro ? money.format(n) : decimal.format(n),
    final v => '$v',
  };
  String quote(String v) => RegExp(r'[;"\r\n]').hasMatch(v) ? '"${v.replaceAll('"', '""')}"' : v;
  final lines = [
    [for (final c in cols) quote(c.header)].join(';'),
    for (final course in _sorted(courses)) [for (final c in cols) quote(value(c.cell(course)))].join(';'),
  ];
  return Uint8List.fromList([0xEF, 0xBB, 0xBF, ...utf8.encode('${lines.join('\r\n')}\r\n')]);
}
