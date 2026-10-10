import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_fr.dart';
import '../courses/domain/course.dart';
import '../documents/documents.dart';
import '../documents/presentation/document_widgets.dart';
import 'backup.dart';

/// Sauvegarde automatique (ordinateur) : chaque semaine, dans un dossier choisi (Proton Drive,
/// disque externe…), les courses en Excel et une copie des photos et justificatifs.
/// Sur téléphone, Android limite l'écriture dans un dossier choisi : la sauvegarde se fait depuis
/// l'ordinateur, qui a les mêmes données grâce à la synchronisation.
bool get supportsAutoBackup => !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

const autoBackupInterval = Duration(days: 7);
const autoBackupKeep = 8;

/// Dossiers créés dans le dossier choisi.
const autoBackupRoot = 'ELAN';
const autoBackupMediaDir = 'Photos et justificatifs';

class AutoBackupResult {
  final String workbook;
  final int copied;
  final int missing;

  const AutoBackupResult({required this.workbook, required this.copied, required this.missing});
}

/// Photos et justificatifs à copier : chemin lisible dans la sauvegarde -> clé du fichier.
/// « 2026/2026-10-04 Foulée de Démoville - Médaille.jpg » ; doublons numérotés.
Map<String, String> backupMediaFiles(Iterable<Course> courses, AppLocalizations t) {
  String clean(String v) => v.replaceAll(RegExp(r'[\\/:*?"<>|\r\n\t]+'), ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  final files = <String, String>{};
  void add(Course c, String name, String key) {
    final dir = '${c.raceDate.year}';
    var path = '$dir/$name';
    for (var i = 2; files.containsKey(path); i++) {
      final ext = p.extension(name);
      path = '$dir/${p.basenameWithoutExtension(name)} ($i)$ext';
    }
    files[path] = key;
  }

  for (final c in courses.where((c) => !c.isDeleted)) {
    final prefix = '${formatIsoDate(c.raceDate)} ${clean(c.title)}';
    if (c.bibPhotoKey case final key?) add(c, '$prefix - ${clean(t.formBib)}${p.extension(key)}', key);
    if (c.medalPhotoKey case final key?) add(c, '$prefix - ${clean(t.formMedal)}${p.extension(key)}', key);
    for (final d in c.documents) {
      add(c, documentExportName(t, DocumentEntry(c, d)), d.key);
    }
  }
  return files;
}

/// Écrit une sauvegarde dans [folder]/ELAN : le classeur du jour, puis les photos et justificatifs
/// pas encore copiés ([fileOf] fournit le fichier, téléchargé au besoin). Garde les [keep] derniers
/// classeurs. Les fichiers déjà copiés ne sont jamais réécrits.
Future<AutoBackupResult> writeBackup({
  required Directory folder,
  required List<Course> courses,
  required AppLocalizations t,
  required DateTime today,
  required Future<File?> Function(String key) fileOf,
  int keep = autoBackupKeep,
}) async {
  final root = Directory(p.join(folder.path, autoBackupRoot));
  await root.create(recursive: true);

  final workbook = 'ELAN-sauvegarde-${formatIsoDate(today)}.xlsx';
  await File(p.join(root.path, workbook)).writeAsBytes(backupWorkbook(courses, t, today: today), flush: true);

  // Noms datés « AAAA-MM-JJ » : l'ordre alphabétique est l'ordre chronologique.
  final workbooks =
      root
          .listSync()
          .whereType<File>()
          .where((f) => RegExp(r'^ELAN-sauvegarde-\d{4}-\d{2}-\d{2}\.xlsx$').hasMatch(p.basename(f.path)))
          .toList()
        ..sort((a, b) => p.basename(b.path).compareTo(p.basename(a.path)));
  for (final old in workbooks.skip(keep)) {
    await old.delete();
  }

  var copied = 0;
  var missing = 0;
  for (final MapEntry(key: path, value: key) in backupMediaFiles(courses, t).entries) {
    final dest = File(p.joinAll([root.path, autoBackupMediaDir, ...path.split('/')]));
    if (await dest.exists()) continue;
    final source = await fileOf(key);
    if (source == null) {
      missing++;
      continue;
    }
    await dest.parent.create(recursive: true);
    await source.copy(dest.path);
    copied++;
  }
  return AutoBackupResult(workbook: workbook, copied: copied, missing: missing);
}

// ---------------------------------------------------------------------
// Réglage et déclenchement
// ---------------------------------------------------------------------

class AutoBackupState {
  final bool enabled;
  final String? folder;
  final DateTime? last;
  final bool running;
  final AutoBackupResult? result;
  final String? error;

  const AutoBackupState({this.enabled = false, this.folder, this.last, this.running = false, this.result, this.error});

  bool get isDue =>
      enabled && folder != null && (last == null || DateTime.now().difference(last!) >= autoBackupInterval);

  AutoBackupState copyWith({
    bool? enabled,
    String? folder,
    DateTime? last,
    bool? running,
    AutoBackupResult? result,
    String? error,
  }) => AutoBackupState(
    enabled: enabled ?? this.enabled,
    folder: folder ?? this.folder,
    last: last ?? this.last,
    running: running ?? this.running,
    result: result ?? this.result,
    error: error,
  );
}

class AutoBackupController extends Notifier<AutoBackupState> {
  static const _enabled = 'autoBackup.enabled';
  static const _folder = 'autoBackup.folder';
  static const _last = 'autoBackup.last';

  @override
  AutoBackupState build() {
    SharedPreferences.getInstance().then((prefs) {
      if (!ref.mounted) return;
      final last = prefs.getString(_last);
      state = state.copyWith(
        enabled: prefs.getBool(_enabled) ?? false,
        folder: prefs.getString(_folder),
        last: last == null ? null : DateTime.tryParse(last),
      );
      unawaited(runIfDue());
    });
    return const AutoBackupState();
  }

  Future<void> setEnabled(bool value) async {
    state = state.copyWith(enabled: value);
    await (await SharedPreferences.getInstance()).setBool(_enabled, value);
    if (value) await runIfDue();
  }

  Future<void> setFolder(String folder) async {
    state = state.copyWith(folder: folder);
    await (await SharedPreferences.getInstance()).setString(_folder, folder);
    await runIfDue();
  }

  /// Lancée au démarrage, au retour dans l'app et régulièrement : ne fait rien si ce n'est pas l'heure.
  Future<void> runIfDue() async {
    if (supportsAutoBackup && state.isDue) await runNow();
  }

  Future<void> runNow() async {
    final folder = state.folder;
    final courses = ref.read(coursesProvider).value;
    if (folder == null || courses == null || state.running) return;
    state = state.copyWith(running: true);
    try {
      final now = DateTime.now();
      final result = await writeBackup(
        folder: Directory(folder),
        courses: courses,
        t: AppLocalizationsFr(),
        today: calendarDate(now.year, now.month, now.day),
        fileOf: ref.read(syncEngineProvider).photoFile,
      );
      await (await SharedPreferences.getInstance()).setString(_last, now.toIso8601String());
      if (ref.mounted) state = state.copyWith(running: false, last: now, result: result);
    } catch (e) {
      if (ref.mounted) state = state.copyWith(running: false, error: e.toString());
    }
  }
}

final autoBackupProvider = NotifierProvider<AutoBackupController, AutoBackupState>(AutoBackupController.new);
