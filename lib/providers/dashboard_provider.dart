import 'package:flutter/material.dart';
import '../models/dashboard_analytics.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardAnalytics? _analytics;
  bool _isLoading = false;
  String? _error;
  String _selectedTimeRange = 'week';
  String _searchQuery = '';

  // Getters
  DashboardAnalytics? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedTimeRange => _selectedTimeRange;
  String get searchQuery => _searchQuery;

  // Mock data for development
  void _loadMockAnalytics() {
    _analytics = DashboardAnalytics(
      totalArticles: 24,
      publishedArticles: 18,
      draftArticles: 4,
      archivedArticles: 2,
      totalViews: 15420,
      totalReaders: 892,
      engagementRate: 78.5,
      popularArticles: [
        PopularArticle(
          id: '1',
          title: 'University Launches New Research Center',
          author: 'Dr. Sarah Johnson',
          views: 2847,
          likes: 156,
          featuredImage: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb',
          publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        PopularArticle(
          id: '2',
          title: 'Student Leaders Win National Award',
          author: 'Maria Rodriguez',
          views: 2156,
          likes: 134,
          featuredImage: 'https://images.unsplash.com/photo-1465101046530-73398c7f28ca',
          publishedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        PopularArticle(
          id: '3',
          title: 'Campus Life: A Photo Essay',
          author: 'Alex Chen',
          views: 1892,
          likes: 98,
          featuredImage: 'https://images.unsplash.com/photo-1519125323398-675f0ddb6308',
          publishedAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
      ],
      recentActivity: [
        ActivityItem(
          id: '1',
          title: 'New Article Published',
          description: '"The Future of Online Education" was published by Prof. Michael Brown',
          type: ActivityType.articlePublished,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          userName: 'Prof. Michael Brown',
        ),
        ActivityItem(
          id: '2',
          title: 'Article Edited',
          description: '"Campus Life: A Photo Essay" was updated by Alex Chen',
          type: ActivityType.articleEdited,
          timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          userName: 'Alex Chen',
        ),
        ActivityItem(
          id: '3',
          title: 'New User Registered',
          description: 'Jane Smith joined the platform as a staff writer',
          type: ActivityType.userRegistered,
          timestamp: DateTime.now().subtract(const Duration(hours: 6)),
          userName: 'Jane Smith',
        ),
        ActivityItem(
          id: '4',
          title: 'High Engagement',
          description: '"University Launches New Research Center" received 50+ likes',
          type: ActivityType.likeReceived,
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        ),
      ],
      categoryDistribution: {
        'Feature': 4,
        'News': 8,
        'Sports': 3,
        'Academics': 2,
        'Gallery': 1,
      },
      dailyViews: {
        '2024-07-15': 2100,
        '2024-07-16': 1800,
        '2024-07-17': 1950,
        '2024-07-18': 2200,
        '2024-07-19': 2050,
        '2024-07-20': 1700,
        '2024-07-21': 1600,
      },
      weeklyViews: {
        'Mon': 1200,
        'Tue': 1350,
        'Wed': 1420,
        'Thu': 1580,
        'Fri': 1650,
        'Sat': 980,
        'Sun': 720,
      },
      monthlyViews: {
        'Week 1': 8500,
        'Week 2': 9200,
        'Week 3': 8800,
        'Week 4': 7600,
      },
      yearlyViews: {
        '2021': 42000,
        '2022': 51000,
        '2023': 61000,
        '2024': 32000,
      },
    );
  }

  // Initialize provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 1000));
      _loadMockAnalytics();
      _error = null;
    } catch (e) {
      _error = 'Failed to load dashboard analytics: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Refresh analytics
  Future<void> refreshAnalytics() async {
    await initialize();
  }

  // Update time range
  void setTimeRange(String timeRange) {
    _selectedTimeRange = timeRange;
    _setLoading(true);
    Future.delayed(const Duration(milliseconds: 600), () {
      _setLoading(false);
      notifyListeners();
    });
  }

  // Update search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Get analytics with filters
  DashboardAnalytics? getFilteredAnalytics() {
    if (_analytics == null) return null;
    
    // Apply search filter if needed
    if (_searchQuery.isNotEmpty) {
      final filteredActivity = _analytics!.recentActivity.where((activity) {
        return activity.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               activity.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               (activity.userName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
      }).toList();

      return DashboardAnalytics(
        totalArticles: _analytics!.totalArticles,
        publishedArticles: _analytics!.publishedArticles,
        draftArticles: _analytics!.draftArticles,
        archivedArticles: _analytics!.archivedArticles,
        totalViews: _analytics!.totalViews,
        totalReaders: _analytics!.totalReaders,
        engagementRate: _analytics!.engagementRate,
        popularArticles: _analytics!.popularArticles,
        recentActivity: filteredActivity,
        categoryDistribution: _analytics!.categoryDistribution,
        weeklyViews: _analytics!.weeklyViews,
        monthlyViews: _analytics!.monthlyViews,
        dailyViews: {},
        yearlyViews: {},
      );
    }

    return _analytics;
  }

  // Get views for selected period
  Map<String, int> getViewsForTimeRange() {
    if (_analytics == null) return {};
    switch (_selectedTimeRange) {
      case 'day':
        return _analytics!.dailyViews;
      case 'week':
        return _analytics!.weeklyViews;
      case 'month':
        return _analytics!.monthlyViews;
      case 'year':
        return _analytics!.yearlyViews;
      default:
        return _analytics!.weeklyViews;
    }
  }

  // Add similar getters for other KPIs (e.g., getReadersForTimeRange, getPublishedArticlesForTimeRange, etc.)

  // Get top categories
  List<MapEntry<String, int>> getTopCategories({int limit = 5}) {
    if (_analytics == null) return [];
    
    final sortedCategories = _analytics!.categoryDistribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedCategories.take(limit).toList();
  }

  // Get recent activity with limit
  List<ActivityItem> getRecentActivity({int limit = 10}) {
    if (_analytics == null) return [];
    
    final filteredActivity = _searchQuery.isNotEmpty
        ? _analytics!.recentActivity.where((activity) {
            return activity.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   activity.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                   (activity.userName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
          }).toList()
        : _analytics!.recentActivity;
    
    return filteredActivity.take(limit).toList();
  }

  // Get popular articles with limit
  List<PopularArticle> getPopularArticles({int limit = 5}) {
    if (_analytics == null) return [];
    
    return _analytics!.popularArticles.take(limit).toList();
  }

  // Calculate growth percentage
  double calculateGrowthPercentage(int current, int previous) {
    if (previous == 0) return current > 0 ? 100.0 : 0.0;
    return ((current - previous) / previous * 100);
  }

  // Get engagement trend
  String getEngagementTrend() {
    if (_analytics == null) return 'stable';
    
    final rate = _analytics!.engagementRate;
    if (rate > 80) return 'excellent';
    if (rate > 60) return 'good';
    if (rate > 40) return 'fair';
    return 'needs_improvement';
  }

  // Get activity type icon
  IconData getActivityTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.articlePublished:
        return Icons.published_with_changes_rounded;
      case ActivityType.articleEdited:
        return Icons.edit_rounded;
      case ActivityType.articleDeleted:
        return Icons.delete_rounded;
      case ActivityType.userRegistered:
        return Icons.person_add_rounded;
      case ActivityType.userLogin:
        return Icons.login_rounded;
      case ActivityType.commentAdded:
        return Icons.comment_rounded;
      case ActivityType.likeReceived:
        return Icons.favorite_rounded;
    }
  }

  // Get activity type color
  Color getActivityTypeColor(ActivityType type) {
    switch (type) {
      case ActivityType.articlePublished:
        return Colors.green;
      case ActivityType.articleEdited:
        return Colors.blue;
      case ActivityType.articleDeleted:
        return Colors.red;
      case ActivityType.userRegistered:
        return Colors.purple;
      case ActivityType.userLogin:
        return Colors.orange;
      case ActivityType.commentAdded:
        return Colors.teal;
      case ActivityType.likeReceived:
        return Colors.pink;
    }
  }

  // --- Time-range-aware KPI getters ---
  int getTotalViewsForTimeRange() {
    final views = getViewsForTimeRange().values;
    if (views.isEmpty) return _analytics?.totalViews ?? 0;
    return views.reduce((a, b) => a + b);
  }

  int getActiveReadersForTimeRange() {
    // For demo: scale totalReaders by time range
    if (_analytics == null) return 0;
    switch (_selectedTimeRange) {
      case 'day':
        return (_analytics!.totalReaders * 0.15).round();
      case 'week':
        return (_analytics!.totalReaders * 0.45).round();
      case 'month':
        return (_analytics!.totalReaders * 0.85).round();
      case 'year':
        return _analytics!.totalReaders;
      default:
        return _analytics!.totalReaders;
    }
  }

  int getArticlesPublishedForTimeRange() {
    // For demo: scale publishedArticles by time range
    if (_analytics == null) return 0;
    switch (_selectedTimeRange) {
      case 'day':
        return (_analytics!.publishedArticles * 0.08).ceil();
      case 'week':
        return (_analytics!.publishedArticles * 0.25).ceil();
      case 'month':
        return (_analytics!.publishedArticles * 0.7).ceil();
      case 'year':
        return _analytics!.publishedArticles;
      default:
        return _analytics!.publishedArticles;
    }
  }

  String getMostPopularCategoryForTimeRange() {
    final categories = getTopCategories();
    if (categories.isEmpty) return '-';
    return categories.first.key;
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

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
} 