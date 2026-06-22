import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nearvendorapp/models/data_models/review.dart';
import 'package:nearvendorapp/models/data_models/shop.dart';
import 'package:nearvendorapp/services/review_services.dart';
import 'package:nearvendorapp/utils/navigation/app_navigation.dart';
import 'package:nearvendorapp/utils/ui/app_alerts.dart';
import 'package:nearvendorapp/views/widgets/loading_screen_view.dart';
import 'package:nearvendorapp/views/widgets/multi_image_picker.dart';
import 'package:nearvendorapp/views/widgets/rating_bar_widget.dart';

class AddEditReviewScreen extends StatefulWidget {
  final Shop shop;
  final Review? existingReview;

  const AddEditReviewScreen({
    super.key,
    required this.shop,
    this.existingReview,
  });

  @override
  State<AddEditReviewScreen> createState() => _AddEditReviewScreenState();
}

class _AddEditReviewScreenState extends State<AddEditReviewScreen> {
  final ReviewServices _reviewServices = ReviewServices();
  final TextEditingController _textController = TextEditingController();
  double _rating = 0;
  final List<File> _images = [];
  final List<String> _existingUrls = [];
  bool _isSubmitting = false;

  bool get _isEditing => widget.existingReview != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _rating = (widget.existingReview!.rating ?? 0).toDouble();
      _textController.text = widget.existingReview!.text ?? '';
      _existingUrls.addAll(widget.existingReview!.images);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating < 1) {
      AppAlerts.showError(context, 'Please select a rating');
      return;
    }

    setState(() => _isSubmitting = true);

    final response = _isEditing
        ? await _reviewServices.updateReview(
            reviewId: widget.existingReview!.id!,
            rating: _rating.round(),
            text: _textController.text.trim(),
            newImages: _images,
            existingImageUrls: _existingUrls,
          )
        : await _reviewServices.createReview(
            shopId: widget.shop.id!,
            rating: _rating.round(),
            text: _textController.text.trim(),
            images: _images,
          );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (response.isSuccess) {
        AppAlerts.showSuccess(
          context,
          _isEditing ? 'Review updated' : 'Review posted',
        );
        AppNavigator.pop(context);
      } else {
        AppAlerts.showError(
          context,
          response.message ?? 'Something went wrong',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Review' : 'Write a Review'),
      ),
      body: LoadingScreenView(
        isLoading: _isSubmitting,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Text(
                      widget.shop.shopName ?? 'Shop',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap to rate',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color
                            ?.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    RatingBarInput(
                      initialRating: _rating,
                      itemSize: 48,
                      onRatingUpdate: (rating) =>
                          setState(() => _rating = rating),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'Review',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                maxLines: 5,
                maxLength: 2000,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Photos (optional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              MultiImagePicker(
                initialImageUrls: _existingUrls,
                onImagesChanged: (images) => setState(() {
                  _images.clear();
                  _images.addAll(images);
                }),
                onImageUrlsChanged: (urls) => setState(() {
                  _existingUrls.clear();
                  _existingUrls.addAll(urls);
                }),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Update Review' : 'Post Review',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
