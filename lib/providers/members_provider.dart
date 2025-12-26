import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/member_model.dart';
import '../services/firebase_service.dart';

class MembersProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final FirebaseStorage _storage = FirebaseService.storage;
  List<MemberModel> _members = [];
  bool _loading = false;
  StreamSubscription<QuerySnapshot>? _membersSubscription;

  List<MemberModel> get members => _members;
  bool get loading => _loading;

  MembersProvider() {
    fetchMembers();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _membersSubscription?.cancel();
    super.dispose();
  }

  void _sortMembers() {
    _members.sort((a, b) {
      // 1. Sort by Category (Lead first)
      if (a.category == 'Lead' && b.category != 'Lead') return -1;
      if (a.category != 'Lead' && b.category == 'Lead') return 1;

      // 2. Sort by Display Order
      final orderCompare = a.displayOrder.compareTo(b.displayOrder);
      if (orderCompare != 0) return orderCompare;

      // 3. Sort by Created Date
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  Future<void> fetchMembers() async {
    _loading = true;
    notifyListeners();
    try {
      final querySnapshot = await _firestore
          .collection('members')
          .orderBy('created_at', descending: true)
          .get();

      _members = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MemberModel.fromMap(data);
      }).toList();
      _sortMembers();
    } catch (e) {
      debugPrint('Error fetching members: $e');
      _members = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<String?> _uploadImage(XFile imageFile) async {
    try {
      final id = const Uuid().v4();
      final fileName = imageFile.name;
      final ext = fileName.split('.').last;
      final finalFileName = 'member_$id.$ext';

      final bytes = await imageFile.readAsBytes();
      final ref = _storage.ref().child('member-profiles/$finalFileName');

      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/$ext'),
      );

      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading member image: $e');
      rethrow;
    }
  }

  Future<MemberModel?> addMember({
    required String name,
    required String role,
    required String email,
    String? avatar,
    // List<String> skills = const [],
    String? profileUrl, // Keep for backward compatibility or direct URL
    XFile? imageFile, // New image file
    String? bio,
    String? linkedinUrl,
    String? githubUrl,
    String? instagramUrl,
    // String? websiteUrl,
    int? displayOrder,
    bool isActive = true,
    String category = 'Member',
  }) async {
    debugPrint('MembersProvider: addMember called');
    
    String? finalProfileUrl = profileUrl;
    if (imageFile != null) {
      finalProfileUrl = await _uploadImage(imageFile);
    }

    final now = DateTime.now();
    final payload = {
      'name': name,
      'role': role,
      'email': email,
      'avatar': avatar,
      // 'skills': skills,
      'profile_url': finalProfileUrl,
      'bio': bio,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
      'instagram_url': instagramUrl,
      // 'website_url': websiteUrl,
      'display_order': displayOrder ?? 0,
      'is_active': isActive,
      'created_at': now.toIso8601String(),
      'category': category,
    };

    try {
      debugPrint('MembersProvider: Adding to Firestore...');
      final docRef = await _firestore.collection('members').add(payload);
      debugPrint('MembersProvider: Member added with ID: ${docRef.id}');
      
      payload['id'] = docRef.id;
      final member = MemberModel.fromMap(payload);
      return member;
    } catch (e) {
      debugPrint('MembersProvider: Error adding member: $e');
      rethrow;
    }
  }

  Future<MemberModel?> updateMember(
    String id, {
    required String name,
    required String role,
    required String email,
    String? avatar,
    // List<String> skills = const [],
    String? profileUrl,
    XFile? imageFile,
    String? bio,
    String? linkedinUrl,
    String? githubUrl,
    String? instagramUrl,
    // String? websiteUrl,
    int? displayOrder,
    required bool isActive,
    String? category,
  }) async {
    final now = DateTime.now();
    
    String? finalProfileUrl = profileUrl;
    if (imageFile != null) {
      finalProfileUrl = await _uploadImage(imageFile);
    }

    final payload = {
      'name': name,
      'role': role,
      'email': email,
      'avatar': avatar,
      // 'skills': skills,
      'profile_url': finalProfileUrl,
      'bio': bio,
      'linkedin_url': linkedinUrl,
      'github_url': githubUrl,
      'instagram_url': instagramUrl,
      // 'website_url': websiteUrl,
      'display_order': displayOrder ?? 0,
      'is_active': isActive,
      'updated_at': now.toIso8601String(),
    };
    
    if (category != null) {
      payload['category'] = category;
    }

    try {
      await _firestore.collection('members').doc(id).update(payload);
      final doc = await _firestore.collection('members').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        final updated = MemberModel.fromMap(data);
        _members = _members.map((m) => m.id == id ? updated : m).toList();
        _sortMembers();
        notifyListeners();
        return updated;
      } else {
        throw Exception('Member not found');
      }
    } catch (e) {
      debugPrint('Error updating member: $e');
      rethrow;
    }
  }

  Future<void> updateMemberFields(
      String id, Map<String, dynamic> changes) async {
    try {
      changes['updated_at'] = DateTime.now().toIso8601String();
      await _firestore.collection('members').doc(id).update(changes);

      final doc = await _firestore.collection('members').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        final updated = MemberModel.fromMap(data);
        _members = _members.map((m) => m.id == id ? updated : m).toList();
        _sortMembers();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating member fields: $e');
      rethrow;
    }
  }

  Future<void> deleteMember(String id) async {
    try {
      await _firestore.collection('members').doc(id).delete();
      _members.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting member: $e');
      rethrow;
    }
  }

  void _subscribeRealtime() {
    _membersSubscription = _firestore
        .collection('members')
        .orderBy('created_at', descending: true)
        .snapshots()
        .listen((snapshot) {
      _members = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return MemberModel.fromMap(data);
      }).toList();
      _sortMembers();
      notifyListeners();
    });
  }
}
