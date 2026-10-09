import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/format.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/common.dart';
import '../../../app/widgets/date_picker.dart';
import '../../../app/widgets/image_export.dart';
import '../../../app/widgets/rich_clipboard.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/courses_providers.dart';
import '../../courses/domain/course.dart';
import '../../documents/documents.dart';
import '../../documents/presentation/document_widgets.dart';
import '../domain/engagement_report.dart';
import '../report_html.dart';
import '../report_text.dart';
import '../report_workbook.dart';
import 'report_card.dart';

/// Bilan d'une période choisie, pour un rapport : texte à coller, tableau, image.
class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  ReportPreset _preset = ReportPreset.schoolYear;
  (DateTime, DateTime)? _custom;
  bool _charityOnly = false;

  /// Texte rédigé (paragraphes) ou en points clés.
  bool _prose = true;
  bool _busy = false;
  final _boundary = GlobalKey();

  Future<void> _pick(DateTime today, (DateTime, DateTime) range, {required bool start}) async {
    final picked = await pickDate(
      context,
      initialDate: start ? range.$1 : range.$2,
      firstDate: DateTime(2000),
      lastDate: DateTime(today.year + 2, 12, 31),
    );
    if (picked == null) return;
    final day = calendarDate(picked.year, picked.month, picked.day);
    setState(() {
      var (from, to) = range;
      if (start) {
        from = day;
        if (to.isBefore(from)) to = from;
      } else {
        to = day;
        if (from.isAfter(to)) from = to;
      }
      _custom = (from, to);
      _preset = ReportPreset.custom;
    });
  }

  /// Copie en HTML (mise en forme gardée dans Word, Excel, Docs) et en texte brut.
  Future<void> _copy(String text, String html, String message) async {
    await copyRich(text: text, html: html);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _export(EngagementReport report) async {
    setState(() => _busy = true);
    try {
      await exportImage(
        context,
        _boundary,
        fileName: exportFileName('elan-bilan', '${formatIsoDate(report.from)}-${formatIsoDate(report.to)}'),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _exportDocs(EngagementReport report, List<DocumentEntry> docs) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final (zip, missing) = await zipDocuments(
      docs,
      (key) => ref.read(syncEngineProvider).photoFile(key),
      nameOf: (e) => documentExportName(t, e),
    );
    if (!mounted) return;
    await exportFile(
      context,
      zip,
      fileName: exportFileName(
        'elan-justificatifs',
        '${formatIsoDate(report.from)}-${formatIsoDate(report.to)}',
        extension: 'zip',
      ),
      mimeType: 'application/zip',
      extension: 'zip',
    );
    if (missing > 0) messenger.showSnackBar(SnackBar(content: Text(t.docZipMissing(missing))));
  }

  Future<void> _exportExcel(EngagementReport report) => exportFile(
    context,
    reportWorkbook(report, AppLocalizations.of(context)),
    fileName: exportFileName(
      'elan-bilan',
      '${formatIsoDate(report.from)}-${formatIsoDate(report.to)}',
      extension: 'xlsx',
    ),
    mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    extension: 'xlsx',
  );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final today = ref.watch(todayProvider).value ?? calendarDate(DateTime.now().year, DateTime.now().month, 1);
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];
    final range = presetRange(_preset, today, custom: _custom);
    final report = EngagementReport.of(courses, from: range.$1, to: range.$2, charityOnly: _charityOnly);
    final text = _prose ? reportProse(report, t) : reportText(report, t);
    // Justificatifs des courses retenues (mêmes bornes, même option « solidaires »).
    final docs = documentsOf(report.courses, from: report.from, to: report.to);

    final period = SectionCard(
      children: [
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            for (final (preset, label) in [
              (ReportPreset.schoolYear, t.reportPresetSchool),
              (ReportPreset.calendarYear, t.reportPresetYear(today.year)),
              (ReportPreset.last12Months, t.reportPresetLast12),
              if (_preset == ReportPreset.custom) (ReportPreset.custom, t.reportPresetCustom),
            ])
              ChoiceChip(
                label: Text(label),
                selected: _preset == preset,
                onSelected: (_) => setState(() => _preset = preset),
              ),
          ],
        ),
        const SizedBox(height: Space.md),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            OutlinedButton.icon(
              onPressed: () => _pick(today, range, start: true),
              icon: const Icon(Icons.event_outlined),
              label: Text(t.reportFrom(formatDay(range.$1))),
            ),
            OutlinedButton.icon(
              onPressed: () => _pick(today, range, start: false),
              icon: const Icon(Icons.event_outlined),
              label: Text(t.reportTo(formatDay(range.$2))),
            ),
          ],
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(t.reportCharityOnly),
          value: _charityOnly,
          onChanged: (v) => setState(() => _charityOnly = v),
        ),
      ],
    );

    final textCard = SectionCard(
      title: t.reportTextTitle,
      children: [
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: true, label: Text(t.reportStyleProse), icon: const Icon(Icons.notes)),
            ButtonSegment(
              value: false,
              label: Text(t.reportStyleBullets),
              icon: const Icon(Icons.format_list_bulleted),
            ),
          ],
          selected: {_prose},
          onSelectionChanged: (v) => setState(() => _prose = v.first),
        ),
        const SizedBox(height: Space.md),
        SelectableText(text, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: Space.md),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            FilledButton.icon(
              onPressed: () => _copy(text, reportTextHtml(text), t.reportCopied),
              icon: const Icon(Icons.content_copy),
              label: Text(t.reportCopyText),
            ),
            // Deux mises en page : Word (compacte, tient sur une page) ou Excel (toutes les colonnes).
            MenuAnchor(
              menuChildren: [
                MenuItemButton(
                  leadingIcon: const Icon(Icons.description_outlined),
                  onPressed: () => _copy(reportTable(report, t), reportTableHtmlWord(report, t), t.reportTableCopied),
                  child: Text(t.reportCopyForWord),
                ),
                MenuItemButton(
                  leadingIcon: const Icon(Icons.grid_on),
                  onPressed: () => _copy(reportTable(report, t), reportTableHtml(report, t), t.reportTableCopied),
                  child: Text(t.reportCopyForExcel),
                ),
              ],
              builder: (context, controller, _) => OutlinedButton.icon(
                onPressed: () => controller.isOpen ? controller.close() : controller.open(),
                icon: const Icon(Icons.table_chart_outlined),
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(child: Text(t.reportCopyTable, overflow: TextOverflow.ellipsis)),
                    const Icon(Icons.arrow_drop_down, size: 20),
                  ],
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: () => _exportExcel(report),
              icon: const Icon(Icons.grid_on),
              label: Text(t.reportExcel),
            ),
            // Les justificatifs des courses de la période, en un ZIP aux noms clairs.
            if (docs.isNotEmpty)
              OutlinedButton.icon(
                onPressed: () => _exportDocs(report, docs),
                icon: const Icon(Icons.folder_zip_outlined),
                label: Text('${t.reportDocsZip} · ${docs.length}'),
              ),
          ],
        ),
      ],
    );

    final imageCard = SectionCard(
      title: t.reportImageTitle,
      children: [
        if (report.isEmpty)
          Text(t.reportEmpty, style: Theme.of(context).textTheme.bodyMedium)
        else ...[
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(Radii.lg),
                child: RepaintBoundary(
                  key: _boundary,
                  child: ReportCard(report: report),
                ),
              ),
            ),
          ),
          const SizedBox(height: Space.md),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: _busy ? null : () => _export(report),
              icon: _busy
                  ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(exportShares ? Icons.share : Icons.download),
              label: Text(exportShares ? t.shareShare : t.shareSave),
            ),
          ),
        ],
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(t.reportTitle.toUpperCase())),
      body: AdaptiveColumns(
        leftShare: 0.58,
        left: [
          period,
          const SizedBox(height: Space.md),
          textCard,
          const SizedBox(height: Space.md),
        ],
        right: [imageCard],
      ),
    );
  }
}
