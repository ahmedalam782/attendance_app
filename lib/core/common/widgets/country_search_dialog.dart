import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';

import '../../helper/phone_helper/phone_length_helper.dart';
import '../../languages/locale_keys.g.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import 'custom_text_field.dart';

/// Al Faris country picker dialog with search.
class CountrySearchDialog extends StatefulWidget {
  const CountrySearchDialog({
    super.key,
    required this.countries,
    required this.currentLocale,
    this.selectedCountryCode,
  });

  final List<CountryModel> countries;
  final String currentLocale;
  final String? selectedCountryCode;

  @override
  State<CountrySearchDialog> createState() => _CountrySearchDialogState();
}

class _CountrySearchDialogState extends State<CountrySearchDialog> {
  late List<CountryModel> _filteredCountries;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _filteredCountries = widget.countries;
    _scrollToSelected();
  }

  void _scrollToSelected() {
    if (widget.selectedCountryCode == null) return;
    final selectedIndex = widget.countries.indexWhere(
      (c) => c.code == widget.selectedCountryCode,
    );
    if (selectedIndex <= 0) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      const itemExtent = 57.0;
      final offset = (selectedIndex * itemExtent).clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );
      _scrollController.jumpTo(offset);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      _filteredCountries = widget.countries
          .where(
            (country) =>
                country.name.toLowerCase().contains(query.toLowerCase()) ||
                country.code.contains(query),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height * 0.7;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: AppColors.cardSurface,
      child: Container(
        padding: const EdgeInsets.all(16),
        height: height,
        child: Column(
          children: [
            CustomTextFormField(
              controller: _searchController,
              onChanged: (value) => _filterCountries(value ?? ''),
              hintText: LocaleKeys.global_search.tr(),
              prefixSvg: AppIcons.iconsSearch,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                controller: _scrollController,
                itemCount: _filteredCountries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 1),
                itemBuilder: (context, index) {
                  final country = _filteredCountries[index];
                  final isSelected =
                      country.code == widget.selectedCountryCode;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor:
                        AppColors.primerColor.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    title: Text(
                      country.name,
                      style: 14.medium.copyWith(
                        color: isSelected
                            ? AppColors.primerColor
                            : AppColors.slate800,
                      ),
                    ),
                    trailing: Text(
                      '+${country.code}',
                      style: 14.semiBold.copyWith(
                        color: isSelected
                            ? AppColors.primerColor
                            : AppColors.slate800,
                      ),
                      textDirection: TextDirection.ltr,
                    ),
                    onTap: () => Navigator.pop(context, country),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
