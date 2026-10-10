import 'package:flutter/material.dart';

import '../../../app/format.dart';
import '../../../app/labels.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../l10n/app_localizations.dart';
import '../domain/course.dart';

/// Résultat de la saisie d'une épreuve enchaînée.
class MultisportInput {
  final Multisport multisport;

  /// Temps total, transitions comprises (0 : pas de chrono).
  final int durationS;

  const MultisportInput(this.multisport, this.durationS);
}

/// État de la saisie d'une épreuve enchaînée : épreuve, format, distance et temps de chaque
/// discipline, transitions (à part, ou comptées dans les disciplines), temps total.
class MultisportEditorController extends ChangeNotifier {
  MultisportKind _kind;
  String? _format;
  bool _transitionsIncluded;

  final List<TextEditingController> distances = [];
  final List<TextEditingController> durations = [];
  final List<TextEditingController> transitions = [];
  final TextEditingController total = TextEditingController();

  /// Message d'erreur à afficher sous la saisie, après [read].
  String? error;

  MultisportEditorController({Multisport? initial, int initialDurationS = 0})
    : _kind = initial?.kind ?? MultisportKind.triathlon,
      _format = initial?.format,
      _transitionsIncluded = initial?.transitionsIncluded ?? false {
    _resetFields();
    if (initial == null) {
      _applyFormat(MultisportFormat.of(_kind).where((f) => f.name == 'S').firstOrNull);
      return;
    }
    for (var i = 0; i < initial.legs.length && i < distances.length; i++) {
      distances[i].text = _distanceInput(_kind.sports[i], initial.legs[i].distanceM);
      if (initial.legs[i].durationS > 0) durations[i].text = formatDuration(initial.legs[i].durationS);
    }
    for (var i = 0; i < initial.transitionsS.length && i < transitions.length; i++) {
      if (initial.transitionsS[i] > 0) transitions[i].text = formatDuration(initial.transitionsS[i]);
    }
    // Temps total saisi à la main (sans détail, ou différent de la somme) : on le garde.
    if (initialDurationS > 0 && initialDurationS != initial.splitsTotalS) total.text = formatDuration(initialDurationS);
  }

  /// Remplace toute la saisie par une épreuve lue dans un fichier de montre.
  void load(Multisport imported) {
    _kind = imported.kind;
    _format = imported.format;
    _transitionsIncluded = false;
    _resetFields();
    total.clear();
    error = null;
    for (var i = 0; i < imported.legs.length && i < distances.length; i++) {
      distances[i].text = _distanceInput(_kind.sports[i], imported.legs[i].distanceM);
      if (imported.legs[i].durationS > 0) durations[i].text = formatDuration(imported.legs[i].durationS);
    }
    for (var i = 0; i < imported.transitionsS.length && i < transitions.length; i++) {
      if (imported.transitionsS[i] > 0) transitions[i].text = formatDuration(imported.transitionsS[i]);
    }
    notifyListeners();
  }

  MultisportKind get kind => _kind;
  String? get format => _format;
  bool get transitionsIncluded => _transitionsIncluded;
  List<Sport> get sports => _kind.sports;

  static String _distanceInput(Sport sport, int meters) =>
      meters == 0 ? '' : (sport == Sport.swim ? '$meters' : metersToKmInput(meters));

  void _resetFields() {
    for (final c in [...distances, ...durations, ...transitions]) {
      c.dispose();
    }
    distances
      ..clear()
      ..addAll([for (final _ in _kind.sports) TextEditingController()]);
    durations
      ..clear()
      ..addAll([for (final _ in _kind.sports) TextEditingController()]);
    transitions
      ..clear()
      ..addAll([for (var i = 0; i < _kind.sports.length - 1; i++) TextEditingController()]);
  }

  void _applyFormat(MultisportFormat? format) {
    _format = format?.name;
    if (format == null) return;
    for (var i = 0; i < distances.length; i++) {
      distances[i].text = _distanceInput(_kind.sports[i], format.distancesM[i]);
    }
  }

  set kind(MultisportKind value) {
    if (value == _kind) return;
    _kind = value;
    _resetFields();
    total.clear();
    error = null;
    final formats = MultisportFormat.of(value);
    _applyFormat(
      formats.where((f) => f.name == _format).firstOrNull ?? formats.where((f) => f.name == 'S').firstOrNull,
    );
    notifyListeners();
  }

  /// [name] null : distances libres (celles déjà saisies sont gardées).
  void selectFormat(String? name) {
    _applyFormat(MultisportFormat.of(_kind).where((f) => f.name == name).firstOrNull);
    _format = name;
    notifyListeners();
  }

  set transitionsIncluded(bool value) {
    _transitionsIncluded = value;
    notifyListeners();
  }

  /// Une distance modifiée à la main ne correspond plus forcément au format choisi.
  void distanceEdited() {
    final format = MultisportFormat.of(_kind).where((f) => f.name == _format).firstOrNull;
    if (format != null) {
      for (var i = 0; i < distances.length; i++) {
        if (_parseDistance(i) != format.distancesM[i]) {
          _format = null;
          break;
        }
      }
    }
    notifyListeners();
  }

  int? _parseDistance(int index) {
    final text = distances[index].text.trim();
    if (text.isEmpty) return null;
    if (_kind.sports[index] == Sport.swim) return int.tryParse(text.replaceAll(RegExp(r'\s'), ''));
    final km = parseDecimal(text);
    return km == null ? null : (km * 1000).round();
  }

  /// Distance totale saisie jusqu'ici, en mètres (aperçu du parrainage au kilomètre).
  int get previewDistanceM {
    var sum = 0;
    for (var i = 0; i < distances.length; i++) {
      sum += _parseDistance(i) ?? 0;
    }
    return sum;
  }

  /// Somme des temps saisis (disciplines et transitions), ou null si le détail est incomplet.
  int? get computedTotalS {
    var sum = 0;
    for (final c in durations) {
      final s = parseDuration(c.text);
      if (c.text.trim().isEmpty || s == null || s <= 0) return null;
      sum += s;
    }
    if (!_transitionsIncluded) {
      for (final c in transitions) {
        if (c.text.trim().isNotEmpty) sum += parseDuration(c.text) ?? 0;
      }
    }
    return sum;
  }

  /// Valide et renvoie la saisie ; null si elle est incorrecte ([error] dit pourquoi).
  /// [planned] : épreuve à venir, seuls l'épreuve et les distances comptent.
  MultisportInput? read(AppLocalizations t, {required bool planned}) {
    error = null;
    final meters = <int>[];
    for (var i = 0; i < distances.length; i++) {
      final m = _parseDistance(i);
      if (m == null || m <= 0) {
        error = t.issueLegDistance;
        return null;
      }
      meters.add(m);
    }

    final times = <int>[];
    final gaps = <int>[];
    var duration = 0;
    if (!planned) {
      final filled = durations.where((c) => c.text.trim().isNotEmpty).length;
      if (filled != 0 && filled != durations.length) {
        error = t.issueLegTimes;
        return null;
      }
      for (final c in durations) {
        final s = c.text.trim().isEmpty ? 0 : parseDuration(c.text);
        if (s == null) {
          error = t.issueInvalidDuration;
          return null;
        }
        times.add(s);
      }
      if (!_transitionsIncluded) {
        for (final c in transitions) {
          final s = c.text.trim().isEmpty ? 0 : parseDuration(c.text);
          if (s == null) {
            error = t.issueInvalidDuration;
            return null;
          }
          gaps.add(s);
        }
      }
      final computed = computedTotalS;
      final entered = total.text.trim().isEmpty ? null : parseDuration(total.text);
      if (total.text.trim().isNotEmpty && entered == null) {
        error = t.issueInvalidDuration;
        return null;
      }
      if (entered != null && computed != null && entered < computed) {
        error = t.issueTotalBelowSplits(formatDuration(computed));
        return null;
      }
      duration = entered ?? computed ?? 0;
    }

    return MultisportInput(
      Multisport(
        kind: _kind,
        format: _format,
        legs: [
          for (var i = 0; i < meters.length; i++)
            Leg(sport: _kind.sports[i], distanceM: meters[i], durationS: planned ? 0 : times[i]),
        ],
        transitionsS: gaps,
        transitionsIncluded: _transitionsIncluded,
      ),
      duration,
    );
  }

  @override
  void dispose() {
    for (final c in [...distances, ...durations, ...transitions, total]) {
      c.dispose();
    }
    super.dispose();
  }
}

/// Saisie d'une épreuve enchaînée, dans le formulaire de course.
class MultisportEditor extends StatelessWidget {
  final MultisportEditorController controller;

  /// Épreuve à venir : pas de temps à saisir.
  final bool planned;

  /// Prévenu à chaque frappe (aperçu du don, effacement des erreurs).
  final VoidCallback onChanged;

  const MultisportEditor({super.key, required this.controller, required this.planned, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final small = Theme.of(context).textTheme.bodySmall?.copyWith(color: p.textMuted);
    const decimal = TextInputType.numberWithOptions(decimal: true);

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final sports = controller.sports;
        final computed = controller.computedTotalS;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<MultisportKind>(
              segments: [for (final k in MultisportKind.values) ButtonSegment(value: k, label: Text(k.label(t)))],
              selected: {controller.kind},
              showSelectedIcon: false,
              onSelectionChanged: (s) {
                controller.kind = s.first;
                onChanged();
              },
            ),
            const SizedBox(height: Space.md),
            Text(t.multisportFormat, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: Space.xs),
            Wrap(
              spacing: Space.sm,
              runSpacing: Space.xs,
              children: [
                for (final f in MultisportFormat.of(controller.kind))
                  ChoiceChip(
                    label: Text(f.name),
                    selected: controller.format == f.name,
                    onSelected: (_) {
                      controller.selectFormat(f.name);
                      onChanged();
                    },
                  ),
                ChoiceChip(
                  label: Text(t.multisportFormatFree),
                  selected: controller.format == null,
                  onSelected: (_) {
                    controller.selectFormat(null);
                    onChanged();
                  },
                ),
              ],
            ),
            const SizedBox(height: Space.xs),
            Text(t.multisportFormatHint, style: small),
            for (var i = 0; i < sports.length; i++) ...[
              const SizedBox(height: Space.md),
              Row(
                children: [
                  Icon(sports[i].icon, size: 20, color: p.accent),
                  const SizedBox(width: Space.sm),
                  Expanded(
                    child: Text(sportLabelAt(sports, i, t), style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: Space.sm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.distances[i],
                      keyboardType: sports[i] == Sport.swim ? TextInputType.number : decimal,
                      onChanged: (_) {
                        controller.distanceEdited();
                        onChanged();
                      },
                      decoration: InputDecoration(
                        labelText: t.multisportLegDistance,
                        suffixText: sports[i] == Sport.swim ? 'm' : 'km',
                      ),
                    ),
                  ),
                  if (!planned) ...[
                    const SizedBox(width: Space.md),
                    Expanded(
                      child: TextField(
                        controller: controller.durations[i],
                        onChanged: (_) {
                          controller.distanceEdited();
                          onChanged();
                        },
                        decoration: InputDecoration(
                          labelText: t.multisportLegTime,
                          hintText: sports[i] == Sport.bike ? '1:05:30' : '12:30',
                          helperText: controller.transitionsIncluded && i < sports.length - 1
                              ? t.multisportTransitionIncludedNote
                              : null,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (!planned && !controller.transitionsIncluded && i < sports.length - 1) ...[
                const SizedBox(height: Space.md),
                TextField(
                  controller: controller.transitions[i],
                  onChanged: (_) {
                    controller.distanceEdited();
                    onChanged();
                  },
                  decoration: InputDecoration(
                    labelText: t.multisportTransition(i + 1),
                    hintText: '2:15',
                    prefixIcon: const Icon(Icons.swap_horiz),
                  ),
                ),
              ],
            ],
            if (!planned) ...[
              const SizedBox(height: Space.sm),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: controller.transitionsIncluded,
                onChanged: (v) {
                  controller.transitionsIncluded = v;
                  onChanged();
                },
                title: Text(t.multisportTransitionsIncluded),
                subtitle: Text(t.multisportTransitionsIncludedHint),
              ),
              const SizedBox(height: Space.sm),
              TextField(
                controller: controller.total,
                onChanged: (_) {
                  controller.distanceEdited();
                  onChanged();
                },
                decoration: InputDecoration(
                  labelText: t.multisportTotalTime,
                  hintText: computed == null ? '1:23:45' : formatDuration(computed),
                  helperText: computed == null
                      ? t.multisportTotalOnly
                      : t.multisportTotalComputed(formatDuration(computed)),
                  helperMaxLines: 3,
                  prefixIcon: const Icon(Icons.timer_outlined),
                ),
              ),
            ],
            if (controller.error != null) ...[
              const SizedBox(height: Space.sm),
              Text(
                controller.error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
              ),
            ],
          ],
        );
      },
    );
  }
}
