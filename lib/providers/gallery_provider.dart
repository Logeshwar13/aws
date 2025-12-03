// lib/providers/gallery_provider.dart

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../services/firebase_service.dart';
import '../models/gallery_item_model.dart';

class GalleryProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final FirebaseStorage _storage = FirebaseService.storage;
  List<GalleryItem> _items = [];
  bool _loading = false;

  List<GalleryItem> get items => _items;
  bool get loading => _loading;

  GalleryProvider() {
    fetchGallery();
  }

  Future<String?> _uploadImage(XFile imageFile) async {
    try {
      final id = const Uuid().v4();
      final fileName = imageFile.name;
      final ext = fileName.split('.').last;
      final finalFileName = 'gallery_$id.$ext';

      final bytes = await imageFile.readAsBytes();
      final ref = _storage.ref().child('gallery-images/$finalFileName');

      await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/$ext'),
      );

      final downloadUrl = await ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading gallery image: $e');
      return null;
    }
  }

  void _sort() {
    _items.sort((a, b) {
      final orderCompare = a.displayOrder.compareTo(b.displayOrder);
      if (orderCompare != 0) return orderCompare;
      return b.createdAt.compareTo(a.createdAt);
    });
  }

  Future<void> fetchGallery() async {
    _loading = true;
    notifyListeners();
    try {
      final querySnapshot = await _firestore
          .collection('gallery_items')
          .orderBy('display_order', descending: false)
          .orderBy('created_at', descending: true)
          .get();

      _items = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return GalleryItem.fromMap(data);
      }).toList();
      _sort();
    } catch (e) {
      debugPrint('Error fetching gallery: $e');
      _items = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<GalleryItem?> addItem({
    required String title,
    String? description,
    XFile? imageFile,
    required String monthYear,
    int displayOrder = 0,
    bool isActive = true,
  }) async {
    debugPrint('GalleryProvider: addItem called');
    String? imageUrl;
    if (imageFile != null) {
      debugPrint('GalleryProvider: Uploading image...');
      imageUrl = await _uploadImage(imageFile);
      debugPrint('GalleryProvider: Image uploaded: $imageUrl');
    }

    if (imageUrl == null || imageUrl.isEmpty) {
      throw Exception('Image upload failed. Please try again.');
    }

    final now = DateTime.now();
    final payload = {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'month_year': monthYear,
      'display_order': displayOrder,
      'is_active': isActive,
      'created_at': now.toIso8601String(),
    };
    try {
      debugPrint('GalleryProvider: Adding to Firestore...');
      final docRef = await _firestore.collection('gallery_items').add(payload);
      debugPrint('GalleryProvider: Item added with ID: ${docRef.id}');
      
      payload['id'] = docRef.id;
      final created = GalleryItem.fromMap(payload);
      
      // _items.insert(0, created);
      // _sort();
      // notifyListeners();
      return created;
    } catch (e) {
      debugPrint('GalleryProvider: Error adding gallery item: $e');
      rethrow;
    }
  }

  Future<GalleryItem?> updateItem(
    String id, {
    required String title,
    String? description,
    XFile? imageFile,
    required String existingImageUrl,
    required String monthYear,
    int displayOrder = 0,
    required bool isActive,
  }) async {
    String imageUrl = existingImageUrl;
    if (imageFile != null) {
      final uploaded = await _uploadImage(imageFile);
      if (uploaded != null && uploaded.isNotEmpty) {
        imageUrl = uploaded;
      }
    }

    final now = DateTime.now();
    final payload = {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'month_year': monthYear,
      'display_order': displayOrder,
      'is_active': isActive,
      'updated_at': now.toIso8601String(),
    };
    try {
      await _firestore.collection('gallery_items').doc(id).update(payload);
      final doc = await _firestore.collection('gallery_items').doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        final updated = GalleryItem.fromMap(data);
        _items = _items.map((g) => g.id == id ? updated : g).toList();
        _sort();
        notifyListeners();
        return updated;
      } else {
        throw Exception('Gallery item not found');
      }
    } catch (e) {
      debugPrint('Error updating gallery item: $e');
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _firestore.collection('gallery_items').doc(id).delete();
      _items.removeWhere((g) => g.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting gallery item: $e');
      rethrow;
    }
  }
}
