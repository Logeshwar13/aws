// lib/models/gallery_item_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GalleryItem {
  final String id;
  final String title;
  final String? description;
  final String imageUrl;
  final String monthYear; // e.g. "May 2025"
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int displayOrder;
  final bool isActive;

  GalleryItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.monthYear,
    required this.createdAt,
    this.description,
    this.updatedAt,
    this.displayOrder = 0,
    this.isActive = true,
  });

  factory GalleryItem.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is String) return DateTime.parse(val);
      return DateTime.now();
    }

    return GalleryItem(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String?,
      imageUrl: map['image_url'] as String? ?? '',
      monthYear: map['month_year'] as String? ?? '',
      createdAt: parseDate(map['created_at']),
      updatedAt: map['updated_at'] != null ? parseDate(map['updated_at']) : null,
      displayOrder: (map['display_order'] as int?) ?? 0,
      isActive: map['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'month_year': monthYear,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }
}
