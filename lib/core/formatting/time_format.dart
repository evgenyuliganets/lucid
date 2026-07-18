import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Times and days in the user's locale and 12/24-hour setting.
extension TimeFormatContext on BuildContext {
  String timeOfDay(TimeOfDay time) =>
      MaterialLocalizations.of(this).formatTimeOfDay(
        time,
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(this),
      );

  String clock(DateTime time) => timeOfDay(TimeOfDay.fromDateTime(time));

  String minuteOfDay(int minute) =>
      timeOfDay(TimeOfDay(hour: minute ~/ 60, minute: minute % 60));

  /// Short weekday name for an ISO weekday (1 = Monday).
  String weekdayShort(int weekday) => DateFormat.E(
    Localizations.localeOf(this).toLanguageTag(),
  ).format(DateTime(2024, 1, weekday));

  String dayMonth(DateTime date) => DateFormat.MMMEd(
    Localizations.localeOf(this).toLanguageTag(),
  ).format(date);
}
