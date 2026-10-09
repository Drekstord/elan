import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// Choix d'une date avec un bouton « Aujourd'hui » qui ramène le calendrier au jour même.
/// Renvoie la date choisie (à minuit, heure locale) ou null si annulé.
Future<DateTime?> pickDate(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) => showDialog<DateTime>(
  context: context,
  builder: (_) => _DatePickerDialog(initialDate: initialDate, firstDate: firstDate, lastDate: lastDate),
);

class _DatePickerDialog extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _DatePickerDialog({required this.initialDate, required this.firstDate, required this.lastDate});

  @override
  State<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  /// Boutons resserrés : les trois tiennent sur la largeur du calendrier.
  static final _compact = ButtonStyle(
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: Space.md, vertical: 10)),
    minimumSize: const WidgetStatePropertyAll(Size(48, 40)),
  );

  late DateTime _selected = _clamp(widget.initialDate);

  /// Change à chaque « Aujourd'hui » : recrée le calendrier pour afficher le bon mois.
  int _generation = 0;

  DateTime _clamp(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    if (day.isBefore(widget.firstDate)) return widget.firstDate;
    if (day.isAfter(widget.lastDate)) return widget.lastDate;
    return day;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final now = DateTime.now();
    return Dialog(
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: p.band,
              padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, Space.md),
              child: Text(
                toBeginningOfSentenceCase(DateFormat('EEEE d MMMM y', 'fr').format(_selected)),
                style: TextStyles.courseTitle(p.onBand, size: 22),
              ),
            ),
            CalendarDatePicker(
              key: ValueKey(_generation),
              initialDate: _selected,
              firstDate: widget.firstDate,
              lastDate: widget.lastDate,
              onDateChanged: (d) => setState(() => _selected = d),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.sm, 0, Space.sm, Space.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton.icon(
                    style: _compact,
                    onPressed: () => setState(() {
                      _selected = _clamp(now);
                      _generation++;
                    }),
                    icon: const Icon(Icons.today),
                    label: Text(t.datePickerToday),
                  ),
                  // Annuler / OK à droite ; passent l'un sous l'autre si la place manque.
                  Expanded(
                    child: OverflowBar(
                      alignment: MainAxisAlignment.end,
                      overflowAlignment: OverflowBarAlignment.end,
                      spacing: Space.xs,
                      children: [
                        TextButton(style: _compact, onPressed: () => Navigator.pop(context), child: Text(t.cancel)),
                        FilledButton(
                          style: _compact,
                          onPressed: () => Navigator.pop(context, _selected),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
