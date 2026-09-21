import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/validations.dart';
import '../../helper/extensions/phone_text_controller.dart';
import '../../helper/phone_helper/phone_length_helper.dart';
import '../../languages/locale_keys.g.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import 'country_search_dialog.dart';
import 'custom_text_field.dart';

/// Al Faris phone field — country code opens [CountrySearchDialog].
class CustomPhoneField extends StatefulWidget {
  const CustomPhoneField({
    super.key,
    this.validator,
    this.controller,
    this.onFieldSubmitted,
    this.onChanged,
    this.showTitle = false,
    this.initialCountryCode = '20',
    this.textInputAction = TextInputAction.next,
    this.autoFocus = false,
    this.isReadOnly = false,
  });

  final String? Function(String? value, int? maxLength)? validator;
  final TextEditingController? controller;
  final void Function(String? value)? onFieldSubmitted;
  final void Function(String? value)? onChanged;
  final bool showTitle;
  final String initialCountryCode;
  final TextInputAction? textInputAction;
  final bool autoFocus;
  final bool isReadOnly;

  @override
  State<CustomPhoneField> createState() => _CustomPhoneFieldState();
}

class _CustomPhoneFieldState extends State<CustomPhoneField> {
  late TextEditingController _controller;
  var _ownsController = false;
  int? _maxLength;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _controller.initializeCountryCode(widget.initialCountryCode);
    _focusNode = FocusNode()..addListener(() => setState(() {}));
    _updateMaxLength();
  }

  void _updateMaxLength() {
    setState(() {
      _maxLength =
          PhoneHelper.countryPhoneLengths[_controller.selectedCountryCode];
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    if (_ownsController) {
      _controller.clearCountryCode();
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _showCountryPicker() async {
    final countries = PhoneHelper.getAllCountries(context.locale.languageCode);
    final selectedCountry = await showDialog<CountryModel>(
      context: context,
      builder: (context) => CountrySearchDialog(
        countries: countries,
        currentLocale: context.locale.languageCode,
        selectedCountryCode: _controller.selectedCountryCode,
      ),
    );

    if (selectedCountry != null) {
      setState(() {
        _controller.updateSelectedCountryCode(selectedCountry.code);
        _updateMaxLength();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: CustomTextFormField(
        hintText: widget.showTitle
            ? LocaleKeys.custom_widgets_phone_number.tr()
            : LocaleKeys.custom_widgets_phone_number.tr(),
        textInputAction: widget.textInputAction,
        onChanged: widget.onChanged,
        maxLength: _focusNode.hasFocus ? _maxLength : null,
        validator: (value) => widget.validator != null
            ? widget.validator!(value, _maxLength)
            : Validations.validatePhoneNumber(
                value,
                _maxLength,
                _controller.selectedCountryCode,
              ),
        focusNode: _focusNode,
        isReadOnly: widget.isReadOnly,
        autoFocus: widget.autoFocus,
        controller: _controller,
        textInputType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        onFieldSubmitted: widget.onFieldSubmitted,
        prefixSvg: AppIcons.iconsPhone,
        suffixWidget: InkWell(
          onTap: widget.isReadOnly ? null : _showCountryPicker,
          child: Padding(
            padding: const EdgeInsetsDirectional.only(end: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+${_controller.selectedCountryCode}',
                  textDirection: TextDirection.ltr,
                  style: 14.medium.copyWith(color: AppColors.slate800),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
