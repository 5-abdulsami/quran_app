import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/surah_filter.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../providers.dart';
import '../../router.dart';
import '../../ui/app_shell.dart';
import '../../ui/keyboard.dart';
import '../../ui/widgets/async_value_view.dart';
import 'surah_list_tile.dart';

/// All 114 surahs, filterable by name or number and by revelation place.
class SurahIndexScreen extends ConsumerStatefulWidget {
  const SurahIndexScreen({super.key});

  @override
  ConsumerState<SurahIndexScreen> createState() => _SurahIndexScreenState();
}

class _SurahIndexScreenState extends ConsumerState<SurahIndexScreen> {
  final _query = TextEditingController();
  RevelationFilter _revelation = RevelationFilter.all;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final surahs = ref.watch(surahsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.surahs),
        actions: const [SettingsAction()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onTapOutside: dismissKeyboard,
              controller: _query,
              onChanged: (_) => setState(() {}),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.filterSurahs,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: l10n.clear,
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(_query.clear),
                      ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              spacing: 8,
              children: [
                for (final (filter, label) in [
                  (RevelationFilter.all, l10n.filterAll),
                  (RevelationFilter.makki, l10n.makki),
                  (RevelationFilter.madani, l10n.madani),
                ])
                  ChoiceChip(
                    label: Text(label),
                    selected: _revelation == filter,
                    onSelected: (_) => setState(() => _revelation = filter),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: AsyncValueView(
              value: surahs,
              onRetry: () => ref.invalidate(surahsProvider),
              data: (all) {
                final visible = filterSurahs(
                  all,
                  query: _query.text,
                  revelation: _revelation,
                );
                return ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  itemCount: visible.length,
                  itemBuilder: (context, index) => SurahListTile(
                    surah: visible[index],
                    onTap: () =>
                        context.push(AppRoutes.surah(visible[index].number)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
