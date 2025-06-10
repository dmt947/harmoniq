import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:harmoniq/models/music_project.dart';

class ProjectService {
  // Singleton Pattern
  static final ProjectService _instance = ProjectService._internal();

  factory ProjectService() {
    return _instance;
  }

  ProjectService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  ///
  CollectionReference<Map<String, dynamic>> _getProjectsCollectionRef() {
    if (_currentUserId == null) {}
    return _firestore.collection('users/$_currentUserId/projects');
  }

  Future<void> saveProject(MusicProject project) async {
    if (_currentUserId == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
      );
    }

    final collectionRef = _getProjectsCollectionRef();
    final docRef = collectionRef.doc(project.id);

    try {
      await docRef.set(project.toJson(), SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<MusicProject>> getProjects() {
    if (_currentUserId == null) {
      return Stream.value([]);
    }

    final collectionRef = _getProjectsCollectionRef();

    return collectionRef.orderBy('name').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return MusicProject.fromJson(doc.data());
        } catch (e) {
          return MusicProject.empty(name: "Error (ID: ${doc.id})");
        }
      }).toList();
    });
  }

  Future<void> deleteProject(String projectId) async {
    if (_currentUserId == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
      );
    }

    final docRef = _getProjectsCollectionRef().doc(projectId);

    try {
      await docRef.delete();
    } catch (e) {
      rethrow;
    }
  }

  Future<MusicProject?> getProject(String projectId) async {
    if (_currentUserId == null) {
      return null;
    }

    final docRef = _getProjectsCollectionRef().doc(projectId);

    try {
      final docSnapshot = await docRef.get();
      if (docSnapshot.exists) {
        return MusicProject.fromJson(docSnapshot.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }
}
