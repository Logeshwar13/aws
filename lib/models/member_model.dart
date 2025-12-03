import 'package:cloud_firestore/cloud_firestore.dart';

class MemberModel {
  final String id;
  final String name;
  final String role;
  final String email;
  final String? avatar;
  final String? profileUrl;
  final String? bio;
  final String? linkedinUrl;
  final String? githubUrl;
  final String? instagramUrl;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final String category; // 'Lead' or 'Member'

  MemberModel({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.avatar,
    this.profileUrl,
    this.bio,
    this.linkedinUrl,
    this.githubUrl,
    this.instagramUrl,
    this.displayOrder = 0,
    this.isActive = true,
    required this.createdAt,
    this.category = 'Member',
  });

  String get initials {
    if (avatar != null && avatar!.isNotEmpty) return avatar!;
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'role': role,
      'email': email,
      'avatar': avatar,
      'profile_url': profileUrl,
      'bio': bio,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
      'instagram_url': instagramUrl,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'category': category,
    };
  }

  factory MemberModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.parse(date);
      return DateTime.now();
    }

    return MemberModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      email: map['email'] ?? '',
      avatar: map['avatar'],
      profileUrl: map['profile_url'] ?? map['image_url'], // Fallback
      bio: map['bio'],
      linkedinUrl: map['linkedin_url'],
      githubUrl: map['github_url'],
      instagramUrl: map['instagram_url'] ?? map['twitter_url'], // Fallback
      displayOrder: map['display_order'] ?? 0,
      isActive: map['is_active'] ?? true,
      createdAt: parseDate(map['created_at']),
      category: map['category'] ?? 'Member',
    );
  }
}
