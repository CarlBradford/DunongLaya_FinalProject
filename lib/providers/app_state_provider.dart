import '../models/articles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../mock/mock_articles.dart';

enum UserRole { reader, staff, admin }

enum AppScreen {
  splash,
  login,
  register,
  home,
  articleDetail,
  staffDashboard,
  articleManagement,
  profile,
  userManagement,
  analytics, 
  welcome, 
}

class AppStateProvider extends ChangeNotifier {
  UserRole _role = UserRole.reader;
  AppScreen _currentScreen = AppScreen.splash;
  Article? _selectedArticle;
  Set<String> _bookmarkedArticleIds = {};
  final Set<String> _likedArticleIds = {};
  int _selectedAdminTab = 0;
  String? currentUserName;
  String? currentUserEmail;
  UserRole? currentUserRole;

  UserRole get role => _role;
  AppScreen get currentScreen => _currentScreen;
  Article? get selectedArticle => _selectedArticle;
  Set<String> get bookmarkedArticleIds => _bookmarkedArticleIds;
  int get selectedAdminTab => _selectedAdminTab;
  String? get userName => currentUserName;
  String? get userEmail => currentUserEmail;
  UserRole? get userRole => currentUserRole;

  void setRole(UserRole role) {
    _role = role;
    notifyListeners();
  }

  void setScreen(AppScreen screen, {Article? article}) {
    _currentScreen = screen;
    _selectedArticle = article;
    notifyListeners();
  }

  void setSelectedAdminTab(int index) {
    _selectedAdminTab = index;
    notifyListeners();
  }

  void setCurrentUser({required String name, required String email, required UserRole role}) {
    currentUserName = name;
    currentUserEmail = email;
    currentUserRole = role;
    notifyListeners();
  }

  Future<void> loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('bookmarked_articles') ?? [];
    _bookmarkedArticleIds = ids.toSet();
    notifyListeners();
  }

  Future<void> toggleBookmark(String articleId) async {
    if (_bookmarkedArticleIds.contains(articleId)) {
      _bookmarkedArticleIds.remove(articleId);
    } else {
      _bookmarkedArticleIds.add(articleId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarked_articles', _bookmarkedArticleIds.toList());
    notifyListeners();
  }

  bool isBookmarked(String articleId) {
    return _bookmarkedArticleIds.contains(articleId);
  }

  // Add a method to increment the like count for an article by id
  void incrementArticleLikes(String articleId) {
    notifyListeners();
  }

  // Toggle like for an article
  void toggleArticleLike(String articleId) {
    final index = articles.indexWhere((a) => a.id == articleId);
    if (index == -1) return;
    if (_likedArticleIds.contains(articleId)) {
      // Unlike
      _likedArticleIds.remove(articleId);
      if (articles[index].likes > 0) articles[index].likes -= 1;
    } else {
      // Like
      _likedArticleIds.add(articleId);
      articles[index].likes += 1;
    }
    notifyListeners();
  }

  void incrementArticleComments(String articleId) {
    final article = articles.firstWhere((a) => a.id == articleId, orElse: () => throw Exception('Article not found'));
    article.comments += 1;
    notifyListeners();
  }

  bool isArticleLiked(String articleId) {
    return _likedArticleIds.contains(articleId);
  }

  // Call this in your main() or provider init
  AppStateProvider() {
    loadBookmarks();
  }
} 