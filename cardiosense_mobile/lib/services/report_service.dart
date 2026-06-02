import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/report.dart';

class ReportService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<Report> _reports = [];
  bool _isLoading = false;

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;

  ReportService() {
    listenToReports();
  }

  // Real-time listener for reports
  void listenToReports() {
    _db.collection('reports').orderBy('createdAt', descending: true).snapshots().listen((snapshot) {
      _reports = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Inject document ID
        return Report.fromJson(data);
      }).toList();
      notifyListeners();
    });
  }

  Future<void> fetchReports() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _db.collection('reports').orderBy('createdAt', descending: true).get();
      _reports = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Report.fromJson(data);
      }).toList();
    } catch (e) {
      debugPrint('Error fetching reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Added helper methods back for filtering reports in UI
  List<Report> getReportsByCardiologist(String email) {
    return _reports.where((r) => r.cardiologistEmail.toLowerCase() == email.trim().toLowerCase()).toList();
  }

  List<Report> getReportsByPatient(String email) {
    return _reports.where((r) => r.patientEmail.toLowerCase() == email.trim().toLowerCase()).toList();
  }

  Future<Report> uploadReport({
    required String patientName,
    required String patientEmail,
    required String patientAge,
    required String patientGender,
    required String symptoms,
    required String notes,
    required String cardiologistName,
    required String cardiologistEmail,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? downloadUrl;
      String? actualFileName = fileName ?? 'ecg_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // 1. Upload File to Firebase Storage
      if (fileBytes != null) {
        final storageRef = _storage.ref().child('ecg_reports/$actualFileName');
        final uploadTask = await storageRef.putData(fileBytes, SettableMetadata(contentType: 'application/pdf'));
        downloadUrl = await uploadTask.ref.getDownloadURL();
      }

      // 2. Prepare Report Data
      final reportData = {
        'reportId': 'ECG-${DateTime.now().millisecondsSinceEpoch}',
        'patientName': patientName,
        'patientEmail': patientEmail.toLowerCase(),
        'patientAge': int.tryParse(patientAge),
        'patientGender': patientGender,
        'symptoms': symptoms,
        'notes': notes,
        'cardiologistName': cardiologistName,
        'cardiologistEmail': cardiologistEmail.toLowerCase(),
        'status': 'Pending',
        'confidence': 'Pending',
        'conditions': [],
        'fileUrl': downloadUrl,
        'fileName': actualFileName,
        'createdAt': FieldValue.serverTimestamp(),
        'analysis': _mockAnalysis(), // AI analysis logic (simulated)
      };

      // 3. Save to Firestore
      final docRef = await _db.collection('reports').add(reportData);
      
      _isLoading = false;
      notifyListeners();
      
      reportData['id'] = docRef.id;
      // Note: createdAt will be null in reportData because serverTimestamp() hasn't resolved yet
      // but the real-time listener will pick it up properly.
      return Report.fromJson(reportData);
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Map<String, dynamic> _mockAnalysis() {
    return {
      'heartRate': 72,
      'rhythmType': 'Normal Sinus Rhythm',
      'confidence': '89.5',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Future<void> submitReview({
    required String id,
    required String status,
    required String doctorNotes,
    List<dynamic>? conditions,
  }) async {
    await _db.collection('reports').doc(id).update({
      'status': status,
      'doctorNotes': doctorNotes,
      'doctorAssessment': doctorNotes,
      'conditions': conditions ?? [],
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
