import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:nearvendorapp/models/data_models/item_model.dart';

class VisualSearchResultSheet extends StatelessWidget {
  final List<Item> items;
  final VoidCallback onAccept;
  final VoidCallback onTryAgain;

  const VisualSearchResultSheet({
    super.key,
    required this.items,
    required this.onAccept,
    required this.onTryAgain,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final item = items.first;
    final score = item.visualScore ?? 0.0;
    final matchPercentage = (score * 100).toInt();
    final isNearby = (item.distanceM ?? 999999) < 50000;

    String matchLabel;
    String matchDescription;
    Color matchColor;

    if (score > 0.8) {
      matchLabel = 'STRONG MATCH';
      matchDescription = 'same or very similar product';
      matchColor = const Color(0xFF004AAD);
    } else if (score > 0.6) {
      matchLabel = 'GOOD MATCH';
      matchDescription = 'same category, similar appearance';
      matchColor = const Color(0xFF1EC091);
    } else {
      matchLabel = 'WEAK MATCH';
      matchDescription = 'loosely related';
      matchColor = Colors.orange;
    }

    if (!isNearby) {
      matchLabel = 'NOT FOUND NEARBY';
      matchDescription = 'similar product suggestions';
      matchColor = Colors.orange[800]!;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: item.imageUrl ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              matchLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: matchColor,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              matchDescription,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Poppins',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: matchColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$matchPercentage%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: matchColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${item.description} • ${item.unit}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: 'Poppins',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004AAD),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                            isNearby
                                ? Icons.check_circle_outline
                                : Icons.shopping_basket_outlined,
                            size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isNearby ? "Yes, that's it" : "View suggestions",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onTryAgain,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF004AAD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.refresh, size: 20, color: Color(0xFF004AAD)),
                        SizedBox(width: 8),
                        Text("Try again",
                            style: TextStyle(
                                color: Color(0xFF004AAD),
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (isNearby) ...[
              const Divider(),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('LOWEST PRICE',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('RS ${item.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF1EC091))),
                      ],
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 40,
                      color: isDark ? Colors.grey[800] : Colors.grey[200]),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('STORES NEAR',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(height: 4),
                        Text('${items.length} Shops',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF004AAD))),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
