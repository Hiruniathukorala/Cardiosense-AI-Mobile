import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'upload_ecg_screen.dart';
import 'doctor_review_screen.dart';
import 'chatbot_screen.dart';
import 'results_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final isCardiologist = user?.role == 'Cardiologist';

    // Configure tabs dynamically based on user role
    final List<Widget> screens = isCardiologist
        ? [
            const DashboardScreen(),
            const UploadEcgScreen(),
            const DoctorReviewScreen(),
            const ChatbotScreen(),
          ]
        : [
            const DashboardScreen(),
            const ResultsScreen(), // Shows Patient history & waveforms
            const ChatbotScreen(),
          ];

    final List<BottomNavigationBarItem> navItems = isCardiologist
        ? const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.upload_file_rounded),
              label: 'Upload ECG',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.rate_review_rounded),
              label: 'Review',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'AI Chat',
            ),
          ]
        : const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_rounded),
              label: 'My ECGs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_rounded),
              label: 'AI Chat',
            ),
          ];

    final displayName = user != null
        ? '${isCardiologist ? 'Dr. ' : ''}${user.name}'
        : 'Guest User';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A66C2),
        elevation: 2,
        title: Row(
          children: [
            const Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            const Text(
              'CardioSense AI',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // User avatar + status indicator
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      displayName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user?.role ?? 'Visitor',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
                  onPressed: () {
                    authService.logout();
                  },
                  tooltip: 'Secure Logout',
                ),
              ],
            ),
          )
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 1,
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0A66C2),
          unselectedItemColor: const Color(0xFF6B7280),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: navItems,
        ),
      ),
    );
  }
}
