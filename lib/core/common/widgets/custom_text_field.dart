import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/input_borders.dart';

export '../../theme/input_borders.dart' show customOutLineBorders;

class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    this.validator,
    this.controller,
    this.textInputType,
    this.prefixIcon,
    this.prefixSvg,
    this.suffixWidget,
    this.hintText,
    this.title,
    this.textInputAction,
    this.onFieldSubmitted,
    this.isObscureText = false,
    this.isReadOnly = false,
    this.autoFocus = false,
    this.maxLength,
    this.onChanged,
    this.inputFormatters,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextInputType? textInputType;
  final IconData? prefixIcon;
  final String? prefixSvg;
  final Widget? suffixWidget;
  final String? hintText;
  final String? title;
  final TextInputAction? textInputAction;
  final void Function(String?)? onFieldSubmitted;
  final bool isObscureText;
  final bool isReadOnly;
  final bool autoFocus;
  final int? maxLength;
  final void Function(String?)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode autovalidateMode;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late final TextEditingController _controller;
  var _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _controller.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasData = _controller.text.isNotEmpty;
    final iconColor = hasData ? AppColors.black33 : AppColors.grey99;

    Widget? prefix;
    if (widget.prefixSvg != null) {
      prefix = SvgPicture.asset(
        widget.prefixSvg!,
        width: 20,
        height: 20,
        fit: BoxFit.scaleDown,
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
      );
    } else if (widget.prefixIcon != null) {
      prefix = Icon(widget.prefixIcon, color: iconColor, size: 20);
    }

    return TextFormField(
      controller: _controller,
      autovalidateMode: widget.autovalidateMode,
      obscureText: widget.isObscureText,
      readOnly: widget.isReadOnly,
      autofocus: widget.autoFocus,
      maxLength: widget.maxLength,
      keyboardType: widget.textInputType,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      inputFormatters: widget.inputFormatters,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      cursorColor: AppColors.primerColor,
      style: 16.regular.copyWith(color: hasData ? AppColors.black33 : null),
      decoration: InputDecoration(
        filled: true,
        fillColor: widget.isReadOnly
            ? AppColors.greyF5
            : AppColors.originalWhite,
        hintText: widget.hintText,
        labelText: widget.title,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        hintStyle: 16.regular.copyWith(color: AppColors.greyB5),
        labelStyle: 16.regular.copyWith(color: AppColors.greyB5),
        errorStyle: 12.regular.copyWith(color: AppColors.primerColorDark),
        contentPadding: const EdgeInsetsDirectional.only(
          start: 10,
          end: 10,
          top: 15,
          bottom: 15,
        ),
        prefixIcon: prefix,
        suffixIcon: widget.suffixWidget,
        border: customOutLineBorders(),
        enabledBorder: customOutLineBorders(),
        disabledBorder: customOutLineBorders(),
        errorBorder: customOutLineBorders(borderColor: AppColors.primerColorDark),
        focusedBorder: customOutLineBorders(
          borderColor: AppColors.primerColor,
          borderWidth: 1.5,
        ),
      ),
    );
  }
}
