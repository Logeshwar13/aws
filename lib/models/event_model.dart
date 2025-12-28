// lib/models/event_model.dart
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String location;
  final String? imageUrl;
  final String? registrationLink;
  final bool isFeatured;
  final DateTime createdAt;
  final String? mode; // 'Online' or 'Offline'
  final DateTime? endTime;
  final String? speakers;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.location,
    this.imageUrl,
    this.registrationLink,
    this.isFeatured = false,
    required this.createdAt,
    this.mode,
    this.endTime,
    this.speakers,
  });

  factory EventModel.fromMap(Map<String, dynamic> m) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.parse(val);
      return DateTime.now(); // Fallback
    }

    DateTime? parseNullableDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.parse(val);
      return null;
    }

    return EventModel(
      id: m['id'] as String? ?? '',
      title: m['title'] as String? ?? '',
      description: m['description'] as String? ?? '',
      eventDate: parseDate(m['event_date']),
      location: m['location'] as String? ?? '',
      imageUrl: m['image_url'] as String?,
      registrationLink: m['registration_link'] as String?,
      isFeatured: m['is_featured'] as bool? ?? false,
      createdAt: parseDate(m['created_at']),
      mode: m['mode'] as String?,
      endTime: parseNullableDate(m['end_time']),
      speakers: m['speakers'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'image_url': imageUrl,
      'registration_link': registrationLink,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'mode': mode,
      'end_time': endTime?.toIso8601String(),
      'speakers': speakers,
    };
  }

  String get formattedDate => DateFormat.yMMMMd().add_jm().format(eventDate);
  String get formattedDateShort => DateFormat.MMMd().format(eventDate);
  String get formattedTime => DateFormat.jm().format(eventDate);
  String get formattedEndTime => endTime != null ? DateFormat.jm().format(endTime!) : '';
}
