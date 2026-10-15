import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/format.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../app/widgets/common.dart';
import '../../../app/widgets/file_open.dart';
import '../../../app/widgets/image_export.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/data/file_import.dart';
import '../../courses/domain/course.dart';
import '../documents.dart';

/// « 245 Ko », « 1,2 Mo » ; en anglais « 245 KB », « 1.2 MB ».
String formatBytes(int bytes) {
  final english = formatLocale == 'en';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).ceil()} ${english ? 'KB' : 'Ko'}';
  final mega = (bytes / (1024 * 1024)).toStringAsFixed(1);
  return english ? '$mega MB' : '${mega.replaceAll('.', ',')} Mo';
}

extension DocumentKindLabel on DocumentKind {
  String label(AppLocalizations t) => switch (this) {
    DocumentKind.confirmation => t.docKindConfirmation,
    DocumentKind.invoice => t.docKindInvoice,
    DocumentKind.donationReceipt => t.docKindReceipt,
    DocumentKind.result => t.docKindResult,
    DocumentKind.other => t.docKindOther,
  };

  IconData get icon => switch (this) {
    DocumentKind.confirmation => Icons.mark_email_read_outlined,
    DocumentKind.invoice => Icons.receipt_long_outlined,
    DocumentKind.donationReceipt => Icons.volunteer_activism_outlined,
    DocumentKind.result => Icons.emoji_events_outlined,
    DocumentKind.other => Icons.description_outlined,
  };
}

/// Titre d'un justificatif : son type, ou son nom de fichier s'il n'en a pas encore.
String documentTitle(AppLocalizations t, CourseDocument d) => d.kind?.label(t) ?? d.name;

/// Nom du fichier exporté : « 2026-10-04 Foulée de Démoville - Facture.pdf ».
String documentExportName(AppLocalizations t, DocumentEntry e) => e.exportName(kindLabel: e.document.kind?.label(t));

/// Choix du type d'un justificatif ; [initial] est présélectionné.
Future<DocumentKind?> pickDocumentKind(BuildContext context, {DocumentKind? initial}) {
  final t = AppLocalizations.of(context);
  return showDialog<DocumentKind>(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(t.docChooseKind),
      children: [
        for (final kind in DocumentKind.values)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, kind),
            padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.sm),
            child: Row(
              children: [
                Icon(kind.icon, color: context.palette.solidarity),
                const SizedBox(width: Space.md),
                Expanded(
                  child: Text(
                    kind.label(t),
                    style: kind == initial
                        ? Theme.of(context).textTheme.titleSmall
                        : Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (kind == initial) Icon(Icons.check, color: context.palette.accent),
              ],
            ),
          ),
      ],
    ),
  );
}

/// Joint un justificatif choisi sur l'appareil à [course], après en avoir choisi le type
/// (proposé d'après le nom du fichier).
Future<void> addDocumentTo(BuildContext context, WidgetRef ref, Course course) async {
  final t = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final picked = await FileImport.pickDocument(dialogTitle: t.docAdd);
  if (picked == null || !context.mounted) return;
  final kind = await pickDocumentKind(context, initial: DocumentKind.guess(picked.name));
  if (kind == null) return;
  final ok = await ref.read(documentActionsProvider).add(course, picked.file, picked.name, kind);
  messenger.showSnackBar(SnackBar(content: Text(ok ? t.docAdded(course.title) : t.docTooBig)));
}

/// Une ligne de justificatif : type, nom, taille ; ouvrir, enregistrer / partager, retirer.
class DocumentTile extends ConsumerWidget {
  final Course course;
  final CourseDocument document;

  const DocumentTile({super.key, required this.course, required this.document});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final actions = ref.read(documentActionsProvider);
    final entry = DocumentEntry(course, document);

    Future<void> open() async {
      final messenger = ScaffoldMessenger.of(context);
      final file = await actions.file(document);
      if (file == null) {
        messenger.showSnackBar(SnackBar(content: Text(t.docUnavailable)));
        return;
      }
      await openLocalFile(file, displayName: document.safeName);
    }

    Future<void> export() async {
      final file = await actions.file(document);
      final bytes = await file?.readAsBytes();
      if (!context.mounted) return;
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.docUnavailable)));
        return;
      }
      await exportFile(
        context,
        bytes,
        fileName: documentExportName(t, entry),
        mimeType: mimeOf(document.safeName),
        extension: document.extension.isEmpty ? 'bin' : document.extension,
      );
    }

    Future<void> changeKind() async {
      final kind = await pickDocumentKind(context, initial: document.kind ?? DocumentKind.guess(document.name));
      if (kind != null) await actions.setKind(course, document, kind);
    }

    Future<void> remove() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.docRemoveTitle),
          content: Text(t.docRemoveBody(document.name)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(t.cancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(t.delete)),
          ],
        ),
      );
      if (confirmed == true) await actions.remove(course, document);
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      // Icône du type (ou du format pour un justificatif sans type) ; titre = type, nom du fichier dessous.
      leading: Icon(
        document.kind?.icon ?? (document.isPdf ? Icons.picture_as_pdf_outlined : Icons.image_outlined),
        color: p.solidarity,
      ),
      title: Text(documentTitle(t, document), maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        [
          if (document.kind != null) document.name,
          formatBytes(document.sizeBytes),
          t.docAddedOn(formatDay(document.addedAt)),
        ].join(' · '),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: open,
      trailing: PopupMenuButton<int>(
        tooltip: t.docActions,
        onSelected: (choice) => switch (choice) {
          0 => open(),
          1 => export(),
          3 => changeKind(),
          _ => remove(),
        },
        itemBuilder: (_) => [
          PopupMenuItem(
            value: 0,
            child: ListTile(leading: const Icon(Icons.open_in_new), title: Text(t.docOpen)),
          ),
          PopupMenuItem(
            value: 1,
            child: ListTile(
              leading: Icon(exportShares ? Icons.share : Icons.download),
              title: Text(exportShares ? t.shareShare : t.docSave),
            ),
          ),
          PopupMenuItem(
            value: 3,
            child: ListTile(leading: const Icon(Icons.label_outline), title: Text(t.docChangeKind)),
          ),
          PopupMenuItem(
            value: 2,
            child: ListTile(leading: const Icon(Icons.delete_outline), title: Text(t.docRemove)),
          ),
        ],
      ),
    );
  }
}

/// Section « Justificatifs » de la fiche d'une course.
class CourseDocumentsCard extends ConsumerWidget {
  final Course course;

  const CourseDocumentsCard({super.key, required this.course});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return SectionCard(
      title: t.docTitle,
      trailing: Text('${course.documents.length}', style: Theme.of(context).textTheme.labelLarge),
      children: [
        if (course.documents.isEmpty) Text(t.docEmptyCourse, style: Theme.of(context).textTheme.bodySmall),
        for (final d in course.documents) DocumentTile(course: course, document: d),
        const SizedBox(height: Space.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => addDocumentTo(context, ref, course),
            icon: const Icon(Icons.attach_file),
            label: Text(t.docAdd),
          ),
        ),
      ],
    );
  }
}
