import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/rituals/panchang.dart';
import '../../core/rituals/providers.dart';
import '../../design/tokens.dart';
import '../../design/widgets.dart';
import '../../l10n/l10n.dart';

/// Search the bundled cities; shows the chosen one until you type.
class CityPicker extends ConsumerStatefulWidget {
  const CityPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  ConsumerState<CityPicker> createState() => _CityPickerState();
}

class _CityPickerState extends ConsumerState<CityPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final DharmaColors c = context.c;
    final List<PanchangCity> all =
        ref.watch(citiesProvider).value ?? const <PanchangCity>[];
    final String q = _query.trim().toLowerCase();
    final bool hindi = Localizations.localeOf(context).languageCode == 'hi';
    final List<PanchangCity> shown = <PanchangCity>[
      for (final PanchangCity city in all)
        if (q.isEmpty
            ? city.id == widget.selected
            : city.name.toLowerCase().contains(q) ||
                  (city.nameHi?.contains(q) ?? false))
          city,
    ].take(4).toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        TextField(
          style: DType.body(c.ink, size: 20),
          decoration: InputDecoration(
            hintText: context.l.searchCity,
            hintStyle: DType.body(c.faint, size: 20),
          ),
          onChanged: (String v) => setState(() => _query = v),
        ),
        const SizedBox(height: Sp.s14),
        for (final PanchangCity city in shown) ...<Widget>[
          OptionRow(
            label: city.labelIn(hindi: hindi),
            selected: city.id == widget.selected,
            onTap: () => widget.onSelected(city.id),
          ),
          const SizedBox(height: Sp.s12),
        ],
      ],
    );
  }
}
