import 'package:flutter/material.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  Set<String> _selectedUserIds = {};
  UserRole? _roleFilter;
  UserStatus? _statusFilter;
  String? _categoryFilter;

  // Available categories
  static const List<String> categories = [
    'Feature',
    'News',
    'Sports',
    'Academics',
    'Gallery',
  ];

  List<User> get users => _users;
  List<User> get filteredUsers => _filteredUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  Set<String> get selectedUserIds => _selectedUserIds;
  UserRole? get roleFilter => _roleFilter;
  UserStatus? get statusFilter => _statusFilter;
  String? get categoryFilter => _categoryFilter;

  void _loadMockUsers() {
    _users = [
      User(
        id: '1',
        firstName: 'Carl',
        lastName: 'De Sagun',
        displayName: 'Carl De Sagun',
        email: 'admin@axis.com',
        username: 'carldesagun',
        role: UserRole.admin,
        permissions: ['manage_users', 'edit_articles', 'publish_articles', 'manage_system'],
        status: UserStatus.active,
        profilePicture: null,
        contactInfo: '09171234567',
        lastLogin: DateTime.now().subtract(const Duration(minutes: 30)),
        activityLogs: ['Logged in', 'Published feature article', 'Managed editorial board', 'Updated user permissions'],
        category: 'Feature',
        position: 'Editor-in-Chief',
        title: 'Chief Editor',
        memberSince: DateTime.now().subtract(const Duration(days: 365)),
        twoFactorEnabled: true,
        articlesPublished: 45,
        totalViews: 28470,
        contributions: 156,
        activeSessions: [
          LoginSession(
            id: 'session1',
            deviceInfo: 'Chrome on Windows 11',
            location: 'Manila, Philippines',
            loginTime: DateTime.now().subtract(const Duration(minutes: 30)),
          ),
        ],
        loginHistory: [
          LoginHistory(
            id: 'login1',
            timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
            deviceInfo: 'Chrome on Windows 11',
            location: 'Manila, Philippines',
            success: true,
          ),
        ],
      ),
      User(
        id: '2',
        firstName: 'Paul Adrian',
        lastName: 'Paraiso',
        displayName: 'Paul Adrian K. Paraiso',
        email: 'paul.paraiso@axis.com',
        username: 'paulparaiso',
        role: UserRole.editor,
        permissions: ['edit_articles', 'publish_articles'],
        status: UserStatus.active,
        profilePicture: null,
        contactInfo: '09293456789',
        lastLogin: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
        activityLogs: ['Logged in', 'Published multiple licensure exam articles', 'Covered engineering achievements'],
        category: 'News',
        position: 'Senior Editor',
        title: 'News Editor',
        memberSince: DateTime.now().subtract(const Duration(days: 280)),
        twoFactorEnabled: false,
        articlesPublished: 32,
        totalViews: 18920,
        contributions: 98,
      ),
      User(
        id: '3',
        firstName: 'Jane',
        lastName: 'Doe',
        displayName: 'Jane Doe',
        email: 'jane@axis.com',
        username: 'janedoe',
        role: UserRole.writer,
        permissions: ['edit_articles'],
        status: UserStatus.active,
        profilePicture: null,
        contactInfo: '09120000002',
        lastLogin: DateTime.now().subtract(const Duration(hours: 3)),
        activityLogs: ['Logged in', 'Started draft article', 'Submitted article for review'],
        category: 'Feature',
        position: 'Staff Writer',
        title: 'Feature Writer',
        memberSince: DateTime.now().subtract(const Duration(days: 180)),
        twoFactorEnabled: false,
        articlesPublished: 12,
        totalViews: 5600,
        contributions: 45,
      ),
    ];
    _filteredUsers = _users;
  }

  // Initialize provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));
      _loadMockUsers();
      _error = null;
    } catch (e) {
      _error = 'Failed to load users: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // CRUD Operations
  Future<void> createUser(User user) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      _users.add(user);
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Failed to create user: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUser(User user) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _users.indexWhere((u) => u.id == user.id);
      if (index != -1) {
        _users[index] = user;
        _applyFilters();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to update user: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteUser(String id) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      _users.removeWhere((user) => user.id == id);
      _selectedUserIds.remove(id);
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Failed to delete user: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> bulkDelete(List<String> ids) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      _users.removeWhere((user) => ids.contains(user.id));
      _selectedUserIds.removeAll(ids);
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Failed to delete users: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Profile Management
  Future<void> updateProfile(String userId, {
    String? firstName,
    String? lastName,
    String? displayName,
    String? email,
    String? username,
    String? contactInfo,
    String? category,
    String? position,
    String? title,
    String? profilePicture,
  }) async {
    _setLoading(true);
    try {
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        final user = _users[index];
        _users[index] = user.copyWith(
          firstName: firstName,
          lastName: lastName,
          displayName: displayName,
          email: email,
          username: username,
          contactInfo: contactInfo,
          category: category,
          position: position,
          title: title,
          profilePicture: profilePicture,
        );
        _applyFilters();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to update profile: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateSecuritySettings(String userId, {
    bool? twoFactorEnabled,
    List<LoginSession>? activeSessions,
  }) async {
    _setLoading(true);
    try {
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        final user = _users[index];
        _users[index] = user.copyWith(
          twoFactorEnabled: twoFactorEnabled,
          activeSessions: activeSessions,
        );
        _applyFilters();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to update security settings: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Search and Filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setRoleFilter(UserRole? role) {
    _roleFilter = role;
    _applyFilters();
  }

  void setStatusFilter(UserStatus? status) {
    _statusFilter = status;
    _applyFilters();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _roleFilter = null;
    _statusFilter = null;
    _categoryFilter = null;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredUsers = _users.where((user) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesSearch = user.displayName.toLowerCase().contains(query) ||
            user.email.toLowerCase().contains(query) ||
            user.username.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      // Role filter
      if (_roleFilter != null && user.role != _roleFilter) {
        return false;
      }

      // Status filter
      if (_statusFilter != null && user.status != _statusFilter) {
        return false;
      }

      // Category filter
      if (_categoryFilter != null && user.category != _categoryFilter) {
        return false;
      }

      return true;
    }).toList();

    // Sort by last login (most recent first)
    _filteredUsers.sort((a, b) => (b.lastLogin ?? DateTime(1970)).compareTo(a.lastLogin ?? DateTime(1970)));
    
    notifyListeners();
  }

  // Selection management
  void selectUser(String userId, bool selected) {
    if (selected) {
      _selectedUserIds.add(userId);
    } else {
      _selectedUserIds.remove(userId);
    }
    notifyListeners();
  }

  void selectAllUsers() {
    _selectedUserIds = _filteredUsers.map((user) => user.id).toSet();
    notifyListeners();
  }

  void deselectAllUsers() {
    _selectedUserIds.clear();
    notifyListeners();
  }

  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get user by ID
  User? getUserById(String id) {
    try {
      return _users.firstWhere((user) => user.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get users by role
  List<User> getUsersByRole(UserRole role) {
    return _users.where((user) => user.role == role).toList();
  }

  // Get users by category
  List<User> getUsersByCategory(String category) {
    return _users.where((user) => user.category == category).toList();
  }

  // Get users by status
  List<User> getUsersByStatus(UserStatus status) {
    return _users.where((user) => user.status == status).toList();
  }
} 