import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Represents a single time period within a day.
class TimePeriod extends Equatable {
  final String openTime; // "HH:mm" 24‑hour format
  final String closeTime; // "HH:mm" 24‑hour format

  const TimePeriod({required this.openTime, required this.closeTime});

  factory TimePeriod.fromJson(Map<String, dynamic> json) => TimePeriod(
    openTime: json['openTime'] as String,
    closeTime: json['closeTime'] as String,
  );

  Map<String, dynamic> toJson() => {
    'openTime': openTime,
    'closeTime': closeTime,
  };

  @override
  List<Object?> get props => [openTime, closeTime];
}

/// Schedule for a single day.
class DaySchedule extends Equatable {
  final bool isOpen;
  final bool is24Hours;
  final List<TimePeriod> periods;

  const DaySchedule({
    this.isOpen = true,
    this.is24Hours = false,
    this.periods = const [],
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) => DaySchedule(
    isOpen: json['isOpen'] as bool? ?? true,
    is24Hours: json['is24Hours'] as bool? ?? false,
    periods:
        (json['periods'] as List<dynamic>?)
            ?.map((e) => TimePeriod.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'isOpen': isOpen,
    'is24Hours': is24Hours,
    'periods': periods.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [isOpen, is24Hours, periods];
}

/// Single period used by Google‑Maps‑style opening hours.
class OpeningHoursPeriod extends Equatable {
  final int openDay; // 0=Sunday … 6=Saturday
  final String openTime;
  final int closeDay;
  final String closeTime;

  const OpeningHoursPeriod({
    required this.openDay,
    required this.openTime,
    required this.closeDay,
    required this.closeTime,
  });

  factory OpeningHoursPeriod.fromJson(Map<String, dynamic> json) =>
      OpeningHoursPeriod(
        openDay: json['openDay'] as int,
        openTime: json['openTime'] as String,
        closeDay: json['closeDay'] as int,
        closeTime: json['closeTime'] as String,
      );

  Map<String, dynamic> toJson() => {
    'openDay': openDay,
    'openTime': openTime,
    'closeDay': closeDay,
    'closeTime': closeTime,
  };

  @override
  List<Object?> get props => [openDay, openTime, closeDay, closeTime];
}

/// Main container for opening hours, mirroring the backend format.
class ShopOpeningHours extends Equatable {
  final String timezone;
  final List<OpeningHoursPeriod> periods;

  const ShopOpeningHours({
    this.timezone = 'Asia/Karachi',
    this.periods = const [],
  });

  factory ShopOpeningHours.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return const ShopOpeningHours();

    final timezone = json['timezone'] as String? ?? 'Asia/Karachi';

    // If it has 'periods', it's the complex format.
    if (json.containsKey('periods') && json['periods'] is List) {
      return ShopOpeningHours(
        timezone: timezone,
        periods: (json['periods'] as List<dynamic>)
            .whereType<Map>()
            .map((p) => OpeningHoursPeriod.fromJson(
                  Map<String, dynamic>.from(p),
                ))
            .toList(),
      );
    }

    final periods = <OpeningHoursPeriod>[];
    const dayKeys = {
      'mon': 1,
      'tue': 2,
      'wed': 3,
      'thu': 4,
      'fri': 5,
      'sat': 6,
      'sun': 0,
    };
    const fullDayKeys = {
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
      'sunday': 0,
    };

    void addPeriod(int dayIdx, String openTime, String closeTime) {
      if (openTime.isEmpty || closeTime.isEmpty) return;
      periods.add(OpeningHoursPeriod(
        openDay: dayIdx,
        openTime: openTime,
        closeDay: dayIdx,
        closeTime: closeTime,
      ));
    }

    void addRange(int dayIdx, String rawRange) {
      final value = rawRange.trim();
      if (value.isEmpty || value.toLowerCase() == 'closed') return;
      final parts = value.split('-');
      if (parts.length == 2) {
        addPeriod(dayIdx, parts[0].trim(), parts[1].trim());
      }
    }

    json.forEach((rawKey, value) {
      final key = rawKey.toLowerCase();
      final dayIdx = dayKeys[key] ?? fullDayKeys[key];
      if (dayIdx == null) return;

      if (value is String) {
        addRange(dayIdx, value);
        return;
      }

      if (value is Map) {
        final schedule = Map<String, dynamic>.from(value);
        final isOpen = schedule['isOpen'] as bool? ?? true;
        if (!isOpen) return;

        final is24Hours = schedule['is24Hours'] as bool? ?? false;
        if (is24Hours) {
          addPeriod(dayIdx, '00:00', '23:59');
          return;
        }

        final slots = schedule['periods'];
        if (slots is List && slots.isNotEmpty) {
          for (final slot in slots.whereType<Map>()) {
            final period = TimePeriod.fromJson(
              Map<String, dynamic>.from(slot),
            );
            addPeriod(dayIdx, period.openTime, period.closeTime);
          }
        } else {
          final openTime = schedule['openTime'] as String? ?? '09:00';
          final closeTime = schedule['closeTime'] as String? ?? '21:00';
          addPeriod(dayIdx, openTime, closeTime);
        }
      }
    });

    return ShopOpeningHours(
      timezone: timezone,
      periods: periods,
    );
  }

  Map<String, dynamic> toJson() => {
    'timezone': timezone,
    'periods': periods.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [timezone, periods];

  /// Convert to UI‑friendly day map.
  Map<String, DaySchedule> toDaySchedules() {
    const dayNames = [
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    final dayMap = <String, DaySchedule>{};
    final grouped = <int, List<OpeningHoursPeriod>>{};
    for (final p in periods) {
      grouped.putIfAbsent(p.openDay, () => []).add(p);
    }
    for (var i = 0; i < 7; i++) {
      final name = dayNames[i];
      final list = grouped[i];
      if (list == null || list.isEmpty) {
        dayMap[name] = const DaySchedule(isOpen: false);
      } else if (list.length == 1 &&
          list[0].openTime == '00:00' &&
          list[0].closeTime == '23:59') {
        dayMap[name] = const DaySchedule(is24Hours: true);
      } else {
        dayMap[name] = DaySchedule(
          periods: list
              .map(
                (p) => TimePeriod(openTime: p.openTime, closeTime: p.closeTime),
              )
              .toList(),
        );
      }
    }
    return dayMap;
  }

  /// Convert from UI‑friendly day map.
  static ShopOpeningHours fromDaySchedules(Map<String, DaySchedule> schedules) {
    const dayIndex = {
      'Monday': 1,
      'Tuesday': 2,
      'Wednesday': 3,
      'Thursday': 4,
      'Friday': 5,
      'Saturday': 6,
      'Sunday': 0,
    };
    final periods = <OpeningHoursPeriod>[];
    schedules.forEach((day, schedule) {
      final idx = dayIndex[day] ?? 0;
      if (!schedule.isOpen) return;
      if (schedule.is24Hours) {
        periods.add(
          OpeningHoursPeriod(
            openDay: idx,
            openTime: '00:00',
            closeDay: idx,
            closeTime: '23:59',
          ),
        );
      } else {
        for (final p in schedule.periods) {
          periods.add(
            OpeningHoursPeriod(
              openDay: idx,
              openTime: p.openTime,
              closeDay: idx,
              closeTime: p.closeTime,
            ),
          );
        }
      }
    });
    return ShopOpeningHours(periods: periods);
  }

  /// Returns the current open/closed status info for the shop.
  ShopStatusInfo getStatusInfo([DateTime? referenceTime]) {
    final now = referenceTime ?? DateTime.now();
    
    if (periods.isEmpty) {
      return const ShopStatusInfo(
        isOpen: false,
        statusText: 'Closed',
        timeDetails: 'No opening hours set',
        statusColor: Color(0xFFE57373), // Soft Red
      );
    }

    // 0=Sunday, 1=Monday, ..., 6=Saturday
    final currentDay = now.weekday % 7;
    final currentMinutes = now.hour * 60 + now.minute;
    final currentWeekMinutes = currentDay * 1440 + currentMinutes;

    OpeningHoursPeriod? activePeriod;
    for (final p in periods) {
      final start = p.openDay * 1440 + _parseTimeToMinutes(p.openTime);
      final end = p.closeDay * 1440 + _parseTimeToMinutes(p.closeTime);
      bool inPeriod = false;
      if (end >= start) {
        inPeriod = currentWeekMinutes >= start && currentWeekMinutes <= end;
      } else {
        inPeriod = currentWeekMinutes >= start || currentWeekMinutes <= end;
      }
      if (inPeriod) {
        activePeriod = p;
        break;
      }
    }

    if (activePeriod != null) {
      if (activePeriod.openTime == '00:00' && activePeriod.closeTime == '23:59') {
        return const ShopStatusInfo(
          isOpen: true,
          statusText: 'Open',
          timeDetails: 'Open 24 hours',
          statusColor: Color(0xFF81C784), // Soft Green
        );
      }

      final start = activePeriod.openDay * 1440 + _parseTimeToMinutes(activePeriod.openTime);
      final end = activePeriod.closeDay * 1440 + _parseTimeToMinutes(activePeriod.closeTime);
      int remainingMinutes = 0;
      if (end >= start) {
        remainingMinutes = end - currentWeekMinutes;
      } else {
        remainingMinutes = (end + 10080) - currentWeekMinutes;
      }

      final closeTimeFormatted = _format12Hour(activePeriod.closeTime);
      String dayDetails = '';
      if (activePeriod.closeDay != currentDay) {
        const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        if (activePeriod.closeDay == (currentDay + 1) % 7) {
          dayDetails = 'tomorrow ';
        } else {
          dayDetails = '${dayNames[activePeriod.closeDay]} ';
        }
      }

      if (remainingMinutes > 0 && remainingMinutes <= 60) {
        return ShopStatusInfo(
          isOpen: true,
          statusText: 'Closing soon',
          timeDetails: 'Closes $dayDetails$closeTimeFormatted',
          statusColor: const Color(0xFFFFB74D), // Soft Orange
        );
      }

      return ShopStatusInfo(
        isOpen: true,
        statusText: 'Open now',
        timeDetails: 'Closes $dayDetails$closeTimeFormatted',
        statusColor: const Color(0xFF81C784), // Soft Green
      );
    }

    // Closed - find the next opening period
    OpeningHoursPeriod? nextPeriod;
    int minDiff = 10080; // cyclic week difference

    for (final p in periods) {
      final start = p.openDay * 1440 + _parseTimeToMinutes(p.openTime);
      int diff = start - currentWeekMinutes;
      if (diff < 0) {
        diff += 10080;
      }
      if (diff < minDiff) {
        minDiff = diff;
        nextPeriod = p;
      }
    }

    if (nextPeriod != null) {
      final openTimeFormatted = _format12Hour(nextPeriod.openTime);
      String dayDetails = 'at ';
      if (nextPeriod.openDay != currentDay) {
        const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
        if (nextPeriod.openDay == (currentDay + 1) % 7) {
          dayDetails = 'tomorrow at ';
        } else {
          dayDetails = '${dayNames[nextPeriod.openDay]} at ';
        }
      }

      if (minDiff > 0 && minDiff <= 60) {
        return ShopStatusInfo(
          isOpen: false,
          statusText: 'Opening soon',
          timeDetails: 'Opens $dayDetails$openTimeFormatted',
          statusColor: const Color(0xFFFFB74D), // Soft Orange
        );
      }

      return ShopStatusInfo(
        isOpen: false,
        statusText: 'Closed',
        timeDetails: 'Opens $dayDetails$openTimeFormatted',
        statusColor: const Color(0xFFE57373), // Soft Red
      );
    }

    return const ShopStatusInfo(
      isOpen: false,
      statusText: 'Closed',
      timeDetails: 'Closed',
      statusColor: Color(0xFFE57373),
    );
  }

  static int _parseTimeToMinutes(String time) {
    try {
      final parts = time.split(':');
      if (parts.length != 2) return 0;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return hour * 60 + minute;
    } catch (_) {
      return 0;
    }
  }

  static String _format12Hour(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length != 2) return time24;
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      final minuteStr = minute.toString().padLeft(2, '0');
      return '$hour12:$minuteStr $period';
    } catch (_) {
      return time24;
    }
  }
}

/// Representation of the shop open/closed status for UI.
class ShopStatusInfo {
  final bool isOpen;
  final String statusText;
  final String timeDetails;
  final Color statusColor;

  const ShopStatusInfo({
    required this.isOpen,
    required this.statusText,
    required this.timeDetails,
    required this.statusColor,
  });
}
