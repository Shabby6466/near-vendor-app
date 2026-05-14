import 'package:equatable/equatable.dart';

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
    if (json == null) return const ShopOpeningHours();
    return ShopOpeningHours(
      timezone: json['timezone'] as String? ?? 'Asia/Karachi',
      periods:
          (json['periods'] as List<dynamic>?)
              ?.map(
                (e) => OpeningHoursPeriod.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
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
        dayMap[name] = const DaySchedule(isOpen: true, is24Hours: true);
      } else {
        dayMap[name] = DaySchedule(
          isOpen: true,
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
}
