// ignore_for_file: unused_field, unnecessary_cast, unused_local_variable, unnecessary_underscores

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import 'package:profanity_filter/profanity_filter.dart';
import '../../models/articles.dart';
import '../../mock/mock_comments.dart';
import 'package:intl/intl.dart';
import '../../providers/article_provider.dart';



class ArticleDetailPage extends StatefulWidget {
  final Article article;
  const ArticleDetailPage({super.key, required this.article});

  @override
  State<ArticleDetailPage> createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  bool _isBookmarked = false;
  bool _showFloatingButton = false;
  double _readProgress = 0.0;
  final GlobalKey _contentKey = GlobalKey();
  List<ArticleComment> get _comments => articleComments[widget.article.id as String] ?? [];
  final TextEditingController _commentController = TextEditingController();
  final ProfanityFilter _profanityFilter = ProfanityFilter();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _scrollController.addListener(_onScroll);
    _animationController.forward();
    
    // Increment views when the detail page is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final articleProvider = Provider.of<ArticleProvider>(context, listen: false);
      articleProvider.incrementViews(widget.article.id);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final scrollOffset = _scrollController.offset;
    final maxScroll = _scrollController.position.maxScrollExtent;
    
    setState(() {
      _showFloatingButton = scrollOffset > 300;
      _readProgress = (scrollOffset / maxScroll).clamp(0.0, 1.0);
    });
  }


  void _toggleLike() {
    final articleProvider = Provider.of<ArticleProvider>(context, listen: false);
    articleProvider.toggleLike(widget.article.id);
    HapticFeedback.lightImpact();
    _animationController.reverse().then((_) {
      _animationController.forward();
    });
  }

  void _shareArticle() {
    Share.share(
      '${widget.article.title}\n\n${widget.article.excerpt}',
      subject: widget.article.title,
    );
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  String getFormattedDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMMM d, yyyy').format(date);
  }

  void _addComment() {
    final rawText = _commentController.text.trim();
    if (rawText.isEmpty) return;
    String filteredText = rawText;
    filteredText = _profanityFilter.censor(filteredText);
    setState(() {
      final comment = ArticleComment(
        user: 'Anonymous',
        text: filteredText,
        timestamp: DateTime.now(),
      );
      if (!articleComments.containsKey(widget.article.id as String)) {
        articleComments[widget.article.id as String] = [];
      }
      articleComments[widget.article.id as String]!.insert(0, comment);
      _commentController.clear();
    });
    Provider.of<ArticleProvider>(context, listen: false).incrementComments(widget.article.id);
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Comment added!', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ArticleProvider>(
      builder: (context, articleProvider, _) {
        final appState = Provider.of<AppStateProvider>(context);
        final isLiked = articleProvider.isArticleLiked(widget.article.id);
        final isBookmarked = appState.isBookmarked(widget.article.id);
        _isBookmarked = isBookmarked;

        // Get the latest article data from the provider
        final currentArticle = articleProvider.articles.firstWhere(
          (a) => a.id == widget.article.id,
          orElse: () => widget.article,
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: [
              // Progress indicator
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _readProgress,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 3,
                ),
              ),
              
              CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // App Bar with Hero Image
                  SliverAppBar(
                    backgroundColor: AppColors.background,
                    expandedHeight: 300,
                    pinned: true,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Hero(
                        tag: 'article-${widget.article.id}',
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(32),
                                bottomRight: Radius.circular(32),
                              ),
                              child: Image.asset(
                                currentArticle.featuredImage ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.surface,
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              ),
                            ),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(32),
                                  bottomRight: Radius.circular(32),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.3),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    leading: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: AppColors.primary,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.share_rounded),
                          color: AppColors.primary,
                          onPressed: _shareArticle,
                        ),
                      ),
                    ],
                  ),
                  
                  // Article Content
                  SliverToBoxAdapter(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Tag
                            // ignore: unnecessary_null_comparison
                            if (currentArticle.categories.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  currentArticle.categories[0].toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            
                            const SizedBox(height: 16),
                            
                            // Title
                            Text(
                              currentArticle.title,
                              style: GoogleFonts.playfairDisplay(
                                fontWeight: FontWeight.bold,
                                fontSize: 28,
                                color: AppColors.textPrimary,
                                height: 1.2,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Author and Date Info
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: AppColors.secondary.withOpacity(0.2),
                                  backgroundImage: const AssetImage('assets/images/the_axis_logo.png'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'By ${currentArticle.author}',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today_rounded,
                                            size: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            getFormattedDate(currentArticle.publishedAt),
                                            style: GoogleFonts.poppins(
                                              color: AppColors.textSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          const Icon(
                                            Icons.access_time_rounded,
                                            size: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${currentArticle.readTime} min read',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.textSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Article Stats
                            Row(
                              children: [
                                _buildStatItem(Icons.remove_red_eye_rounded, currentArticle.views.toString()),
                                const SizedBox(width: 16),
                                _buildStatItem(Icons.favorite_rounded, currentArticle.likes.toString()),
                                const SizedBox(width: 16),
                                _buildStatItem(Icons.comment_rounded, currentArticle.comments.toString()),
                              ],
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Content
                            Container(
                              key: _contentKey,
                              child: Text(
                                currentArticle.content,
                                style: GoogleFonts.poppins(
                                  color: AppColors.textPrimary,
                                  fontSize: 17,
                                  height: 1.7,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Divider(
                              color: AppColors.primary.withOpacity(0.3),
                              thickness: 1.2,
                              endIndent: 40,
                              indent: 40,
                            ),
                            const SizedBox(height: 24),
                            // Comment Section
                            _buildCommentSection(),
                            const SizedBox(height: 32),
                            // Related Articles Section
                            _buildRelatedPopularSection(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Bottom Actions Bar
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Consumer<AppStateProvider>(
                  builder: (context, appState, _) {
                    final isLiked = articleProvider.isArticleLiked(widget.article.id);
                    final isBookmarked = appState.isBookmarked(widget.article.id);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surface.withOpacity(0.95),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.1),
                            blurRadius: 20,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            label: isLiked ? 'Liked' : 'Like',
                            color: isLiked ? Colors.redAccent : AppColors.textSecondary,
                            onPressed: _toggleLike,
                            animated: true,
                          ),
                          _buildActionButton(
                            icon: Icons.share_rounded,
                            label: 'Share',
                            color: AppColors.primary,
                            onPressed: _shareArticle,
                          ),
                          _buildActionButton(
                            icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            label: 'Save',
                            color: isBookmarked ? AppColors.primary : AppColors.textSecondary,
                            onPressed: () => appState.toggleBookmark(widget.article.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Floating Action Button
              if (_showFloatingButton)
                Positioned(
                  bottom: 100,
                  right: 24,
                  child: FloatingActionButton(
                    onPressed: _scrollToTop,
                    backgroundColor: AppColors.primary,
                    child: const Icon(Icons.keyboard_arrow_up_rounded),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    bool animated = false,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            animated
                ? AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => ScaleTransition(
                      scale: animation,
                      child: child,
                    ),
                    child: Icon(
                      icon,
                      key: ValueKey(icon),
                      color: color,
                      size: 24,
                    ),
                  )
                : Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments (${_comments.length})',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _comments.length,
          itemBuilder: (context, index) {
            final comment = _comments[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.secondary.withOpacity(0.2),
                    backgroundImage: const AssetImage('assets/images/the_axis_logo.png'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comment.user,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.text,
                          style: GoogleFonts.poppins(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          comment.timestamp.toLocal().toString(),
                          style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Add a comment...',
            hintStyle: GoogleFonts.poppins(color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send_rounded, color: AppColors.primary),
              onPressed: _addComment,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedPopularSection() {
    final articleProvider = Provider.of<ArticleProvider>(context, listen: false);
    String mainCategory = widget.article.categories[0].toLowerCase();
    bool isFeature = mainCategory == 'feature' || mainCategory == 'editorial';
    final List<Article> related = articleProvider.articles
        .where((a) {
          if (a.id == widget.article.id) return false;
          if (a.categories.isEmpty) return false;
          String cat = a.categories[0].toLowerCase();
          if (isFeature) {
            return cat == 'feature' || cat == 'editorial';
          } else {
            return cat == mainCategory;
          }
        })
        .toList();
    if (related.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Related Articles',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final article = related[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArticleDetailPage(article: article),
                    ),
                  );
                },
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                        child: Image.asset(
                          article.featuredImage ?? '',
                          width: 70,
                          height: 140,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                article.title,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                article.categories.isNotEmpty ? article.categories[0] : '',
                                style: GoogleFonts.poppins(
                                  color: AppColors.secondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.remove_red_eye_rounded, size: 14, color: AppColors.secondary),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(article.views.toString(), style: GoogleFonts.poppins(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.favorite_rounded, size: 14, color: AppColors.secondary),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(article.likes.toString(), style: GoogleFonts.poppins(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.comment, size: 14, color: AppColors.secondary),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(article.comments.toString(), style: GoogleFonts.poppins(fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}