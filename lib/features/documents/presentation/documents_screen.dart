import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/format.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/common.dart';
import '../../../app/widgets/image_export.dart';
import '../../../core/providers.dart';
import '../../../core/text.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/courses_providers.dart';
import '../../courses/domain/course.dart';
import '../../report/domain/engagement_report.dart';
import '../documents.dart';
import 'document_widgets.dart';

/// Tous les justificatifs, rattachés à leur course, filtrables par période ; export ZIP.
class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  /// null = toutes les dates.
  ReportPreset? _preset;
  String _search = '';
  bool _busy = false;

  Future<void> _exportZip(List<DocumentEntry> entries, (DateTime, DateTime)? range) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final (zip, missing) = await zipDocuments(
        entries,
        (key) => ref.read(syncEngineProvider).photoFile(key),
        nameOf: (e) => documentExportName(t, e),
      );
      if (!mounted) return;
      final suffix = range == null ? 'tous' : '${formatIsoDate(range.$1)}-${formatIsoDate(range.$2)}';
      await exportFile(
        context,
        zip,
        fileName: exportFileName('elan-justificatifs', suffix, extension: 'zip'),
        mimeType: 'application/zip',
        extension: 'zip',
      );
      if (missing > 0) messenger.showSnackBar(SnackBar(content: Text(t.docZipMissing(missing))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addFromList(List<Course> courses) async {
    final course = await showDialog<Course>(
      context: context,
      builder: (_) => _CoursePickerDialog(courses: courses),
    );
    if (course != null && mounted) await addDocumentTo(context, ref, course);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final today = ref.watch(todayProvider).value ?? calendarDate(DateTime.now().year, DateTime.now().month, 1);
    final courses = (ref.watch(coursesProvider).value ?? const <Course>[]).where((c) => !c.isDeleted).toList();
    final range = _preset == null ? null : presetRange(_preset!, today);
    final needle = fold(_search.trim());
    final entries = documentsOf(courses, from: range?.$1, to: range?.$2)
        .where(
          (e) =>
              needle.isEmpty ||
              fold(e.course.title).contains(needle) ||
              fold(e.course.associationName ?? '').contains(needle) ||
              fold(e.document.name).contains(needle),
        )
        .toList();

    // Regroupement par course (l'ordre de [documentsOf] est conservé).
    final groups = <Course, List<DocumentEntry>>{};
    for (final e in entries) {
      (groups[e.course] ??= []).add(e);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.docTitle.toUpperCase()),
        actions: [
          IconButton(
            tooltip: t.docZip,
            onPressed: entries.isEmpty || _busy ? null : () => _exportZip(entries, range),
            icon: _busy
                ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.folder_zip_outlined),
          ),
          const SizedBox(width: Space.sm),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: courses.isEmpty ? null : () => _addFromList(courses),
        icon: const Icon(Icons.attach_file),
        label: Text(t.docAdd.toUpperCase()),
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.md, 112),
          children: [
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.sm,
              children: [
                for (final (preset, label) in <(ReportPreset?, String)>[
                  (null, t.docAllDates),
                  (ReportPreset.schoolYear, t.reportPresetSchool),
                  (ReportPreset.calendarYear, t.reportPresetYear(today.year)),
                  (ReportPreset.last12Months, t.reportPresetLast12),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: _preset == preset,
                    onSelected: (_) => setState(() => _preset = preset),
                  ),
              ],
            ),
            const SizedBox(height: Space.sm),
            TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(hintText: t.docSearch, prefixIcon: const Icon(Icons.search), isDense: true),
            ),
            const SizedBox(height: Space.md),
            if (entries.isNotEmpty) ...[
              // Passe à la ligne si la place manque (téléphone, textes agrandis).
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: Space.sm,
                runSpacing: Space.sm,
                children: [
                  Text(t.docCount(entries.length, groups.length), style: Theme.of(context).textTheme.titleSmall),
                  FilledButton.tonalIcon(
                    onPressed: _busy ? null : () => _exportZip(entries, range),
                    icon: const Icon(Icons.folder_zip_outlined),
                    label: Text(t.docZip),
                  ),
                ],
              ),
              const SizedBox(height: Space.md),
            ],
            if (entries.isEmpty)
              EmptyState(
                icon: Icons.receipt_long_outlined,
                message: courses.any((c) => c.documents.isNotEmpty) ? t.docNoMatch : t.docEmpty,
              ),
            for (final MapEntry(key: course, value: docs) in groups.entries) ...[
              Card(
                clipBehavior: Clip.antiAlias,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.sm, Space.xs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      InkWell(
                        onTap: () => context.push(Routes.course(course.id)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: Space.xs),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(course.title.toUpperCase(), style: TextStyles.courseTitle(p.text, size: 18)),
                                    Text(
                                      [
                                        formatDay(course.raceDate),
                                        if (course.associationName != null) course.associationName!,
                                        if (course.donationCents > 0) formatEuros(course.donationCents),
                                      ].join('  ·  '),
                                      style: Theme.of(context).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right, color: p.textMuted),
                            ],
                          ),
                        ),
                      ),
                      for (final e in docs) DocumentTile(course: course, document: e.document),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Space.sm),
            ],
          ],
        ),
      ),
    );
  }
}

/// Choix de la course à laquelle rattacher un justificatif (recherche par nom ou association).
class _CoursePickerDialog extends StatefulWidget {
  final List<Course> courses;

  const _CoursePickerDialog({required this.courses});

  @override
  State<_CoursePickerDialog> createState() => _CoursePickerDialogState();
}

class _CoursePickerDialogState extends State<_CoursePickerDialog> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final needle = fold(_search.trim());
    final list =
        widget.courses
            .where(
              (c) => needle.isEmpty || fold(c.title).contains(needle) || fold(c.associationName ?? '').contains(needle),
            )
            .toList()
          ..sort((a, b) => b.raceDate.compareTo(a.raceDate));
    return AlertDialog(
      title: Text(t.docChooseCourse),
      contentPadding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, 0),
      content: SizedBox(
        width: 420,
        height: 420,
        child: Column(
          children: [
            TextField(
              autofocus: true,
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: t.coursesSearch,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
            ),
            const SizedBox(height: Space.sm),
            Expanded(
              child: ListView(
                children: [
                  for (final c in list)
                    ListTile(
                      title: Text(c.title),
                      subtitle: Text(
                        [formatDay(c.raceDate), if (c.associationName != null) c.associationName!].join('  ·  '),
                      ),
                      trailing: c.documents.isEmpty ? null : Badge(label: Text('${c.documents.length}')),
                      onTap: () => Navigator.pop(context, c),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(t.cancel))],
    );
  }
}
