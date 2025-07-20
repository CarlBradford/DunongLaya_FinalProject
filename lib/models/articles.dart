enum ArticleStatus { draft, published, archived, scheduled, deleted }

class Article {
  final String id;
  final String title;
  final String content;
  final String excerpt;
  final String author;
  final List<String> categories;
  final String? featuredImage;
  final ArticleStatus status;
  final int readTime; // in minutes
  final DateTime? publishedAt;
  final DateTime? scheduledAt;
  final DateTime? updatedAt;
  // New fields
  int likes;
  int comments;
  int views;
  int shares;
  // SEO metadata
  final String? metaTitle;
  final String? metaDescription;
  final List<String> keywords;
  final String? slug;
  // Auto-save tracking
  final DateTime? lastSaved;
  final bool hasUnsavedChanges;

  Article({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.author,
    required this.categories,
    this.featuredImage,
    required this.status,
    required this.readTime,
    this.publishedAt,
    this.scheduledAt,
    this.updatedAt,
    this.likes = 0,
    this.comments = 0,
    this.views = 0,
    this.shares = 0,
    this.metaTitle,
    this.metaDescription,
    this.keywords = const [],
    this.slug,
    this.lastSaved,
    this.hasUnsavedChanges = false,
  });

  Article copyWith({
    String? id,
    String? title,
    String? content,
    String? excerpt,
    String? author,
    List<String>? categories,
    String? featuredImage,
    ArticleStatus? status,
    int? readTime,
    DateTime? publishedAt,
    DateTime? scheduledAt,
    DateTime? updatedAt,
    int? likes,
    int? comments,
    int? views,
    int? shares,
    String? metaTitle,
    String? metaDescription,
    List<String>? keywords,
    String? slug,
    DateTime? lastSaved,
    bool? hasUnsavedChanges,
  }) {
    return Article(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      excerpt: excerpt ?? this.excerpt,
      author: author ?? this.author,
      categories: categories ?? this.categories,
      featuredImage: featuredImage ?? this.featuredImage,
      status: status ?? this.status,
      readTime: readTime ?? this.readTime,
      publishedAt: publishedAt ?? this.publishedAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      views: views ?? this.views,
      shares: shares ?? this.shares,
      metaTitle: metaTitle ?? this.metaTitle,
      metaDescription: metaDescription ?? this.metaDescription,
      keywords: keywords ?? this.keywords,
      slug: slug ?? this.slug,
      lastSaved: lastSaved ?? this.lastSaved,
      hasUnsavedChanges: hasUnsavedChanges ?? this.hasUnsavedChanges,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'excerpt': excerpt,
      'author': author,
      'categories': categories,
      'featuredImage': featuredImage,
      'status': status.name,
      'readTime': readTime,
      'publishedAt': publishedAt?.toIso8601String(),
      'scheduledAt': scheduledAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'views': views,
      'shares': shares,
      'metaTitle': metaTitle,
      'metaDescription': metaDescription,
      'keywords': keywords,
      'slug': slug,
      'lastSaved': lastSaved?.toIso8601String(),
      'hasUnsavedChanges': hasUnsavedChanges,
    };
  }

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      excerpt: json['excerpt'] ?? '',
      author: json['author'],
      categories: List<String>.from(json['categories'] ?? [json['category'] ?? '']),
      featuredImage: json['featuredImage'],
      status: ArticleStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ArticleStatus.draft,
      ),
      readTime: json['readTime'] ?? 1,
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt']) : null,
      scheduledAt: json['scheduledAt'] != null ? DateTime.parse(json['scheduledAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      views: json['views'] ?? 0,
      shares: json['shares'] ?? 0,
      metaTitle: json['metaTitle'],
      metaDescription: json['metaDescription'],
      keywords: List<String>.from(json['keywords'] ?? []),
      slug: json['slug'],
      lastSaved: json['lastSaved'] != null ? DateTime.parse(json['lastSaved']) : null,
      hasUnsavedChanges: json['hasUnsavedChanges'] ?? false,
    );
  }
} 