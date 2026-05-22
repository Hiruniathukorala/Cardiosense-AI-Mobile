import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/report_service.dart';
import '../widgets/status_badge.dart';
import 'results_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final reportService = Provider.of<ReportService>(context);
    final user = authService.currentUser;
    final isCardiologist = user?.role == 'Cardiologist';

    // Retrieve and filter reports in real-time
    final userReports = user != null
        ? (isCardiologist
            ? reportService.getReportsByCardiologist(user.email)
            : reportService.getReportsByPatient(user.email))
        : [];

    final totalCount = userReports.length;
    final normalCount = userReports.where((r) => r.status == 'Normal').length;
    final abnormalCount = userReports.where((r) => r.status == 'Abnormal').length;
    final criticalCount = userReports.where((r) => r.status == 'Critical').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6F9),
      body: RefreshIndicator(
        onRefresh: () async {
          await reportService.fetchReports();
        },
        color: const Color(0xFF0A66C2),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0A66C2), Color(0xFF084E96)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user?.name ?? "Guest"}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isCardiologist
                          ? 'Review clinical alerts and submit patient diagnostic reports.'
                          : 'Monitor your cardiological reports history and AI diagnoses.',
                      style: const TextStyle(
                        color: Color(0xCCFFFFFF),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Overview Heading
              const Text(
                'Clinical Diagnostics Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),

              // Statistics Grid
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _buildStatCard(
                    title: isCardiologist ? 'ECGs Analyzed' : 'My Reports',
                    value: totalCount.toString(),
                    icon: Icons.analytics_rounded,
                    color: const Color(0xFF0A66C2),
                    bgColor: const Color(0xFFEBF3FF),
                  ),
                  _buildStatCard(
                    title: 'Normal Cases',
                    value: normalCount.toString(),
                    icon: Icons.check_circle_rounded,
                    color: const Color(0xFF10B981),
                    bgColor: const Color(0xFFD1FAE5),
                  ),
                  _buildStatCard(
                    title: 'Abnormal Cases',
                    value: abnormalCount.toString(),
                    icon: Icons.error_rounded,
                    color: const Color(0xFFF59E0B),
                    bgColor: const Color(0xFFFEF3C7),
                  ),
                  _buildStatCard(
                    title: 'Critical Alerts',
                    value: criticalCount.toString(),
                    icon: Icons.warning_rounded,
                    color: const Color(0xFFEF4444),
                    bgColor: const Color(0xFFFEE2E2),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // History list title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isCardiologist ? 'Recent Scans History' : 'My Medical Reports',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF6B7280)),
                ],
              ),
              const SizedBox(height: 12),

              // Reports list or empty state card
              if (userReports.isEmpty)
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.history_rounded, size: 48, color: Colors.black26),
                          const SizedBox(height: 12),
                          Text(
                            isCardiologist
                                ? 'No ECG reports scanned yet.\nUse the Tab Bar below to upload.'
                                : 'No cardiology reports available.\nCheck back when your doctor uploads them.',
                            style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: userReports.length > 5 ? 5 : userReports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final report = userReports[index];
                    return Card(
                      elevation: 1,
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.5),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Push directly to results view for inspection
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Scaffold(
                                appBar: AppBar(
                                  backgroundColor: const Color(0xFF0A66C2),
                                  title: Text('Report: ${report.reportId}'),
                                ),
                                body: ResultsScreen(specificReport: report),
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFAFAFA),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFFE5E7EB)),
                                ),
                                child: const Icon(
                                  Icons.favorite_outline_rounded,
                                  color: Color(0xFF0A66C2),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          report.reportId,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0A66C2),
                                            fontSize: 14,
                                          ),
                                        ),
                                        StatusBadge(status: report.status),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      isCardiologist
                                          ? 'Patient: ${report.patientName}'
                                          : 'Cardiologist: ${report.cardiologistName}',
                                      style: const TextStyle(
                                        color: Color(0xFF1F2937),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Confidence: ${report.confidence}  •  Symptoms: ${report.symptoms.isNotEmpty ? report.symptoms : "None"}',
                                      style: const TextStyle(
                                        color: Color(0xFF6B7280),
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
