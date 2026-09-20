import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_icons.dart';
import '../../theme/app_typography.dart';
import '../../theme/input_borders.dart';

class PassTextFormField extends StatefulWidget {
  const PassTextFormField({
    super.key,
    this.validator,
    this.controller,
    this.hintText = '************',
    this.textInputAction = TextInputAction.next,
    this.onFieldSubmitted,
    this.onChanged,
  });

  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final String? hintText;
  final TextInputAction? textInputAction;
  final void Function(String?)? onFieldSubmitted;
  final void Function(String?)? onChanged;

  @override
  State<PassTextFormField> createState() => _PassTextFormFieldState();
}

class _PassTextFormFieldState extends State<PassTextFormField> {
  late final TextEditingController _controller;
  var _ownsController = false;
  var _visible = false;

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

    return TextFormField(
      controller: _controller,
      obscureText: !_visible,
      obscuringCharacter: '*',
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
      cursorColor: AppColors.primerColor,
      style: 16.regular.copyWith(color: hasData ? AppColors.black33 : null),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.cardSurface,
        hintText: widget.hintText,
        hintStyle: 15.regular.copyWith(color: AppColors.slate400),
        errorStyle: 12.medium.copyWith(color: AppColors.primerColorDark),
        contentPadding: const EdgeInsetsDirectional.only(
          start: 16,
          end: 16,
          top: 16,
          bottom: 16,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsetsDirectional.only(start: 14, end: 10),
          child: SvgPicture.asset(
            AppIcons.iconsLock,
            width: 20,
            height: 20,
            fit: BoxFit.scaleDown,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _visible = !_visible),
          icon: SvgPicture.asset(
            _visible ? AppIcons.iconsOpenEye : AppIcons.iconsClosedEye,
            width: 20,
            height: 20,
            fit: BoxFit.scaleDown,
            colorFilter: ColorFilter.mode(
              hasData ? AppColors.black33 : AppColors.greyB5,
              BlendMode.srcIn,
            ),
          ),
        ),
        border: customOutLineBorders(
          borderRadius: 14,
          borderColor: AppColors.slate200,
        ),
        enabledBorder: customOutLineBorders(
          borderRadius: 14,
          borderColor: AppColors.slate200,
          borderWidth: 1.0,
        ),
        disabledBorder: customOutLineBorders(
          borderRadius: 14,
          borderColor: AppColors.slate100,
        ),
        errorBorder: customOutLineBorders(
          borderRadius: 14,
          borderColor: AppColors.primerColorDark,
          borderWidth: 1.2,
        ),
        focusedBorder: customOutLineBorders(
          borderRadius: 14,
          borderColor: AppColors.primerColor,
          borderWidth: 1.6,
        ),
      ),
    );
  }
}
