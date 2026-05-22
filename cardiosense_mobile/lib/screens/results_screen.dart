import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../widgets/custom_ecg_painter.dart';
import '../widgets/status_badge.dart';
import 'doctor_review_screen.dart';

class ResultsScreen extends StatelessWidget {
  final Report? specificReport;

  const ResultsScreen({Key? key, this.specificReport}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final reportService = Provider.of<ReportService>(context);
    final user = authService.currentUser;
    final isCardiologist = user?.role == 'Cardiologist';

    // If no specific report is passed, fetch the latest user report as fallback
    final userReports = user != null
        ? (isCardiologist
            ? reportService.getReportsByCardiologist(user.email)
            : reportService.getReportsByPatient(user.email))
        : [];

    final report = specificReport ?? (userReports.isNotEmpty ? userReports.first : null);

    if (report == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3F6F9),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.analytics_outlined, size: 64, color: Colors.black26),
                    const SizedBox(height: 16),
                    const Text(
                      'No Reports Available',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isCardiologist
                          ? 'Upload a patient\'s ECG file in the "Upload ECG" tab to trigger automated AI analysis.'
                          : 'Your cardiologist has not submitted any reports yet.',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final isAbnormal = report.status == 'Abnormal' || report.status == 'Critical';
    final accentColor = isAbnormal ? const Color(0xFFEF4444) : const Color(0xFF10B981);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Header info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Analysis Results',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Report: ${report.reportId}  •  Patient: ${report.patientName}',
                      style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                    ),
                  ],
                ),
                StatusBadge(status: report.status),
              ],
            ),
            const SizedBox(height: 20),

            // Waveform Graphic Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ECG Waveform (Lead II)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '25 mm/s • 10 mm/mV',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF4B5563)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Custom Painted Waveform Display
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        color: Colors.white,
                        child: CustomPaint(
                          painter: CustomEcgPainter(status: report.status),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Interval metrics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetricItem('Heart Rate', report.heartRate),
                        _buildDivider(),
                        _buildMetricItem('PR Interval', report.prInterval),
                        _buildDivider(),
                        _buildMetricItem('QRS Duration', report.qrsDuration),
                        _buildDivider(),
                        _buildMetricItem('QT/QTc', report.qtInterval),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // AI Assessment Summary card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI Diagnosis Impression',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    const SizedBox(height: 12),

                    // Colorful banner
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isAbnormal ? Icons.warning_rounded : Icons.check_circle_rounded,
                            color: accentColor,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isAbnormal
                                      ? 'ARRHYTHMIA IMPRESSION DETECTED'
                                      : 'NORMAL CARDIO GRAPH RHYTHM',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: accentColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Automated Classifier Confidence Level: ${report.confidence}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: accentColor.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Detected Conditions List
                    const Text(
                      'DETECTED CARDIAC CONDITIONS',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 8),
                    if (report.conditions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No pathologic cardiovascular conditions flagged.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF374151), fontWeight: FontWeight.w500),
                        ),
                      )
                    else
                      ...report.conditions.map(
                        (cond) => Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.favorite_rounded, color: Color(0xFFEF4444), size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  cond.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: cond.severity == 'High'
                                      ? const Color(0xFFFEE2E2)
                                      : const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${cond.severity} Risk',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: cond.severity == 'High'
                                        ? const Color(0xFF991B1B)
                                        : const Color(0xFF92400E),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const Divider(height: 32),

                    // Recommendations
                    const Text(
                      'AI CLINICAL RECOMMENDATION',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.status == 'Normal'
                          ? 'Baseline ECG is stable. Re-evaluate as needed during routine clinician follow-ups.'
                          : 'Patient exhibits signs of cardiac instability. Immediate review by a cardiologist is highly recommended.',
                      style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF1F2937)),
                    ),

                    // Doctor notes if approved
                    if (report.status == 'Approved' && report.doctorNotes.isNotEmpty) ...[
                      const Divider(height: 32),
                      const Text(
                        'CLINICIAN SIGN-OFF ASSESSMENT',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF6B7280)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF3FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report.doctorNotes,
                              style: const TextStyle(fontSize: 13, height: 1.5, color: Color(0xFF1F2937), fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Signed by: ${report.cardiologistName}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0A66C2)),
                                ),
                                if (report.finalizedAt != null)
                                  Text(
                                    'Date: ${DateTime.tryParse(report.finalizedAt!)?.toLocal().toString().substring(0, 16) ?? ""}',
                                    style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Cardiologist Sign-Off button
            if (isCardiologist && report.status == 'Pending') ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        appBar: AppBar(
                          backgroundColor: const Color(0xFF0A66C2),
                          title: const Text('Clinical Sign-off'),
                        ),
                        body: const DoctorReviewScreen(),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.rate_review_rounded),
                label: const Text(
                  'Finalize Medical Report Review',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0A66C2)),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: const Color(0xFFE5E7EB),
    );
  }
}
