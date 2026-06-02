import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/auth_service.dart';
import 'services/report_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation.dart';

// IMPORTANT: If you have generated firebase_options.dart using FlutterFire CLI,
// uncomment the line below and the configuration in main().
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // For Web, you usually pass the options here if not using firebase_options.dart
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,
      // options: DefaultFirebaseOptions.currentPlatform, 
    );
  } catch (e) {
    debugPrint('Firebase initialization warning: $e');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ReportService()),
      ],
      child: const CardioSenseApp(),
    ),
  );
}

class CardioSenseApp extends StatelessWidget {
  const CardioSenseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardioSense AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A66C2),
          primary: const Color(0xFF0A66C2),
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
      ),
      home: const AuthenticationWrapper(),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return authService.isAuthenticated ? const MainNavigation() : const LoginScreen();
  }
}
