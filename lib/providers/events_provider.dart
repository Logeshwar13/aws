// lib/providers/events_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../models/event_model.dart';
import '../services/firebase_service.dart';

enum EventFilterType { upcoming, history }

class EventsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseService.firestore;
  final FirebaseStorage _storage = FirebaseService.storage;
  List<EventModel> _events = [];
  bool _loading = false;
  StreamSubscription<QuerySnapshot>? _eventsSubscription;

  EventFilterType _filterType = EventFilterType.upcoming;

  List<EventModel> get events => _events;
  bool get loading => _loading;
  EventFilterType get filterType => _filterType;

  List<EventModel> get filteredEvents {
    final now = DateTime.now();
    if (_filterType == EventFilterType.upcoming) {
      return _events.where((e) => e.eventDate.isAfter(now) || e.eventDate.isAtSameMomentAs(now)).toList();
    } else {
      // For history, we might want to show newest first (descending)
      final history = _events.where((e) => e.eventDate.isBefore(now)).toList();
      history.sort((a, b) => b.eventDate.compareTo(a.eventDate));
      return history;
    }
  }

  void setFilterType(EventFilterType type) {
    _filterType = type;
    notifyListeners();
  }

  EventsProvider() {
    fetchEvents();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchEvents() async {
    _loading = true;
    notifyListeners();

    try {
      final querySnapshot = await _firestore
          .collection('events')
          .orderBy('event_date', descending: false)
          .get();

      _events = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EventModel.fromMap(data);
      }).toList();

      // Auto-switch to history if no upcoming events
      final now = DateTime.now();
      final hasUpcoming = _events.any((e) => e.eventDate.isAfter(now) || e.eventDate.isAtSameMomentAs(now));
      if (!hasUpcoming && _events.isNotEmpty) {
        _filterType = EventFilterType.history;
      }
    } catch (e) {
      debugPrint('Error fetching events: $e');
      _events = [];
    }

    _loading = false;
    notifyListeners();
  }

  Future<EventModel?> createEvent({
    required String title,
    required String description,
    required DateTime eventDate,
    required String location,
    XFile? imageFile,
    String? registrationLink,
    bool isFeatured = false,
  }) async {
    debugPrint('EventsProvider: createEvent called');
    String? imageUrl;
    if (imageFile != null) {
      try {
        debugPrint('EventsProvider: Uploading image...');
        final id = const Uuid().v4();
        final fileName = imageFile.name;
        final ext = fileName.split('.').last;
        final finalFileName = 'event_$id.$ext';

        final bytes = await imageFile.readAsBytes();
        final ref = _storage.ref().child('event-images/$finalFileName');

        await ref.putData(
          bytes,
          SettableMetadata(contentType: 'image/$ext'),
        );

        imageUrl = await ref.getDownloadURL();
        debugPrint('EventsProvider: Image uploaded: $imageUrl');
      } catch (e) {
        debugPrint('EventsProvider: Error uploading image: $e');
        rethrow;
      }
    }

    final now = DateTime.now();
    final data = {
      'title': title,
      'description': description,
      'event_date': eventDate.toIso8601String(),
      'location': location,
      'image_url': imageUrl,
      'registration_link': registrationLink,
      'is_featured': isFeatured,
      'created_at': now.toIso8601String(),
    };

    try {
      debugPrint('EventsProvider: Adding to Firestore...');
      final docRef = await _firestore.collection('events').add(data);
      debugPrint('EventsProvider: Document added with ID: ${docRef.id}');
      
      // Construct model from local data + new ID
      data['id'] = docRef.id;
      final e = EventModel.fromMap(data);
      
      // We don't strictly need to insert into _events if the stream is active,
      // but it doesn't hurt for immediate UI feedback.
      // _events.insert(0, e); 
      // notifyListeners();
      
      return e;
    } catch (e) {
      debugPrint('EventsProvider: Error creating event: $e');
      throw Exception('Error creating event: $e');
    }
  }

  Future<void> updateEvent(String id, Map<String, dynamic> changes) async {
    try {
      await _firestore.collection('events').doc(id).update(changes);

      final doc = await _firestore.collection('events').doc(id).get();
      if (doc.exists) {
        final updatedData = doc.data()!;
        updatedData['id'] = doc.id;
        final updated = EventModel.fromMap(updatedData);
        _events = _events.map((e) => e.id == id ? updated : e).toList();
        notifyListeners();
      } else {
        throw Exception('Update failed - document not found');
      }
    } catch (e) {
      debugPrint('Error updating event: $e');
      throw Exception('Error updating event: $e');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _firestore.collection('events').doc(id).delete();
      _events.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting event: $e');
      throw Exception('Error deleting event: $e');
    }
  }

  void _subscribeRealtime() {
    _eventsSubscription = _firestore
        .collection('events')
        .orderBy('event_date', descending: false)
        .snapshots()
        .listen((snapshot) {
      _events = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EventModel.fromMap(data);
      }).toList();
      notifyListeners();
    });
  }
}
