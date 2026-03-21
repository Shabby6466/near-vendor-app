import 'package:flutter/material.dart';
import 'package:nearvendorapp/utils/app_spacing.dart';

class AllReviewsScreen extends StatelessWidget {
  const AllReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('All Reviews', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(AppSpacing.mediumHorizontalSpacing(context)),
        itemCount: 10,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${index + 50}'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('User ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('2 days ago', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: List.generate(5, (starIndex) {
                          return Icon(
                            starIndex < 4 ? Icons.star : Icons.star_border,
                            size: 14,
                            color: Colors.amber,
                          );
                        }),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '"Best Products of my life everything went smoothly. Shop owner was very professional and honest"',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
