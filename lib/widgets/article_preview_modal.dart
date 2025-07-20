import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/articles.dart';
import '../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/article_provider.dart';

class ArticlePreviewModal extends StatelessWidget {
  final String articleId;

  const ArticlePreviewModal({
    Key? key,
    required this.articleId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 400;
    
    return Consumer<ArticleProvider>(
      builder: (context, articleProvider, _) {
        final article = articleProvider.articles.firstWhere(
          (a) => a.id == articleId,
          orElse: () => Article(
            id: '',
            title: 'Not found',
            content: '',
            excerpt: '',
            author: '',
            categories: [],
            status: ArticleStatus.draft,
            readTime: 1,
          ),
        );
    return Dialog(
      backgroundColor: Colors.transparent,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isSmallMobile ? size.width * 0.95 : (isMobile ? size.width * 0.9 : 700),
                minWidth: isSmallMobile ? size.width * 0.9 : 320,
                maxHeight: size.height * (isSmallMobile ? 0.9 : 0.85),
              ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(isSmallMobile ? 20 : 24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(isSmallMobile ? 16 : (isMobile ? 20 : 24)),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isSmallMobile ? 20 : 24),
                  topRight: Radius.circular(isSmallMobile ? 20 : 24),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.secondary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.preview_rounded,
                    color: AppColors.secondary,
                    size: isSmallMobile ? 22 : (isMobile ? 26 : 28),
                  ),
                  SizedBox(width: isSmallMobile ? 8 : 12),
                  Expanded(
                    child: Text(
                      'Article Preview',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallMobile ? 16 : (isMobile ? 18 : 20),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: isSmallMobile ? 20 : 24,
                    ),
                    tooltip: 'Close preview',
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallMobile ? 16 : (isMobile ? 20 : 24)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured Image
                    if (article.featuredImage != null)
                      Container(
                        width: double.infinity,
                        height: isSmallMobile ? 150 : (isMobile ? 180 : 200),
                        margin: EdgeInsets.only(bottom: isSmallMobile ? 16 : (isMobile ? 20 : 24)),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 16),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 16),
                          child: Image.network(
                            article.featuredImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.background,
                                child: Icon(
                                  Icons.image_not_supported_rounded,
                                  size: isSmallMobile ? 32 : (isMobile ? 40 : 48),
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    // Title
                    Text(
                      article.title,
                      style: GoogleFonts.poppins(
                        fontSize: isSmallMobile ? 20 : (isMobile ? 24 : 28),
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: isSmallMobile ? 12 : 16),
                    // Meta information
                    Wrap(
                      spacing: isSmallMobile ? 8 : 12,
                      runSpacing: isSmallMobile ? 6 : 8,
                      children: [
                        _MetaChip(
                          icon: Icons.person_rounded,
                          text: article.author,
                        ),
                        _MetaChip(
                          icon: Icons.category_rounded,
                          text: article.categories.isNotEmpty ? article.categories[0] : '',
                        ),
                        _MetaChip(
                          icon: Icons.timer_rounded,
                          text: '${article.readTime} min read',
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallMobile ? 16 : 20),
                    // Content
                    Container(
                      padding: EdgeInsets.all(isSmallMobile ? 12 : (isMobile ? 16 : 20)),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 16),
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        article.content,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallMobile ? 14 : (isMobile ? 15 : 16),
                          height: 1.6,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: isSmallMobile ? 16 : 24),
                    // Status indicator
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallMobile ? 12 : 16, 
                        vertical: isSmallMobile ? 6 : 8
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(article.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 20),
                        border: Border.all(
                          color: _getStatusColor(article.status).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getStatusIcon(article.status),
                            size: isSmallMobile ? 14 : 16,
                            color: _getStatusColor(article.status),
                          ),
                          SizedBox(width: isSmallMobile ? 4 : 6),
                          Text(
                            _getStatusText(article.status),
                            style: GoogleFonts.poppins(
                              fontSize: isSmallMobile ? 10 : 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(article.status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
            ),
          ),
        );
      },
    );
  }


  Color _getStatusColor(ArticleStatus status) {
    switch (status) {
      case ArticleStatus.draft:
        return Colors.orange;
      case ArticleStatus.published:
        return Colors.green;
      case ArticleStatus.archived:
        return Colors.grey;
      case ArticleStatus.scheduled:
        return Colors.blue;
      case ArticleStatus.deleted:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ArticleStatus status) {
    switch (status) {
      case ArticleStatus.draft:
        return Icons.edit_rounded;
      case ArticleStatus.published:
        return Icons.published_with_changes_rounded;
      case ArticleStatus.archived:
        return Icons.archive_rounded;
      case ArticleStatus.scheduled:
        return Icons.schedule_rounded;
      case ArticleStatus.deleted:
        return Icons.delete_forever_rounded;
    }
  }

  String _getStatusText(ArticleStatus status) {
    switch (status) {
      case ArticleStatus.draft:
        return 'Draft';
      case ArticleStatus.published:
        return 'Published';
      case ArticleStatus.archived:
        return 'Archived';
      case ArticleStatus.scheduled:
        return 'Scheduled';
      case ArticleStatus.deleted:
        return 'Deleted';
    }
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetaChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 400;
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 8 : 12, 
        vertical: isSmallMobile ? 4 : 6
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isSmallMobile ? 8 : 12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmallMobile ? 12 : 14,
            color: AppColors.primary,
          ),
          SizedBox(width: isSmallMobile ? 4 : 6),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: isSmallMobile ? 10 : 12,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
} 