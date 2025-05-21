import 'package:hive/hive.dart';

part 'user.g.dart'; // This is required for code generation

@HiveType(typeId: 0) // typeId must be unique across your app
class User {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String fullName;

  @HiveField(3)
  final String email;

  @HiveField(4)
  final String role;

  @HiveField(5)
  final String passwordHash;

  @HiveField(6)
  final String languagePreference;

  @HiveField(7)
  final String themePreference;

  @HiveField(8)
  final bool isActive;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.role,
    required this.passwordHash,
    required this.languagePreference,
    required this.themePreference,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'],
      passwordHash: json['passwordHash'],
      languagePreference: json['language_preference'] ?? 'en',
      themePreference: json['theme_preference'] ?? 'light',
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'email': email,
      'role': role,
      'passwordHash': passwordHash,
      'language_preference': languagePreference,
      'theme_preference': themePreference,
      'is_active': isActive,
    };
  }
}




// class User {
//   final int id;
//   final String username;
//   final String fullName;
//   final String email;
//   final String role;
//   final String passwordHash;
//   final String languagePreference;
//   final String themePreference;
//   final bool isActive;
//
//   User({
//     required this.id,
//     required this.username,
//     required this.fullName,
//     required this.email,
//     required this.role,
//     required this.passwordHash,
//     required this.languagePreference,
//     required this.themePreference,
//     required this.isActive,
//   });
//
//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['id'],
//       username: json['username'],
//       fullName: json['full_name'] ?? '',
//       email: json['email'] ?? '',
//       role: json['role'],
//       passwordHash: json['passwordHash'],
//       languagePreference: json['language_preference'] ?? 'en',
//       themePreference: json['theme_preference'] ?? 'light',
//       isActive: json['is_active'] ?? true,
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'username': username,
//       'full_name': fullName,
//       'email': email,
//       'role': role,
//       'passwordHash': passwordHash,
//       'language_preference': languagePreference,
//       'theme_preference': themePreference,
//       'is_active': isActive,
//     };
//   }
// }
