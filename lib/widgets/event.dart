import 'package:flutter/material.dart';

class Event{
  final String title;
  final String description;
  final DateTime start;
  final DateTime end;
  final Color bacckgroundColor;
  final bool isAllDay;

  const Event({
    required this.title,
    required this.description,
    required this.start,
    required this.end,
    this.bacckgroundColor = Colors.lightGreen,
    this.isAllDay = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
      'isAllDay': isAllDay,
    };
  }

  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      title: map['title'],
      description: map['description'],
      start: DateTime.parse(map['start']),
      end: DateTime.parse(map['end']),
      isAllDay: map['isAllDay'],
    );
  }
}