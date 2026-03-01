import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use environment variables or manual toggle for production
  static const bool isProduction = bool.fromEnvironment('IS_PRODUCTION', defaultValue: false);

  static const String localBaseUrl = kIsWeb
      ? 'http://localhost:8000/api'
      : (defaultTargetPlatform == TargetPlatform.android
          ? 'http://172.20.196.114:8000/api'
          : 'http://localhost:8000/api');

  // Replace with your actual production URL after hosting the backend
  static const String productionBaseUrl = 'https://your-backend-url.railway.app/api';

  static String get baseUrl => isProduction ? productionBaseUrl : localBaseUrl;

  static const String localWsUrl = kIsWeb
      ? 'ws://localhost:8000/ws/leaves/'
      : (defaultTargetPlatform == TargetPlatform.android
          ? 'ws://172.20.196.114:8000/ws/leaves/'
          : 'ws://localhost:8000/ws/leaves/');

  // Replace with your actual production WebSocket URL
  static const String productionWsUrl = 'wss://your-backend-url.railway.app/ws/leaves/';

  static String get wsUrl => isProduction ? productionWsUrl : localWsUrl;
}
