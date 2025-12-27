import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final bool autofocus;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final TextAlign? textAlign;
  final Widget? prefix;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final EdgeInsetsGeometry? contentPadding;
  final Color? hintColor;

  const AppTextField({
    super.key,
    this.controller,
    this.textAlign,
    this.contentPadding,
    this.hintColor,
    this.hint,
    this.isPassword = false,
    this.keyboardType,
    this.enabled = true,
    this.validator,
    this.isMultiline = false,
    this.suffixIcon,
    this.onChanged,
    this.textInputAction,
    this.onFieldSubmitted,
    this.autofocus = false,
    this.onTap,
    this.prefixIcon,
    this.inputFormatters,
    this.prefix,
    this.autofillHints,
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: widget.onTap,
          customBorder: Theme.of(context).inputDecorationTheme.border,
          child: IgnorePointer(
            ignoring: widget.onTap != null,
            child: TextFormField(
              autofillHints: widget.autofillHints,
              inputFormatters: widget.inputFormatters,
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
              textInputAction: widget.textInputAction,
              onFieldSubmitted: widget.onFieldSubmitted,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.black),
              decoration:
                  InputDecoration(
                        contentPadding: widget.contentPadding,
                        hintStyle: TextStyle(
                          color:
                              widget.hintColor ??
                              Colors.black.withValues(alpha: 0.5),
                        ),
                      )
                      .applyDefaults(Theme.of(context).inputDecorationTheme)
                      .copyWith(
                        focusedBorder: widget.isMultiline
                            ? OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              )
                            : null,
                        enabledBorder: widget.isMultiline
                            ? OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              )
                            : null,
                        disabledBorder: widget.isMultiline
                            ? OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              )
                            : null,
                        hintText: widget.hint,
                        prefix: widget.prefix,
                        prefixIcon: widget.prefixIcon != null
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
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
                                ),
                              )
                            : widget.suffixIcon,
                        errorMaxLines: 2,
                      ),
            ),
          ),
        ),
      ],
    );
  }
}
