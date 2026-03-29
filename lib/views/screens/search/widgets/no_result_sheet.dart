import 'package:flutter/material.dart';

class NoResultSheet extends StatelessWidget {
  final String? message;
  final VoidCallback onIncreaseRadius;
  final VoidCallback onDismiss;

  const NoResultSheet({
    super.key,
    this.message,
    required this.onIncreaseRadius,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 24),
            const Text(
              'No Items Found Nearby',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message ??
                  'We couldn\'t find any matching products within your current discovery radius. Try increasing the radius in your settings or search again with a different angle.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: onIncreaseRadius,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF004AAD),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Increase Discovery Radius',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onDismiss,
              child: Text(
                'Dismiss',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
