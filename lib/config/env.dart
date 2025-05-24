import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get baseUrl => dotenv.get('BASE_URL');
  static String get mediaUrl => dotenv.get('MEDIA_URL');
  static String get socketUrl => dotenv.get('SOCKET_URL');

  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }
}