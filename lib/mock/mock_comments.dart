class ArticleComment {
  final String user;
  final String text;
  final DateTime timestamp;

  ArticleComment({
    required this.user,
    required this.text,
    required this.timestamp,
  });
}

// Map of articleId to list of comments
final Map<String, List<ArticleComment>> articleComments = {}; 