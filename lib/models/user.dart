enum UserRole { admin, editor, writer, contributor }
enum UserStatus { active, inactive, suspended }

class User {
  final String id;
  final String firstName;
  final String lastName;
  final String displayName;
  final String email;
  final String username;
  final UserRole role;
  final List<String> permissions;
  final UserStatus status;
  final String? profilePicture;
  final String contactInfo;
  final DateTime? lastLogin;
  final List<String> activityLogs;
  
  final String? category;
  final String? position;
  final String? title;
  final DateTime? memberSince;
  final bool twoFactorEnabled;
  final List<LoginSession> activeSessions;
  final List<LoginHistory> loginHistory;
  final int articlesPublished;
  final int totalViews;
  final int contributions;
  final String? password;

  // Computed properties
  String get fullName => '$firstName $lastName';
  String get initials => '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'.toUpperCase();
  String get roleDisplayName => role.name[0].toUpperCase() + role.name.substring(1);
  String get categoryDisplay => category ?? 'Not assigned';
  String get positionDisplay => position ?? 'Not specified';

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.email,
    required this.username,
    required this.role,
    required this.permissions,
    required this.status,
    this.profilePicture,
    required this.contactInfo,
    this.lastLogin,
    required this.activityLogs,
    this.category,
    this.position,
    this.title,
    this.memberSince,
    this.twoFactorEnabled = false,
    this.activeSessions = const [],
    this.loginHistory = const [],
    this.articlesPublished = 0,
    this.totalViews = 0,
    this.contributions = 0,
    this.password,
  });

  User copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? displayName,
    String? email,
    String? username,
    UserRole? role,
    List<String>? permissions,
    UserStatus? status,
    String? profilePicture,
    String? contactInfo,
    DateTime? lastLogin,
    List<String>? activityLogs,
    String? category,
    String? position,
    String? title,
    DateTime? memberSince,
    bool? twoFactorEnabled,
    List<LoginSession>? activeSessions,
    List<LoginHistory>? loginHistory,
    int? articlesPublished,
    int? totalViews,
    int? contributions,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      permissions: permissions ?? this.permissions,
      status: status ?? this.status,
      profilePicture: profilePicture ?? this.profilePicture,
      contactInfo: contactInfo ?? this.contactInfo,
      lastLogin: lastLogin ?? this.lastLogin,
      activityLogs: activityLogs ?? this.activityLogs,
      category: category ?? this.category,
      position: position ?? this.position,
      title: title ?? this.title,
      memberSince: memberSince ?? this.memberSince,
      twoFactorEnabled: twoFactorEnabled ?? this.twoFactorEnabled,
      activeSessions: activeSessions ?? this.activeSessions,
      loginHistory: loginHistory ?? this.loginHistory,
      articlesPublished: articlesPublished ?? this.articlesPublished,
      totalViews: totalViews ?? this.totalViews,
      contributions: contributions ?? this.contributions,
      password: password ?? this.password,
    );
  }

  // Factory constructor for backward compatibility
  factory User.fromLegacy({
    required String id,
    required String fullName,
    required String email,
    required String username,
    required UserRole role,
    required List<String> permissions,
    required UserStatus status,
    String? profilePicture,
    required String contactInfo,
    DateTime? lastLogin,
    required List<String> activityLogs,
    String? password,
  }) {
    final nameParts = fullName.split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    
    return User(
      id: id,
      firstName: firstName,
      lastName: lastName,
      displayName: fullName,
      email: email,
      username: username,
      role: role,
      permissions: permissions,
      status: status,
      profilePicture: profilePicture,
      contactInfo: contactInfo,
      lastLogin: lastLogin,
      activityLogs: activityLogs,
      memberSince: DateTime.now().subtract(const Duration(days: 365)),
      password: password,
    );
  }
}

// Login session tracking
class LoginSession {
  final String id;
  final String deviceInfo;
  final String location;
  final DateTime loginTime;
  final bool isActive;

  LoginSession({
    required this.id,
    required this.deviceInfo,
    required this.location,
    required this.loginTime,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceInfo': deviceInfo,
    'location': location,
    'loginTime': loginTime.toIso8601String(),
    'isActive': isActive,
  };

  factory LoginSession.fromJson(Map<String, dynamic> json) => LoginSession(
    id: json['id'],
    deviceInfo: json['deviceInfo'],
    location: json['location'],
    loginTime: DateTime.parse(json['loginTime']),
    isActive: json['isActive'] ?? true,
  );
}

// Login history tracking
class LoginHistory {
  final String id;
  final DateTime timestamp;
  final String deviceInfo;
  final String location;
  final bool success;
  final String? failureReason;

  LoginHistory({
    required this.id,
    required this.timestamp,
    required this.deviceInfo,
    required this.location,
    required this.success,
    this.failureReason,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'deviceInfo': deviceInfo,
    'location': location,
    'success': success,
    'failureReason': failureReason,
  };

  factory LoginHistory.fromJson(Map<String, dynamic> json) => LoginHistory(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    deviceInfo: json['deviceInfo'],
    location: json['location'],
    success: json['success'],
    failureReason: json['failureReason'],
  );
} 