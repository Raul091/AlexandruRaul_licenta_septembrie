import 'package:flutter/material.dart';

class Emotion{
  final String eventTitle;
  final String emotion;


  const Emotion({
    required this.eventTitle,
    required this.emotion,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventTitle': eventTitle,
      'emotion': emotion,
    };
  }

  static Emotion fromMap(Map<String, dynamic> map) {
    return Emotion(
      eventTitle: map['eventTitle'],
      emotion: map['emotion'],
    );
  }
}