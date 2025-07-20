class DashboardAnalytics {
  final int totalArticles;
  final int publishedArticles;
  final int draftArticles;
  final int archivedArticles;
  final int totalViews;
  final int totalReaders;
  final double engagementRate;
  final List<PopularArticle> popularArticles;
  final List<ActivityItem> recentActivity;
  final Map<String, int> categoryDistribution;
  final Map<String, int> weeklyViews;
  final Map<String, int> monthlyViews;
  final Map<String, int> dailyViews;
  final Map<String, int> yearlyViews;

  DashboardAnalytics({
    required this.totalArticles,
    required this.publishedArticles,
    required this.draftArticles,
    required this.archivedArticles,
    required this.totalViews,
    required this.totalReaders,
    required this.engagementRate,
    required this.popularArticles,
    required this.recentActivity,
    required this.categoryDistribution,
    required this.weeklyViews,
    required this.monthlyViews,
    required this.dailyViews,
    required this.yearlyViews,
  });

  factory DashboardAnalytics.fromJson(Map<String, dynamic> json) {
    return DashboardAnalytics(
      totalArticles: json['totalArticles'] ?? 0,
      publishedArticles: json['publishedArticles'] ?? 0,
      draftArticles: json['draftArticles'] ?? 0,
      archivedArticles: json['archivedArticles'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      totalReaders: json['totalReaders'] ?? 0,
      engagementRate: (json['engagementRate'] ?? 0.0).toDouble(),
      popularArticles: (json['popularArticles'] as List?)
          ?.map((e) => PopularArticle.fromJson(e))
          .toList() ?? [],
      recentActivity: (json['recentActivity'] as List?)
          ?.map((e) => ActivityItem.fromJson(e))
          .toList() ?? [],
      categoryDistribution: Map<String, int>.from(json['categoryDistribution'] ?? {}),
      weeklyViews: Map<String, int>.from(json['weeklyViews'] ?? {}),
      monthlyViews: Map<String, int>.from(json['monthlyViews'] ?? {}),
      dailyViews: Map<String, int>.from(json['dailyViews'] ?? {}),
      yearlyViews: Map<String, int>.from(json['yearlyViews'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalArticles': totalArticles,
      'publishedArticles': publishedArticles,
      'draftArticles': draftArticles,
      'archivedArticles': archivedArticles,
      'totalViews': totalViews,
      'totalReaders': totalReaders,
      'engagementRate': engagementRate,
      'popularArticles': popularArticles.map((e) => e.toJson()).toList(),
      'recentActivity': recentActivity.map((e) => e.toJson()).toList(),
      'categoryDistribution': categoryDistribution,
      'weeklyViews': weeklyViews,
      'monthlyViews': monthlyViews,
      'dailyViews': dailyViews,
      'yearlyViews': yearlyViews,
    };
  }
}

class PopularArticle {
  final String id;
  final String title;
  final String author;
  final int views;
  final int likes;
  final String? featuredImage;
  final DateTime publishedAt;

  PopularArticle({
    required this.id,
    required this.title,
    required this.author,
    required this.views,
    required this.likes,
    this.featuredImage,
    required this.publishedAt,
  });

  factory PopularArticle.fromJson(Map<String, dynamic> json) {
    return PopularArticle(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      featuredImage: json['featuredImage'],
      publishedAt: DateTime.parse(json['publishedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'views': views,
      'likes': likes,
      'featuredImage': featuredImage,
      'publishedAt': publishedAt.toIso8601String(),
    };
  }
}

class ActivityItem {
  final String id;
  final String title;
  final String description;
  final ActivityType type;
  final DateTime timestamp;
  final String? userId;
  final String? userName;

  ActivityItem({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.timestamp,
    this.userId,
    this.userName,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ActivityType.articlePublished,
      ),
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      userId: json['userId'],
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'userName': userName,
    };
  }
}

enum ActivityType {
  articlePublished,
  articleEdited,
  articleDeleted,
  userRegistered,
  userLogin,
  commentAdded,
  likeReceived,
} 