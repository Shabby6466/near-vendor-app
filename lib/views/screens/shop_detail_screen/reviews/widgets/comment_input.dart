import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nearvendorapp/views/widgets/loading_animation.dart';
import 'package:nearvendorapp/views/widgets/multi_image_picker.dart';

class CommentInput extends StatefulWidget {
  final Future<bool> Function(String text, List<File> images) onSubmit;
  final bool isSubmitting;

  const CommentInput({
    super.key,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _controller = TextEditingController();
  final List<File> _images = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _images.isEmpty) return;

    final success = await widget.onSubmit(text, _images);
    if (success && mounted) {
      _controller.clear();
      setState(() => _images.clear());
    }
  }

  void _openImagePicker() {
    MultiImagePicker.showPickerSheet(
      context: context,
      onPicked: (file) {
        if (!mounted) return;
        if (_images.length >= 5) return;
        setState(() => _images.add(file));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          border: Border(
            top: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_images.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MultiImagePicker(
                  initialImages: _images,
                  onImagesChanged: (images) {
                    setState(() {
                      _images.clear();
                      _images.addAll(images);
                    });
                  },
                ),
              ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: theme.primaryColor,
                    size: 22,
                  ),
                  onPressed: _openImagePicker,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: 3,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      hintText: 'Write a comment...',
                      hintStyle: TextStyle(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.15),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: theme.dividerColor.withValues(alpha: 0.15),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: theme.primaryColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: widget.isSubmitting ? null : _submit,
                  icon: widget.isSubmitting
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: LoadingAnimation(
                            color: theme.primaryColor,
                            size: 18,
                          ),
                        )
                      : Icon(Icons.send_rounded, color: theme.primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
