import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/labels.dart';
import '../../../app/theme/app_theme.dart';
import '../../../app/theme/tokens.dart';
import '../../../core/text.dart';
import '../../../l10n/app_localizations.dart';
import '../../courses/domain/course.dart';
import '../data/association_search.dart';
import '../domain/association.dart';

/// Choix d'une association : catalogue, répertoire officiel, ou saisie libre.
Future<Association?> pickAssociation(BuildContext context) => showModalBottomSheet<Association>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => const FractionallySizedBox(heightFactor: 0.9, child: _AssociationPicker()),
);

class _AssociationPicker extends ConsumerStatefulWidget {
  const _AssociationPicker();

  @override
  ConsumerState<_AssociationPicker> createState() => _AssociationPickerState();
}

class _AssociationPickerState extends ConsumerState<_AssociationPicker> {
  final _query = TextEditingController();
  Timer? _debounce;
  List<Association> _official = const [];
  bool _searching = false;
  bool _offline = false;
  int _generation = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _query.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () => _searchOfficial(value));
  }

  Future<void> _searchOfficial(String value) async {
    final generation = ++_generation;
    if (value.trim().length < 3) {
      setState(() => _official = const []);
      return;
    }
    setState(() => _searching = true);
    try {
      final results = await ref.read(associationSearchProvider).searchOfficial(value);
      if (mounted && generation == _generation) {
        setState(() {
          _official = results;
          _offline = false;
        });
      }
    } catch (_) {
      if (mounted && generation == _generation) setState(() => _offline = true);
    } finally {
      if (mounted && generation == _generation) setState(() => _searching = false);
    }
  }

  Future<void> _useFreeName(String name) async {
    final t = AppLocalizations.of(context);
    final cause = await showDialog<CauseType>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(t.assoCause),
        children: [
          for (final c in CauseType.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, c),
              child: Row(
                children: [
                  Icon(c.icon, size: 20),
                  const SizedBox(width: Space.md),
                  Text(c.label(t)),
                ],
              ),
            ),
        ],
      ),
    );
    if (cause != null && mounted) {
      Navigator.pop(context, Association(id: 'libre-${fold(name).hashCode}', name: name.trim(), cause: cause));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = context.palette;
    final query = _query.text.trim();
    final catalog = AssociationSearch.searchCatalog(query);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(Space.md),
            child: TextField(
              controller: _query,
              autofocus: true,
              onChanged: _onChanged,
              decoration: InputDecoration(hintText: t.assoSearchHint, prefixIcon: const Icon(Icons.search)),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (query.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: Text(t.assoFree(query)),
                    onTap: () => _useFreeName(query),
                  ),
                if (catalog.isNotEmpty) _header(t.assoCatalog),
                for (final a in catalog) _tile(a, t),
                if (query.length >= 3) ...[
                  _header(t.assoOfficial),
                  if (_searching)
                    ListTile(
                      leading: const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      title: Text(t.assoSearching),
                    )
                  else if (_offline)
                    ListTile(
                      leading: Icon(Icons.cloud_off_outlined, color: p.textMuted),
                      title: Text(t.assoSearchOffline),
                    )
                  else if (_official.isEmpty)
                    ListTile(
                      title: Text(t.assoNoResult, style: TextStyle(color: p.textMuted)),
                    )
                  else
                    for (final a in _official) _tile(a, t),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(String label) => Padding(
    padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, Space.xs),
    child: Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: context.palette.textMuted)),
  );

  Widget _tile(Association a, AppLocalizations t) => ListTile(
    leading: Icon(a.cause.icon),
    title: Text(a.name),
    subtitle: Text([a.cause.label(t), ?a.city].join(' · ')),
    onTap: () => Navigator.pop(context, a),
  );
}
