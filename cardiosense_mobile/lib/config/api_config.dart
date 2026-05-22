import 'dart:io' show Platform;

class ApiConfig {
  // Configures the baseline connection url to point to the local Express backend server.
  // Note: Android Emulators must connect via 10.0.2.2, while iOS/Desktop connects via localhost.
  static String get baseUrl {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5001';
      }
    } catch (_) {
      // Platform check will throw an exception on Flutter Web, fallback to localhost
    }
    return 'http://localhost:5001';
  }

  static String get loginUrl => '$baseUrl/api/auth/login';
  static String get registerUrl => '$baseUrl/api/auth/register';
  static String get reportsUrl => '$baseUrl/api/reports';
  static String get uploadUrl => '$baseUrl/api/upload';

  static String getReportDetailsUrl(String id) => '$baseUrl/api/reports/$id';
}
