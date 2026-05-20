import 'package:flutter/material.dart';
// Import the opening‑hours model from the same package
import 'package:nearvendorapp/models/data_models/opening_hours.dart';

/// Simple widget to display opening hours for a shop.
class ShopTimingView extends StatelessWidget {
  final ShopOpeningHours openingHours;

  const ShopTimingView({super.key, required this.openingHours});

  @override
  Widget build(BuildContext context) {
    final dayMap = openingHours.toDaySchedules();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: dayMap.entries.map((e) {
        final day = e.key;
        final schedule = e.value;
        String text;
        if (!schedule.isOpen) {
          text = 'Closed';
        } else if (schedule.is24Hours) {
          text = 'Open 24 h';
        } else if (schedule.periods.isEmpty) {
          text = 'Open';
        } else {
          text = schedule.periods
              .map((p) => '${p.openTime} – ${p.closeTime}')
              .join(', ');
        }
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  day,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(child: Text(text)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
