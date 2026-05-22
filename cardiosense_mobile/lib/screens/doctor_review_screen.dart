import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/report.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../widgets/custom_ecg_painter.dart';

class DoctorReviewScreen extends StatefulWidget {
  const DoctorReviewScreen({Key? key}) : super(key: key);

  @override
  State<DoctorReviewScreen> createState() => _DoctorReviewScreenState();
}

class _DoctorReviewScreenState extends State<DoctorReviewScreen> {
  int _selectedPatientIdx = 0;
  final _notesController = TextEditingController();
  bool _isSaving = false;
  String _errorText = '';
  String _successText = '';

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize notes with first pending report notes if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = Provider.of<AuthService>(context, listen: false);
      final reportService = Provider.of<ReportService>(context, listen: false);
      final user = authService.currentUser;

      if (user != null) {
        final pending = reportService
            .getReportsByCardiologist(user.email)
            .where((r) => r.status == 'Pending')
            .toList();
        if (pending.isNotEmpty) {
          _notesController.text = pending[0].doctorNotes;
        }
      }
    });
  }

  Future<void> _saveDraft(Report report) async {
    setState(() {
      _errorText = '';
      _successText = '';
      _isSaving = true;
    });

    final reportService = Provider.of<ReportService>(context, listen: false);

    try {
      await reportService.submitReview(
        id: report.id,
        status: 'Pending',
        doctorNotes: _notesController.text,
      );
      setState(() {
        _successText = 'Draft saved successfully.';
      });
      // Refresh reports cache
      await reportService.fetchReports();
    } catch (e) {
      setState(() {
        _errorText = 'Failed to save draft.';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _approveAndFinalize(Report report, String finalStatus) async {
    setState(() {
      _errorText = '';
      _successText = '';
      _isSaving = true;
    });

    final reportService = Provider.of<ReportService>(context, listen: false);

    try {
      await reportService.submitReview(
        id: report.id,
        status: finalStatus, // e.g. 'Approved' (which represents normal/abnormal finalized check in the web)
        doctorNotes: _notesController.text,
      );
      setState(() {
        _successText = 'Report approved and finalized.';
        _selectedPatientIdx = 0;
      });
      
      // Refresh reports cache
      await reportService.fetchReports();
      
      // Clear notes field
      _notesController.clear();
    } catch (e) {
      setState(() {
        _errorText = 'Failed to finalize report.';
      });
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final reportService = Provider.of<ReportService>(context);
    final user = authService.currentUser;

    final pendingReports = user != null
        ? reportService
            .getReportsByCardiologist(user.email)
            .where((r) => r.status == 'Pending')
            .toList()
        : <Report>[];

    if (pendingReports.isEmpty) {
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
                  children: const [
                    Icon(Icons.check_circle_outline_rounded, size: 56, color: Color(0xFF10B981)),
                    SizedBox(height: 16),
                    Text(
                      'All Reports Finalized!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No pending patient ECG scans require clinical sign-off at this time.',
                      style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
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

    // Safeguard index out of bounds
    if (_selectedPatientIdx >= pendingReports.length) {
      _selectedPatientIdx = 0;
    }

    final currentReport = pendingReports[_selectedPatientIdx];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      body: Column(
        children: [
          // Row of pending patients (horizontal scroller)
          Container(
            height: 72,
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.white,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: pendingReports.length,
              itemBuilder: (context, idx) {
                final r = pendingReports[idx];
                final isSelected = _selectedPatientIdx == idx;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(r.patientName),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPatientIdx = idx;
                          _notesController.text = r.doctorNotes;
                          _errorText = '';
                          _successText = '';
                        });
                      }
                    },
                    selectedColor: const Color(0xFFEBF3FF),
                    backgroundColor: const Color(0xFFF3F4F6),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: isSelected ? const Color(0xFF0A66C2) : const Color(0xFF374151),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main panels
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Patient metadata summary
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
                              Text(
                                currentReport.patientName,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'AI Impression: Abnormal',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Age/Gender: ${currentReport.patientAge ?? "Unknown"} yrs • ${currentReport.patientGender ?? "Unknown"}  |  ID: ${currentReport.reportId}',
                            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12),
                          ),
                          if (currentReport.symptoms.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Symptoms: ${currentReport.symptoms}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mini Waveform Display
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'ECG Waveform (Lead II)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Container(
                              height: 100,
                              color: Colors.white,
                              child: CustomPaint(
                                painter: CustomEcgPainter(status: currentReport.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Form Notes
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Clinical Notes & Diagnosis Plan',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1F2937)),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _notesController,
                            maxLines: 6,
                            decoration: InputDecoration(
                              hintText: 'Enter final assessments, beta-blocker plans, telemetry reviews, etc...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notifications
                  if (_errorText.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFCA5A5)),
                      ),
                      child: Text(
                        _errorText,
                        style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  if (_successText.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD1FAE5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        _successText,
                        style: const TextStyle(color: Color(0xFF065F46), fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Form Action Buttons row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isSaving ? null : () => _approveAndFinalize(currentReport, 'Normal'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.close_rounded, size: 18),
                          label: const Text('Reject AI'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : () => _saveDraft(currentReport),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF0A66C2),
                            side: const BorderSide(color: Color(0xFF0A66C2)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Save Draft'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : () => _approveAndFinalize(currentReport, 'Approved'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Approve'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
