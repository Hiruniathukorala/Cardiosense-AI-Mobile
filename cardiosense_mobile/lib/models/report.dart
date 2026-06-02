import 'package:cloud_firestore/cloud_firestore.dart';

class ReportCondition {
  final String name;
  final String severity; // 'High', 'Medium', 'Low'

  ReportCondition({required this.name, required this.severity});

  factory ReportCondition.fromJson(Map<String, dynamic> json) {
    return ReportCondition(
      name: json['name'] ?? '',
      severity: json['severity'] ?? 'Medium',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'severity': severity,
    };
  }
}

class Report {
  final String id;
  final String reportId;
  final String createdAt;
  final String patientName;
  final String patientEmail;
  final int? patientAge;
  final String? patientGender;
  final String symptoms;
  final String notes;
  final String cardiologistName;
  final String cardiologistEmail;
  final String status; // 'Pending', 'Approved', 'Normal', 'Abnormal', 'Critical'
  final String confidence;
  final List<ReportCondition> conditions;
  final String? fileUrl;
  final String doctorNotes;
  final String doctorAssessment;
  final String? finalizedAt;

  // Visual clinical metrics mapped from results screen
  final String heartRate;
  final String prInterval;
  final String qrsDuration;
  final String qtInterval;

  Report({
    required this.id,
    required this.reportId,
    required this.createdAt,
    required this.patientName,
    required this.patientEmail,
    this.patientAge,
    this.patientGender,
    required this.symptoms,
    required this.notes,
    required this.cardiologistName,
    required this.cardiologistEmail,
    required this.status,
    required this.confidence,
    required this.conditions,
    this.fileUrl,
    required this.doctorNotes,
    required this.doctorAssessment,
    this.finalizedAt,
    this.heartRate = '75 bpm',
    this.prInterval = '160 ms',
    this.qrsDuration = '90 ms',
    this.qtInterval = '400 ms',
  });

  static String _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toIso8601String();
    } else if (value is String) {
      return value;
    }
    return '';
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    var rawConditions = json['conditions'] as List?;
    List<ReportCondition> parsedConditions = rawConditions != null
        ? rawConditions.map((c) => ReportCondition.fromJson(c)).toList()
        : [];

    return Report(
      id: json['id'] ?? '',
      reportId: json['reportId'] ?? '',
      createdAt: _parseDate(json['createdAt']),
      patientName: json['patientName'] ?? '',
      patientEmail: json['patientEmail'] ?? '',
      patientAge: json['patientAge'] != null 
          ? int.tryParse(json['patientAge'].toString()) ?? json['patientAge'] as int? 
          : null,
      patientGender: json['patientGender'],
      symptoms: json['symptoms'] ?? '',
      notes: json['notes'] ?? '',
      cardiologistName: json['cardiologistName'] ?? '',
      cardiologistEmail: json['cardiologistEmail'] ?? '',
      status: json['status'] ?? 'Pending',
      confidence: json['confidence'] ?? 'Pending',
      conditions: parsedConditions,
      fileUrl: json['fileUrl'],
      doctorNotes: json['doctorNotes'] ?? '',
      doctorAssessment: json['doctorAssessment'] ?? '',
      finalizedAt: json['finalizedAt'] != null ? _parseDate(json['finalizedAt']) : null,
      // Mock metrics to match backend report definitions if missing
      heartRate: json['heartRate'] ?? (json['status'] == 'Abnormal' ? '112 bpm' : '72 bpm'),
      prInterval: json['prInterval'] ?? '140 ms',
      qrsDuration: json['qrsDuration'] ?? '95 ms',
      qtInterval: json['qtInterval'] ?? '420 ms',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reportId': reportId,
      'createdAt': createdAt,
      'patientName': patientName,
      'patientEmail': patientEmail,
      'patientAge': patientAge,
      'patientGender': patientGender,
      'symptoms': symptoms,
      'notes': notes,
      'cardiologistName': cardiologistName,
      'cardiologistEmail': cardiologistEmail,
      'status': status,
      'confidence': confidence,
      'conditions': conditions.map((c) => c.toJson()).toList(),
      'fileUrl': fileUrl,
      'doctorNotes': doctorNotes,
      'doctorAssessment': doctorAssessment,
      'finalizedAt': finalizedAt,
      'heartRate': heartRate,
      'prInterval': prInterval,
      'qrsDuration': qrsDuration,
      'qtInterval': qtInterval,
    };
  }
}
