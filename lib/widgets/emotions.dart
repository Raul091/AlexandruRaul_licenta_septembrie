import 'package:flutter/material.dart';

class Emotion{
  final String eventTitle;
  final String emotion;
  final DateTime start;

  const Emotion({
    required this.eventTitle,
    required this.emotion,
    required this.start,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventTitle': eventTitle,
      'emotion': emotion,
      'start': start.toIso8601String(),
    };
  }

  static Emotion fromMap(Map<String, dynamic> map) {
    return Emotion(
      eventTitle: map['eventTitle'],
      emotion: map['emotion'],
      start: DateTime.parse(map['start']),
    );
  }
}

class chartEmotion{
  final String emotion;
  final String dateTime;


  const chartEmotion({
    required this.emotion,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'emotion': emotion,
      'date': dateTime,
    };
  }

  static chartEmotion fromMap(Map<String, dynamic> map) {
    return chartEmotion(
      emotion: map['emotion'],
      dateTime: map['date'],
    );
  }
}

