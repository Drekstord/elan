import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/format.dart';
import '../../../app/labels.dart';
import '../../../app/router.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/common.dart';
import '../../../app/widgets/image_export.dart';
import '../../../app/widgets/rich_clipboard.dart';
import '../../../core/providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/domain/course.dart';
import '../../documents/documents.dart';
import '../../documents/presentation/document_widgets.dart';
import '../../report/domain/engagement_report.dart';
import '../../report/presentation/report_card.dart';
import '../../report/report_html.dart';
import '../association_text.dart';
import '../domain/association_summary.dart';

/// Récapitulatif d'une association : argent engagé, courses, causes, impact annoncé,
/// justificatifs ; texte à copier et image, comme le bilan.
class AssociationScreen extends ConsumerStatefulWidget {
  final String name;

  const AssociationScreen({super.key, required this.name});

  @override
  ConsumerState<AssociationScreen> createState() => _AssociationScreenState();
}

class _AssociationScreenState extends ConsumerState<AssociationScreen> {
  final _boundary = GlobalKey();
  bool _busy = false;

  Future<void> _zip(AssociationSummary a) async {
    final t = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final (zip, missing) = await zipDocuments(
        documentsOf(a.courses),
        (key) => ref.read(syncEngineProvider).photoFile(key),
        nameOf: (e) => documentExportName(t, e),
      );
      if (!mounted) return;
      await exportFile(
        context,
        zip,
        fileName: exportFileName('elan-justificatifs', a.name, extension: 'zip'),
        mimeType: 'application/zip',
        extension: 'zip',
      );
      if (missing > 0) messenger.showSnackBar(SnackBar(content: Text(t.docZipMissing(missing))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final courses = ref.watch(coursesProvider).value ?? const <Course>[];
    final a = associationSummary(courses, widget.name);

    if (a == null) {
      return Scaffold(
        appBar: AppBar(title: Text(t.assoTitle.toUpperCase())),
        body: EmptyState(icon: Icons.volunteer_activism_outlined, message: t.assoNotFound),
      );
    }

    final muted = p.onBandMuted;
    final declared = a.declared.entries.toList()..sort((x, y) => y.value.compareTo(x.value));
    final text = associationText(a, t);
    final docs = documentsOf(a.courses);
    final period = a.first == a.last ? formatDay(a.first) : t.reportPeriod(formatDay(a.first), formatDay(a.last));

    final hero = HeroBand(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Kicker(a.causes.map((c) => c.label(t)).join('  ·  '), color: p.bandAccent),
          const SizedBox(height: Space.xs),
          Text(a.name.toUpperCase(), style: TextStyles.courseTitle(p.onBand, size: 30)),
          const SizedBox(height: Space.lg),
          HeroFigure(
            size: 80,
            value: formatEurosAmount(a.donationCents),
            unit: '€',
            label: t.statDonations,
            color: p.bandWarm,
          ),
          const SizedBox(height: Space.lg),
          StatGrid(
            minTileWidth: 120,
            tiles: [
              StatTile(label: t.statRaces, value: '${a.courses.length}', color: p.onBand, labelColor: muted),
              StatTile(
                label: t.statDistance,
                value: formatKm(a.distanceM, decimals: 1),
                color: p.onBand,
                labelColor: muted,
              ),
              for (final e in declared)
                StatTile(label: e.key.label(t), value: formatQuantity(e.value), color: p.bandAccent, labelColor: muted),
            ],
          ),
          const SizedBox(height: Space.md),
          Text(period, style: TextStyles.kicker(muted, size: 12)),
        ],
      ),
    );

    final coursesCard = SectionCard(
      title: t.assoCourses,
      children: [
        // Sous l'en-tête plutôt qu'à côté : tient sur un téléphone, même avec de grands textes.
        if (docs.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _busy ? null : () => _zip(a),
              icon: const Icon(Icons.folder_zip_outlined, size: 18),
              label: Text(t.docZip),
            ),
          ),
        for (final c in a.courses.reversed) ...[
          InkWell(
            onTap: () => context.push(Routes.course(c.id)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: Space.sm),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c.title, style: Theme.of(context).textTheme.titleSmall),
                        Text(
                          [
                            formatDay(c.raceDate),
                            formatKm(c.distanceM, decimals: 1),
                            if (c.documents.isNotEmpty) t.docCountShort(c.documents.length),
                          ].join('  ·  '),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (c.donationCents > 0)
                    Text(formatEuros(c.donationCents), style: TextStyles.figure(p.solidarity, size: 18)),
                  Icon(Icons.chevron_right, color: p.textMuted),
                ],
              ),
            ),
          ),
          for (final d in c.documents) DocumentTile(course: c, document: d),
        ],
      ],
    );

    final exportCard = SectionCard(
      title: t.assoExport,
      children: [
        SelectableText(text, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: Space.md),
        Wrap(
          spacing: Space.sm,
          runSpacing: Space.sm,
          children: [
            FilledButton.icon(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                await copyRich(text: text, html: reportTextHtml(text));
                messenger.showSnackBar(SnackBar(content: Text(t.reportCopied)));
              },
              icon: const Icon(Icons.content_copy),
              label: Text(t.reportCopyText),
            ),
          ],
        ),
        const SizedBox(height: Space.lg),
        Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Radii.lg),
              child: RepaintBoundary(
                key: _boundary,
                child: ReportCard(
                  report: EngagementReport.of(a.courses, from: a.first, to: a.last),
                  title: a.name,
                  subtitle: '${t.assoCardTitle} · $period',
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.md),
        Align(
          alignment: Alignment.centerLeft,
          child: FilledButton.icon(
            onPressed: () => exportImage(context, _boundary, fileName: exportFileName('elan', a.name)),
            icon: Icon(exportShares ? Icons.share : Icons.download),
            label: Text(exportShares ? t.shareShare : t.shareSave),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(t.assoTitle.toUpperCase())),
      body: AdaptiveColumns(
        left: [
          hero,
          const SizedBox(height: Space.md),
          coursesCard,
          const SizedBox(height: Space.md),
        ],
        right: [exportCard],
      ),
    );
  }
}
