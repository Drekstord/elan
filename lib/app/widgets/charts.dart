import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Graphiques ÉLAN, sans bibliothèque : marques fines, grille discrète,
/// valeurs en couleur de texte (jamais dans la couleur de la série),
/// infobulle au survol, étiquettes directes sélectives.

/// Arrondi « lisible » de l'échelle : 1 ; 1,5 ; 2 ; 2,5 ; 3 ; 4 ; 5 ; 6 ; 8 × 10^n.
double niceCeiling(double value) {
  if (value <= 0) return 1;
  final exponent = math.pow(10, (math.log(value) / math.ln10).floor()).toDouble();
  for (final step in [1, 1.5, 2, 2.5, 3, 4, 5, 6, 8, 10]) {
    if (value <= step * exponent) return step * exponent;
  }
  return 10 * exponent;
}

const double _axisWidth = 52;

/// Réserve au-dessus des barres pour l'étiquette de valeur.
const double _labelSpace = 22;

TextStyle _axisStyle(BuildContext context) =>
    TextStyles.kicker(context.palette.textMuted, size: 11).copyWith(letterSpacing: 0.4, fontFeatures: Fonts.tabular);

/// Grille horizontale (0, milieu, haut) avec libellés à gauche.
class _Grid extends StatelessWidget {
  final double max;
  final String Function(double) format;

  const _Grid({required this.max, required this.format});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return LayoutBuilder(
      builder: (context, c) => Stack(
        children: [
          for (final f in [0.0, 0.5, 1.0]) ...[
            Positioned(
              left: _axisWidth,
              right: 0,
              top: c.maxHeight * (1 - f),
              child: Container(height: 1, color: f == 0 ? p.border : p.border.withValues(alpha: 0.5)),
            ),
            Positioned(
              left: 0,
              width: _axisWidth - 6,
              top: (c.maxHeight * (1 - f) - 7).clamp(0, c.maxHeight - 14),
              child: Text(format(max * f), textAlign: TextAlign.right, style: _axisStyle(context)),
            ),
          ],
        ],
      ),
    );
  }
}

class BarDatum {
  final String axisLabel;
  final String tooltip;
  final double value;

  const BarDatum({required this.axisLabel, required this.tooltip, required this.value});
}

/// Barres verticales d'une seule série (le titre de la carte la nomme).
///
/// Chaque période a son libellé sous l'axe ; la valeur s'affiche au-dessus des barres
/// quand la place le permet. Un appui sélectionne une barre ([onSelect]).
class BarChart extends StatelessWidget {
  final List<BarDatum> data;
  final Color color;

  /// Graduations de l'axe, avec l'unité (« 100 km »).
  final String Function(double) format;

  /// Étiquette au-dessus d'une barre, sans unité (« 42 »).
  final String Function(double)? valueLabel;
  final double height;
  final int? selected;
  final ValueChanged<int>? onSelect;

  const BarChart({
    super.key,
    required this.data,
    required this.color,
    required this.format,
    this.valueLabel,
    this.height = 180,
    this.selected,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = data.fold(0.0, (m, d) => math.max(m, d.value));
    final top = niceCeiling(maxValue);
    final lastNonZero = data.lastIndexWhere((d) => d.value > 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final columnWidth = (constraints.maxWidth - _axisWidth) / math.max(1, data.length);
        return _bars(context, maxValue, top, lastNonZero, columnWidth);
      },
    );
  }

  Widget _bars(BuildContext context, double maxValue, double top, int lastNonZero, double columnWidth) {
    final p = context.palette;
    final label = valueLabel ?? format;
    // Toutes les valeurs si les colonnes sont assez larges ; sinon le maximum,
    // la dernière période et la sélection.
    final labelAll = columnWidth >= 28;
    // Libellés d'axe : tous, ou un sur deux / trois quand les périodes sont nombreuses.
    final axisEvery = math.max(1, (22 / columnWidth).ceil());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                top: _labelSpace,
                child: _Grid(max: top, format: format),
              ),
              Positioned.fill(
                left: _axisWidth,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final (i, d) in data.indexed)
                      Expanded(
                        child: Tooltip(
                          message: d.tooltip,
                          waitDuration: Duration.zero,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onSelect == null ? null : () => onSelect!(i),
                            // Zone d'appui : toute la colonne, pas seulement la barre.
                            child: Container(
                              color: i == selected ? p.text.withValues(alpha: 0.06) : Colors.transparent,
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.symmetric(horizontal: 1),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (d.value > 0 &&
                                      (labelAll || d.value == maxValue || i == lastNonZero || i == selected))
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          label(d.value),
                                          style: TextStyles.figure(
                                            selected == null || i == selected ? p.text : p.textMuted,
                                            size: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  Container(
                                    // Barre fine : au plus 62 % de la colonne et 36 px.
                                    width: math.min(36, columnWidth * 0.62),
                                    height: d.value <= 0 ? 0 : math.max(2, (height - _labelSpace) * d.value / top),
                                    decoration: BoxDecoration(
                                      // La barre sélectionnée reste pleine, les autres s'atténuent.
                                      color: selected == null || i == selected ? color : color.withValues(alpha: 0.4),
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Space.xs),
        Padding(
          padding: const EdgeInsets.only(left: _axisWidth),
          child: Row(
            children: [
              for (final (i, d) in data.indexed)
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        i % axisEvery == 0 || i == selected ? d.axisLabel : '',
                        maxLines: 1,
                        style: _axisStyle(context).copyWith(
                          color: i == selected ? p.text : null,
                          fontWeight: i == selected ? FontWeight.w800 : null,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Forme de la marque d'une entrée de légende.
enum LegendMark { bar, line, dot }

/// Légende : marque colorée + libellé en couleur de texte (+ valeur éventuelle).
class ChartLegend extends StatelessWidget {
  final List<(LegendMark, Color, String, String?)> items;

  const ChartLegend(this.items, {super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    Widget mark(LegendMark kind, Color color) => switch (kind) {
      LegendMark.bar => Container(
        width: 10,
        height: 14,
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
        ),
      ),
      LegendMark.line => Container(width: 16, height: 3, color: color),
      LegendMark.dot => Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    };
    return Wrap(
      spacing: Space.lg,
      runSpacing: Space.xs,
      children: [
        for (final (kind, color, label, value) in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              mark(kind, color),
              const SizedBox(width: Space.sm),
              Flexible(
                child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: p.text)),
              ),
              if (value != null) ...[
                const SizedBox(width: Space.sm),
                Text(value, style: TextStyles.figure(p.text, size: 15)),
              ],
            ],
          ),
      ],
    );
  }
}

class LineSeries {
  final String name;
  final Color color;

  /// Précision affichée dans la légende après la valeur finale (« au 8 oct. »).
  final String? note;

  /// Points (x, y) en marches d'escalier : la valeur change à chaque point et reste
  /// constante jusqu'au suivant ; la série s'arrête à [endX].
  final List<(double, double)> points;
  final double endX;

  const LineSeries({required this.name, required this.color, required this.points, required this.endX, this.note});

  double valueAt(double x) {
    var v = 0.0;
    for (final (px, py) in points) {
      if (px > x) break;
      v = py;
    }
    return v;
  }
}

/// Courbes cumulées (2 séries au plus), légende + étiquettes directes, réticule au survol.
class StepLineChart extends StatefulWidget {
  final List<LineSeries> series;
  final double maxX;
  final String Function(double) formatY;
  final String Function(double) formatX;
  final List<(double, String)> xTicks;
  final double height;

  const StepLineChart({
    super.key,
    required this.series,
    required this.maxX,
    required this.formatY,
    required this.formatX,
    required this.xTicks,
    this.height = 200,
  });

  @override
  State<StepLineChart> createState() => _StepLineChartState();
}

class _StepLineChartState extends State<StepLineChart> {
  double? _hoverX;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final maxY = niceCeiling(widget.series.fold(0.0, (m, s) => math.max(m, s.points.last.$2)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Légende, toujours présente à partir de deux séries, avec la valeur finale.
        ChartLegend([
          for (final s in widget.series)
            (
              LegendMark.line,
              s.color,
              s.name,
              '${widget.formatY(s.points.last.$2)}${s.note == null ? '' : '  ${s.note}'}',
            ),
        ]),
        const SizedBox(height: Space.md),
        // Lecteurs d'écran : la courbe est dessinée, on lit la valeur finale de chaque série.
        Semantics(
          container: true,
          label: [
            for (final s in widget.series) '${s.name} : ${widget.formatY(s.points.last.$2)} ${s.note ?? ''}'.trim(),
          ].join(' ; '),
          child: ExcludeSemantics(
            child: SizedBox(
              height: widget.height,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _Grid(max: maxY, format: widget.formatY),
                  ),
                  Positioned.fill(
                    left: _axisWidth,
                    child: LayoutBuilder(
                      builder: (context, c) {
                        final hover = _hoverX;
                        final tooltipLeft = hover == null ? 0.0 : (hover / widget.maxX * c.maxWidth);
                        return MouseRegion(
                          onHover: (e) => setState(
                            () => _hoverX = (e.localPosition.dx / c.maxWidth * widget.maxX).clamp(0, widget.maxX),
                          ),
                          onExit: (_) => setState(() => _hoverX = null),
                          child: GestureDetector(
                            onHorizontalDragUpdate: (e) => setState(
                              () => _hoverX = (e.localPosition.dx / c.maxWidth * widget.maxX).clamp(0, widget.maxX),
                            ),
                            onHorizontalDragEnd: (_) => setState(() => _hoverX = null),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _StepPainter(widget.series, widget.maxX, maxY, hover, p.text, p.surface),
                                  ),
                                ),
                                if (hover != null)
                                  Positioned(
                                    top: 0,
                                    left: tooltipLeft > c.maxWidth - 170 ? tooltipLeft - 170 : tooltipLeft + 10,
                                    child: _ChartTooltip(
                                      title: widget.formatX(hover),
                                      rows: [
                                        for (final s in widget.series)
                                          if (hover <= s.endX) (s.color, s.name, widget.formatY(s.valueAt(hover))),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.xs),
        Padding(
          padding: const EdgeInsets.only(left: _axisWidth),
          child: LayoutBuilder(
            builder: (context, c) {
              // Une graduation sur deux si elles se chevaucheraient.
              final every = c.maxWidth / math.max(1, widget.xTicks.length) < 30 ? 2 : 1;
              return SizedBox(
                height: 14,
                child: Stack(
                  children: [
                    for (final (i, (x, label)) in widget.xTicks.indexed)
                      if (i % every == 0)
                        Positioned(
                          left: (x / widget.maxX * c.maxWidth - 16).clamp(0, c.maxWidth - 32),
                          width: 32,
                          child: Text(label, textAlign: TextAlign.center, style: _axisStyle(context)),
                        ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StepPainter extends CustomPainter {
  final List<LineSeries> series;
  final double maxX;
  final double maxY;
  final double? hoverX;
  final Color ink;
  final Color surface;

  _StepPainter(this.series, this.maxX, this.maxY, this.hoverX, this.ink, this.surface);

  @override
  void paint(Canvas canvas, Size size) {
    Offset at(double x, double y) => Offset(x / maxX * size.width, size.height - y / maxY * size.height);

    // Série de comparaison d'abord, série principale par-dessus.
    for (final s in series.reversed) {
      final line = Paint()
        ..color = s.color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round;
      final path = Path()..moveTo(at(0, 0).dx, at(0, 0).dy);
      var y = 0.0;
      for (final (px, py) in s.points.skip(1)) {
        path.lineTo(at(px, y).dx, at(px, y).dy);
        path.lineTo(at(px, py).dx, at(px, py).dy);
        y = py;
      }
      path.lineTo(at(s.endX, y).dx, at(s.endX, y).dy);
      canvas.drawPath(path, line);
      // Point final, cerclé de la couleur de fond.
      final end = at(s.endX, y);
      canvas.drawCircle(end, 5, Paint()..color = surface);
      canvas.drawCircle(end, 4, Paint()..color = s.color);
    }

    final hover = hoverX;
    if (hover != null) {
      final x = at(hover, 0).dx;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        Paint()
          ..color = ink.withValues(alpha: 0.35)
          ..strokeWidth = 1,
      );
      for (final s in series) {
        if (hover > s.endX) continue;
        final point = at(hover, s.valueAt(hover));
        canvas.drawCircle(point, 5, Paint()..color = surface);
        canvas.drawCircle(point, 4, Paint()..color = s.color);
      }
    }
  }

  @override
  bool shouldRepaint(_StepPainter old) => old.hoverX != hoverX || old.series != series || old.maxY != maxY;
}

class _ChartTooltip extends StatelessWidget {
  final String title;
  final List<(Color, String, String)> rows;

  const _ChartTooltip({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return IgnorePointer(
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(Space.sm),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: p.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyles.kicker(p.textMuted, size: 11)),
            const SizedBox(height: Space.xs),
            for (final (color, name, value) in rows)
              Row(
                children: [
                  Container(width: 8, height: 8, color: color),
                  const SizedBox(width: Space.xs),
                  Expanded(child: Text(name, style: Theme.of(context).textTheme.bodySmall)),
                  Text(value, style: TextStyles.figure(p.text, size: 14)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class DotDatum {
  final double x;
  final double y;
  final String tooltipTitle;
  final String tooltipValue;

  const DotDatum({required this.x, required this.y, required this.tooltipTitle, required this.tooltipValue});
}

/// Nuage de points d'une série ; [invertY] place les petites valeurs en haut
/// (allure : plus rapide = plus haut).
class DotChart extends StatefulWidget {
  final List<DotDatum> data;
  final Color color;
  final String Function(double) formatY;
  final List<(double, String)> xTicks;
  final double minX;
  final double maxX;
  final bool invertY;
  final double height;

  const DotChart({
    super.key,
    required this.data,
    required this.color,
    required this.formatY,
    required this.xTicks,
    required this.minX,
    required this.maxX,
    this.invertY = false,
    this.height = 200,
  });

  @override
  State<DotChart> createState() => _DotChartState();
}

class _DotChartState extends State<DotChart> {
  int? _hover;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ys = widget.data.map((d) => d.y);
    // Échelle resserrée autour des données (une allure ne part pas de zéro).
    final step = 15.0;
    final lo = (ys.reduce(math.min) / step).floor() * step - step;
    final hi = (ys.reduce(math.max) / step).ceil() * step + step;
    final spanX = math.max(1.0, widget.maxX - widget.minX);

    double fy(double y, double h) => widget.invertY ? (y - lo) / (hi - lo) * h : h - (y - lo) / (hi - lo) * h;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Lecteurs d'écran : chaque point (course, date, valeur), comme les infobulles.
        Semantics(
          container: true,
          label: [for (final d in widget.data) '${d.tooltipTitle} : ${d.tooltipValue}'].join(' ; '),
          child: ExcludeSemantics(
            child: SizedBox(
              height: widget.height,
              child: LayoutBuilder(
                builder: (context, c) {
                  final w = c.maxWidth - _axisWidth - 8;
                  final h = c.maxHeight - 8;
                  Offset pos(DotDatum d) => Offset(_axisWidth + 4 + (d.x - widget.minX) / spanX * w, 4 + fy(d.y, h));
                  final hover = _hover;
                  return MouseRegion(
                    onHover: (e) {
                      int? best;
                      var bestDist = 18.0;
                      for (final (i, d) in widget.data.indexed) {
                        final dist = (pos(d) - e.localPosition).distance;
                        if (dist < bestDist) {
                          best = i;
                          bestDist = dist;
                        }
                      }
                      if (best != _hover) setState(() => _hover = best);
                    },
                    onExit: (_) => setState(() => _hover = null),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        for (final f in [0.0, 0.5, 1.0]) ...[
                          Positioned(
                            left: _axisWidth,
                            right: 0,
                            top: 4 + h * f,
                            child: Container(height: 1, color: p.border.withValues(alpha: f == 1 ? 1 : 0.5)),
                          ),
                          Positioned(
                            left: 0,
                            width: _axisWidth - 6,
                            top: (h * f - 3).clamp(0, h),
                            child: Text(
                              widget.formatY(widget.invertY ? lo + (hi - lo) * f : hi - (hi - lo) * f),
                              textAlign: TextAlign.right,
                              style: _axisStyle(context),
                            ),
                          ),
                        ],
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _DotPainter([for (final d in widget.data) pos(d)], widget.color, p.surface, hover),
                          ),
                        ),
                        if (hover != null)
                          Positioned(
                            left: pos(widget.data[hover]).dx > c.maxWidth - 180
                                ? pos(widget.data[hover]).dx - 172
                                : pos(widget.data[hover]).dx + 12,
                            top: (pos(widget.data[hover]).dy - 24).clamp(0, h),
                            child: _ChartTooltip(
                              title: widget.data[hover].tooltipTitle,
                              rows: [(widget.color, '', widget.data[hover].tooltipValue)],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.xs),
        Padding(
          padding: const EdgeInsets.only(left: _axisWidth + 4, right: 4),
          child: LayoutBuilder(
            builder: (context, c) => SizedBox(
              height: 14,
              child: Stack(
                children: [
                  for (final (x, label) in widget.xTicks)
                    Positioned(
                      left: ((x - widget.minX) / spanX * c.maxWidth - 20).clamp(0, c.maxWidth - 40),
                      width: 40,
                      child: Text(label, textAlign: TextAlign.center, style: _axisStyle(context)),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DotPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;
  final Color surface;
  final int? hover;

  _DotPainter(this.points, this.color, this.surface, this.hover);

  @override
  void paint(Canvas canvas, Size size) {
    for (final (i, pt) in points.indexed) {
      final r = i == hover ? 6.0 : 4.0;
      // Anneau de la couleur du fond : les points qui se chevauchent restent distincts.
      canvas.drawCircle(pt, r + 2, Paint()..color = surface);
      canvas.drawCircle(pt, r, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_DotPainter old) => old.hover != hover || old.points.length != points.length;
}
