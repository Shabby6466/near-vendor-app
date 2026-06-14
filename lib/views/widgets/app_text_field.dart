import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/helper_functions.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hint;
  final bool isPassword;
  final TextInputType? keyboardType;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final bool isMultiline;
  final Widget? suffixIcon;
  final void Function(String)? onChanged;
  final bool autofocus;
  final Widget? prefixIcon;
  final TextAlign? textAlign;
  final Widget? prefix;
  final TextStyle? style;
  final bool showBorder;

  const AppTextField({
    super.key,
    this.controller,
    this.textAlign,
    this.style,
    this.hint,
    this.isPassword = false,
    this.keyboardType,
    this.enabled = true,
    this.validator,
    this.isMultiline = false,
    this.suffixIcon,
    this.onChanged,
    this.autofocus = false,
    this.prefixIcon,
    this.prefix,
    this.showBorder = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final border = widget.showBorder
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          )
        : widget.isMultiline
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          )
        : null;

    final enabledBorder = widget.showBorder
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          )
        : widget.isMultiline
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          )
        : null;

    final focusedBorder = widget.showBorder
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          )
        : widget.isMultiline
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          )
        : null;

    final errorBorder = widget.showBorder
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: theme.colorScheme.error),
          )
        : null;

    final focusedErrorBorder = widget.showBorder
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
          )
        : null;

    final disabledBorder = widget.showBorder
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(100),
            borderSide: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          )
        : widget.isMultiline
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          )
        : null;

    final defaultStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontSize: 15,
      letterSpacing: 0.3,
    );

    return TextFormField(
      onTapOutside: (event) => hideKeyBoard(),
      autofocus: widget.autofocus,
      maxLines: widget.isMultiline ? 3 : 1,
      controller: widget.controller,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      textAlign: widget.textAlign ?? TextAlign.start,
      obscureText: _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: widget.style ?? defaultStyle,
      decoration:
          InputDecoration(
                hintText: widget.hint,
                prefix: widget.prefix,
                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: widget.prefixIcon,
                      )
                    : null,
                suffixIcon: widget.isPassword
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: theme.iconTheme.color?.withValues(alpha: 0.5),
                        ),
                      )
                    : widget.suffixIcon,
                errorMaxLines: 2,
              )
              .applyDefaults(theme.inputDecorationTheme)
              .copyWith(
                border: border,
                enabledBorder: enabledBorder,
                focusedBorder: focusedBorder,
                errorBorder: errorBorder,
                focusedErrorBorder: focusedErrorBorder,
                disabledBorder: disabledBorder,
              ),
    );
  }
}
