import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';

class FirebaseService {
  static final FirebaseAuth auth = FirebaseAuth.instance;
  
  // Connect to the specific database 'aws-pudu' seen in your console
  static final FirebaseFirestore firestore = FirebaseFirestore.instanceFor(
    app: Firebase.app(), 
    databaseId: 'aws-pudu'
  );
  
  static final FirebaseStorage storage = FirebaseStorage.instance;

  // Collections
  static CollectionReference get eventsCollection =>
      firestore.collection('events');

  static CollectionReference get membersCollection =>
      firestore.collection('members');

  static CollectionReference get galleryCollection =>
      firestore.collection('gallery_items');

  static CollectionReference get contactsCollection =>
      firestore.collection('contacts');

  static CollectionReference get adminsCollection =>
      firestore.collection('admins');

  static CollectionReference get settingsCollection =>
      firestore.collection('settings');

  // Stats methods
  static Future<Map<String, dynamic>> fetchCommunityStats() async {
    try {
      final doc = await settingsCollection.doc('community_stats').get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return {
        'members': 0,
        'certified': 0,
        'projects': 0,
      };
    } catch (e) {
      debugPrint('Error fetching stats: $e');
      return {
        'members': 0,
        'certified': 0,
        'projects': 0,
      };
    }
  }

  static Future<void> updateCommunityStats(Map<String, dynamic> stats) async {
    try {
      await settingsCollection.doc('community_stats').set(stats, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating stats: $e');
      rethrow;
    }
  }

  // Storage references
  static Reference get eventImagesRef => storage.ref().child('event-images');

  static Reference get galleryImagesRef =>
      storage.ref().child('gallery-images');

  static Reference get speakerImagesRef =>
      storage.ref().child('speaker-images');

  // Helper methods
  static Future<bool> isAdmin() async {
    final user = auth.currentUser;
    if (user == null) {
      debugPrint('isAdmin: No user logged in');
      return false;
    }

    try {
      final adminDoc = await adminsCollection.doc(user.uid).get();
      final exists = adminDoc.exists;
      debugPrint('isAdmin: User ${user.uid} isAdmin=$exists');
      return exists;
    } catch (e) {
      debugPrint('isAdmin: Error checking admin status: $e');
      return false;
    }
  }

  // Contact methods
  static Future<void> postContact(Map<String, dynamic> payload) async {
    try {
      debugPrint('Attempting to post contact: $payload');
      final docRef = await contactsCollection.add(payload);
      debugPrint('Contact posted successfully with ID: ${docRef.id}');
    } catch (e) {
      debugPrint('Error posting contact: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> fetchContacts() async {
    try {
      final querySnapshot = await contactsCollection
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error fetching contacts: $e');
      return [];
    }
  }
}
