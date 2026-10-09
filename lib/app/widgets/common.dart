import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/media/media_store.dart';
import '../../core/providers.dart';
import '../../features/courses/domain/course.dart';
import '../../l10n/app_localizations.dart';
import '../labels.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'count_up.dart';
import 'elan_emblem.dart';

/// Logotype : emblème d'élan (facultatif) et « ÉLAN » en capitales condensées,
/// souligné d'un trait d'accent.
class Wordmark extends StatelessWidget {
  final double size;
  final Color? color;
  final bool withEmblem;

  const Wordmark({super.key, this.size = 28, this.color, this.withEmblem = true});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final word = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).appTitle,
          style: TextStyles.courseTitle(color ?? p.text, size: size).copyWith(letterSpacing: size * 0.06),
        ),
        Container(width: size * 0.9, height: size * 0.12, color: p.accent),
      ],
    );
    if (!withEmblem) return word;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElanEmblem(size: size * 1.25, color: color ?? p.text),
        SizedBox(width: size * 0.3),
        word,
      ],
    );
  }
}

/// Sur-titre en capitales : « KILOMÈTRES ».
class Kicker extends StatelessWidget {
  final String text;
  final Color? color;
  final double size;

  const Kicker(this.text, {super.key, this.color, this.size = 13});

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    semanticsLabel: text,
    style: TextStyles.kicker(color ?? context.palette.textMuted, size: size),
  );
}

/// En-tête de section : sur-titre et filet épais.
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(header: true, child: Kicker(title, color: p.text, size: 15)),
            ),
            // Se resserre au besoin (téléphone, textes agrandis) au lieu de déborder.
            if (trailing case final trailing?) ...[const SizedBox(width: Space.sm), Flexible(child: trailing)],
          ],
        ),
        const SizedBox(height: Space.xs),
        Container(height: 2, color: p.text),
      ],
    );
  }
}

/// Bloc de contenu sur surface, avec en-tête de section facultatif.
class SectionCard extends StatelessWidget {
  final String? title;
  final Widget? trailing;
  final List<Widget> children;

  const SectionCard({super.key, this.title, this.trailing, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[SectionHeader(title!, trailing: trailing), const SizedBox(height: Space.md)],
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Bandeau inversé (noir) pour les chiffres héros, souligné de l'accent.
class HeroBand extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const HeroBand({super.key, required this.child, this.padding = const EdgeInsets.all(Space.lg)});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(color: p.band, borderRadius: BorderRadius.circular(Radii.lg)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: padding,
            child: DefaultTextStyle.merge(
              style: TextStyle(color: p.onBand),
              child: child,
            ),
          ),
          Container(height: 5, color: p.bandAccent),
        ],
      ),
    );
  }
}

/// Grand chiffre avec son unité et son sur-titre (dans un [HeroBand]).
class HeroFigure extends StatelessWidget {
  final String value;
  final String? unit;
  final String label;
  final Color? color;
  final double size;

  /// Chiffre animé (défile jusqu'à sa valeur au lancement, voir [CountUp]) ; sinon [value] fixe.
  final ({String id, num value, String Function(num) format})? count;

  const HeroFigure({
    super.key,
    this.value = '',
    this.unit,
    required this.label,
    this.color,
    this.size = 88,
    this.count,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = color ?? p.onBand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              if (count case final n?)
                CountUp(
                  id: n.id,
                  value: n.value,
                  format: n.format,
                  style: TextStyles.hero(c, size: size),
                )
              else
                Text(value, style: TextStyles.hero(c, size: size)),
              if (unit != null) ...[
                const SizedBox(width: Space.xs),
                Text(unit!, style: TextStyles.figure(c, size: size * 0.34)),
              ],
            ],
          ),
        ),
        const SizedBox(height: Space.sm),
        Kicker(label, color: p.onBandMuted),
      ],
    );
  }
}

/// Valeur chiffrée avec son libellé.
class StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final Color? labelColor;
  final bool large;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.color,
    this.labelColor,
    this.large = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Kicker(label, color: labelColor, size: 12),
        const SizedBox(height: Space.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(value, style: TextStyles.figure(color ?? p.text, size: large ? 34 : 24)),
        ),
      ],
    );
  }
}

/// Grille de statistiques qui s'adapte à la largeur.
class StatGrid extends StatelessWidget {
  final List<Widget> tiles;
  final double minTileWidth;

  const StatGrid({super.key, required this.tiles, this.minTileWidth = 140});

  @override
  Widget build(BuildContext context) {
    if (tiles.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final perRow = (constraints.maxWidth / minTileWidth).floor().clamp(1, tiles.length);
        final width = (constraints.maxWidth - (perRow - 1) * Space.md) / perRow;
        return Wrap(
          spacing: Space.md,
          runSpacing: Space.md,
          children: [for (final tile in tiles) SizedBox(width: width, child: tile)],
        );
      },
    );
  }
}

/// Étiquette de statut pour les courses à venir ou à compléter.
class StatusChip extends StatelessWidget {
  final CourseStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (color, icon) = switch (status) {
      CourseStatus.upcoming => (p.upcoming, Icons.event_outlined),
      CourseStatus.awaitingResult => (p.accent, Icons.edit_note),
      CourseStatus.completed => (p.accent, Icons.check),
    };
    return Pill(
      icon: icon,
      label: status.label(AppLocalizations.of(context)),
      color: color,
      filled: status == CourseStatus.awaitingResult,
    );
  }
}

/// Étiquette à angles francs, texte en capitales condensées.
class Pill extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;
  final bool filled;

  const Pill({super.key, this.icon, required this.label, required this.color, this.filled = false});

  @override
  Widget build(BuildContext context) {
    final fg = filled ? context.palette.onAccent : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: Space.xs)],
          Flexible(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyles.kicker(fg, size: 12).copyWith(letterSpacing: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

/// Photo de course par clé : cache local, sinon téléchargement.
class CoursePhoto extends ConsumerWidget {
  final String photoKey;
  final bool thumbnail;
  final BoxFit fit;

  /// Texte alternatif lu par les lecteurs d'écran ; null = image décorative (ignorée).
  final String? semanticLabel;

  const CoursePhoto({
    super.key,
    required this.photoKey,
    this.thumbnail = false,
    this.fit = BoxFit.cover,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final muted = context.palette.textMuted;
    final key = thumbnail ? MediaStore.thumbKeyOf(photoKey) : photoKey;
    final file = ref.watch(photoFileProvider(key));
    // La miniature peut manquer (format non décodable) : repli sur l'original.
    if (thumbnail && file.hasValue && file.value == null) {
      return CoursePhoto(photoKey: photoKey, fit: fit, semanticLabel: semanticLabel);
    }
    return file.when(
      loading: () =>
          const Center(child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      error: (_, _) => Center(child: Icon(Icons.broken_image_outlined, color: muted)),
      data: (f) => f == null
          ? Center(child: Icon(Icons.cloud_off_outlined, color: muted))
          : Image.file(
              f,
              fit: fit,
              semanticLabel: semanticLabel,
              excludeFromSemantics: semanticLabel == null,
              errorBuilder: (_, _, _) => Center(child: Icon(Icons.broken_image_outlined, color: muted)),
            ),
    );
  }
}

/// Plein écran zoomable.
Future<void> showPhoto(BuildContext context, String photoKey, {String? label}) => showDialog<void>(
  context: context,
  builder: (ctx) => Dialog.fullscreen(
    backgroundColor: Colors.black,
    child: Stack(
      children: [
        Positioned.fill(
          child: InteractiveViewer(
            maxScale: 5,
            child: CoursePhoto(photoKey: photoKey, fit: BoxFit.contain, semanticLabel: label),
          ),
        ),
        Positioned(
          top: Space.md,
          right: Space.md,
          child: IconButton.filled(
            tooltip: AppLocalizations.of(ctx).close,
            onPressed: () => Navigator.pop(ctx),
            icon: const Icon(Icons.close),
          ),
        ),
      ],
    ),
  ),
);

/// Message centré pour les listes vides.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const EmptyState({super.key, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Space.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 44, color: p.accent),
              const SizedBox(height: Space.md),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: p.textMuted, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Contenu centré et limité en largeur sur grand écran.
class ContentWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ContentWidth({super.key, required this.child, this.maxWidth = kContentMaxWidth});

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}

/// Une colonne sur téléphone, deux côte à côte sur grand écran
/// (chaque colonne défile alors indépendamment).
class AdaptiveColumns extends StatelessWidget {
  final List<Widget> left;
  final List<Widget> right;

  /// Largeur de la colonne de gauche en disposition large (part de la largeur).
  final double leftShare;

  const AdaptiveColumns({super.key, required this.left, required this.right, this.leftShare = 0.5});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < kTwoColumns) {
          return ContentWidth(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(Space.md, 0, Space.md, Space.xl),
              children: [...left, ...right],
            ),
          );
        }
        final width = c.maxWidth.clamp(0, kWideMaxWidth).toDouble();
        return Center(
          child: SizedBox(
            width: width,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: (width - Space.lg * 3) * leftShare,
                  child: ListView(padding: const EdgeInsets.fromLTRB(Space.lg, 0, 0, Space.xl), children: left),
                ),
                const SizedBox(width: Space.lg),
                Expanded(
                  child: ListView(padding: const EdgeInsets.fromLTRB(0, 0, Space.lg, Space.xl), children: right),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
