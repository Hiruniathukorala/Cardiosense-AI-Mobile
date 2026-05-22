import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
import '../models/report.dart';

class ReportService extends ChangeNotifier {
  List<Report> _reports = [];
  bool _isLoading = false;

  List<Report> get reports => _reports;
  bool get isLoading => _isLoading;

  ReportService() {
    fetchReports();
  }

  Future<void> fetchReports() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(ApiConfig.reportsUrl));

      if (response.statusCode == 200) {
        final List raw = jsonDecode(response.body);
        _reports = raw.map((r) => Report.fromJson(r)).toList();
        
        // Sort reports by date (newest first)
        _reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    } catch (_) {
      // Backend offline or initial load empty
      _reports = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

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
    String? filePath,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final request = http.MultipartRequest('POST', Uri.parse(ApiConfig.uploadUrl));

      // Append textual metadata fields
      request.fields['patientName'] = patientName.trim();
      request.fields['patientEmail'] = patientEmail.trim().toLowerCase();
      request.fields['patientAge'] = patientAge;
      request.fields['patientGender'] = patientGender;
      request.fields['symptoms'] = symptoms;
      request.fields['notes'] = notes;
      request.fields['cardiologistName'] = cardiologistName.trim();
      request.fields['cardiologistEmail'] = cardiologistEmail.trim().toLowerCase();

      // Append PDF attachment file
      if (filePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'ecgFile',
            filePath,
            contentType: MediaType('application', 'pdf'),
          ),
        );
      } else if (fileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'ecgFile',
            fileBytes,
            filename: fileName ?? 'mock_ecg.pdf',
            contentType: MediaType('application', 'pdf'),
          ),
        );
      } else {
        // Fallback for demo testing in emulator when no file is selected.
        // We append a tiny mock PDF file byte array.
        final tinyPdfBytes = Uint8List.fromList([
          37, 80, 68, 70, 45, 49, 46, 52, 10, 49, 32, 48, 32, 111, 98, 106, 10, 60, 60, 47, 84, 121, 112, 101, 47, 67, 97, 116, 97, 108, 111, 103, 47, 80, 97, 103, 101, 115, 32, 50, 32, 48, 32, 82, 62, 62, 10, 101, 110, 100, 111, 98, 106, 10, 116, 114, 97, 105, 108, 101, 114, 10, 60, 60, 47, 83, 105, 122, 101, 32, 51, 47, 82, 111, 111, 116, 32, 49, 32, 48, 32, 82, 62, 62, 10, 37, 37, 69, 79, 70
        ]);
        request.files.add(
          http.MultipartFile.fromBytes(
            'ecgFile',
            tinyPdfBytes,
            filename: 'ecg_scanned_report.pdf',
            contentType: MediaType('application', 'pdf'),
          ),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (streamedResponse.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newReport = Report.fromJson(data);
        
        // Prepend new report to local cache
        _reports.insert(0, newReport);
        _isLoading = false;
        notifyListeners();
        return newReport;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Upload failed with status code ${response.statusCode}');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Report> submitReview({
    required String id,
    required String status,
    required String doctorNotes,
    List<ReportCondition>? conditions,
    String? confidence,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final Map<String, dynamic> body = {
        'status': status,
        'doctorNotes': doctorNotes,
        'doctorAssessment': doctorNotes,
      };

      if (conditions != null) {
        body['conditions'] = conditions.map((c) => c.toJson()).toList();
      }
      if (confidence != null) {
        body['confidence'] = confidence;
      }

      final response = await http.put(
        Uri.parse(ApiConfig.getReportDetailsUrl(id)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedReport = Report.fromJson(data);

        // Update cached report
        final idx = _reports.indexWhere((r) => r.id == id);
        if (idx != -1) {
          _reports[idx] = updatedReport;
        }

        _isLoading = false;
        notifyListeners();
        return updatedReport;
      } else {
        throw Exception('Review submission failed.');
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
