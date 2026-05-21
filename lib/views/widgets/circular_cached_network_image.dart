import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nearvendorapp/views/widgets/shimmer_effect.dart';

class CircularCachedNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CircularCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.size = 100,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder(context);
    }

    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        fit: fit,
        placeholder: (context, url) =>
            placeholder ?? ShimmerEffect(borderRadius: size / 2),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildPlaceholder(context),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        shape: BoxShape.circle,
      ),
      child: Icon(Icons.person, size: size * 0.6, color: Colors.white),
    );
  }
}
