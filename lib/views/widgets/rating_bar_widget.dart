import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingBarWidget extends StatelessWidget {
  final double rating;
  final double itemSize;
  final Color? color;

  const RatingBarWidget.display({
    super.key,
    required this.rating,
    this.itemSize = 16,
    this.color,
  });

  const RatingBarWidget.input({
    super.key,
    required this.rating,
    this.itemSize = 40,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RatingBarIndicator(
      rating: rating,
      itemSize: itemSize,
      unratedColor: theme.dividerColor.withValues(alpha: 0.3),
      itemBuilder: (context, _) =>
          Icon(Icons.star_rounded, color: color ?? Colors.amber),
    );
  }
}

class RatingBarInput extends StatefulWidget {
  final double initialRating;
  final double itemSize;
  final ValueChanged<double>? onRatingUpdate;

  const RatingBarInput({
    super.key,
    this.initialRating = 0,
    this.itemSize = 40,
    this.onRatingUpdate,
  });

  @override
  State<RatingBarInput> createState() => _RatingBarInputState();
}

class _RatingBarInputState extends State<RatingBarInput> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return RatingBar.builder(
      initialRating: widget.initialRating,
      minRating: 1,
      itemSize: widget.itemSize,
      unratedColor: theme.dividerColor.withValues(alpha: 0.3),
      itemPadding: const EdgeInsets.symmetric(horizontal: 4),
      itemBuilder: (context, _) =>
          const Icon(Icons.star_rounded, color: Colors.amber),
      onRatingUpdate: (rating) {
        widget.onRatingUpdate?.call(rating);
      },
    );
  }
}
