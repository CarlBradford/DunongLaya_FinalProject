// ignore_for_file: unused_local_variable, unused_element

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/article_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/dashboard_analytics.dart';
import '../../models/articles.dart';
import '../../widgets/admin_scaffold.dart';
import '../admin/analytics_screen.dart' show TimePeriodSelector;
import '../../widgets/article_preview_modal.dart';

class StaffDashboard extends StatefulWidget {
  final bool isAdmin;
  const StaffDashboard({Key? key, this.isAdmin = false}) : super(key: key);

  @override
  
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Initialize both providers
      context.read<DashboardProvider>().initialize();
      final articleProvider = context.read<ArticleProvider>();
      if (articleProvider.articles.isEmpty) {
        articleProvider.initialize();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToArticleManagement({ArticleStatus? statusFilter, bool createNew = false}) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.setScreen(AppScreen.articleManagement);
    
    if (statusFilter != null) {
      final articleProvider = context.read<ArticleProvider>();
      articleProvider.setStatusFilter(statusFilter);
    }
  }

  void _navigateToUserManagement() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.setScreen(AppScreen.userManagement);
  }

  void _navigateToProfile() {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    appState.setScreen(AppScreen.profile);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    return AdminScaffold(
      breadcrumbs: ['Dashboard'],
      selectedIndex: appState.selectedAdminTab,
      userRole: appState.userRole,
      onDestinationSelected: (index) {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        appState.setSelectedAdminTab(index);
        
        // Handle different tab indices for admin vs staff
        if (appState.userRole == UserRole.admin) {
          switch (index) {
            case 0:
              appState.setScreen(AppScreen.staffDashboard);
              break;
            case 1:
              appState.setScreen(AppScreen.articleManagement);
              break;
            case 2:
              appState.setScreen(AppScreen.userManagement);
              break;
            case 3:
              appState.setScreen(AppScreen.analytics);
              break;
            default:
              appState.setScreen(AppScreen.staffDashboard);
          }
        } else {
          // Staff users don't have access to User Management
          switch (index) {
            case 0:
              appState.setScreen(AppScreen.staffDashboard);
              break;
            case 1:
              appState.setScreen(AppScreen.articleManagement);
              break;
            case 2:
              appState.setScreen(AppScreen.analytics);
              break;
            default:
              appState.setScreen(AppScreen.staffDashboard);
          }
        }
      },
      userName: 'Staff',
      userEmail: null,
      onLogout: () {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        appState.setRole(UserRole.reader);
        appState.setScreen(AppScreen.welcome);
      },
      child: Consumer2<DashboardProvider, ArticleProvider>(
        builder: (context, dashboardProvider, articleProvider, child) {
          if (dashboardProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }
          if (dashboardProvider.error != null) {
            return _buildErrorState(dashboardProvider);
          }
          final timeRange = dashboardProvider.selectedTimeRange;
          return Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final isMobile = screenWidth < 600;
                  final isSmallMobile = screenWidth < 400;
                  
                  return Padding(
                    padding: EdgeInsets.only(
                      top: isSmallMobile ? 16 : (isMobile ? 20 : 24), 
                      left: isSmallMobile ? 12 : (isMobile ? 16 : 24), 
                      right: isSmallMobile ? 12 : (isMobile ? 16 : 24), 
                      bottom: 0
                    ),
                    child: TimePeriodSelector(
                      selected: timeRange,
                      onChanged: (range) => dashboardProvider.setTimeRange(range),
                      isSmallMobile: isSmallMobile,
                      isMobile: isMobile,
                    ),
                  );
                },
              ),
              Expanded(
                child: _OverviewTab(dashboardProvider: dashboardProvider, articleProvider: articleProvider, timeRange: timeRange),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(DashboardProvider dashboardProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading dashboard',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            dashboardProvider.error!,
            style: GoogleFonts.poppins(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => dashboardProvider.initialize(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Retry', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      backgroundColor: AppColors.secondary,
      foregroundColor: AppColors.onPrimary,
      onPressed: () => _navigateToArticleManagement(createNew: true),
      icon: const Icon(Icons.add_rounded, size: 24),
      label: Text('New Article', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  final DashboardProvider dashboardProvider;
  final ArticleProvider articleProvider;
  final String timeRange;

  const _OverviewTab({
    required this.dashboardProvider,
    required this.articleProvider,
    required this.timeRange,
  });

  @override
  Widget build(BuildContext context) {
    final analytics = dashboardProvider.analytics;
    if (analytics == null) {
      // Skeleton loader for loading state
      return _DashboardSkeleton();
    }
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 400;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 12 : (isMobile ? 16 : 24),
        vertical: isSmallMobile ? 16 : (isMobile ? 20 : 24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics Grid
          _buildSectionTitle(context, 'Key Metrics', icon: Icons.bar_chart_rounded),
          const SizedBox(height: 16),
          _buildMetricsSection(context, analytics, isMobile, timeRange),
          const SizedBox(height: 32),
          // Recent Articles
          _buildSectionTitle(context, 'Recent Articles', icon: Icons.article_rounded),
          const SizedBox(height: 5),
          _buildRecentArticlesSummary(context, isMobile),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, {IconData? icon}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 400;
    
    return Row(
      children: [
        if (icon != null)
          Container(
            decoration: BoxDecoration(
              color: Color.fromRGBO(31, 58, 52, 1),
              borderRadius: BorderRadius.circular(isSmallMobile ? 6 : 8),
            ),
            padding: EdgeInsets.all(isSmallMobile ? 4 : 6),
            child: Icon(
              icon, 
              color: Color(0xFFE4B646), 
              size: isSmallMobile ? 16 : 20
            ),
          ),
        if (icon != null) SizedBox(width: isSmallMobile ? 8 : 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: isSmallMobile ? 16 : (isMobile ? 18 : 20),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsSection(BuildContext context, DashboardAnalytics analytics, bool isMobile, String timeRange) {
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 400;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    
    final metrics = [
      _ModernMetricCard(
        icon: Icons.visibility_rounded,
        title: 'Total Article Views',
        value: dashboardProvider.getTotalViewsForTimeRange().toString(),
        subtitle: _getSubtitleForTimeRange(timeRange),
        color: AppColors.primary,
      ),
      _ModernMetricCard(
        icon: Icons.people_rounded,
        title: 'Active Readers',
        value: dashboardProvider.getActiveReadersForTimeRange().toString(),
        subtitle: 'Unique users',
        color: AppColors.secondary,
      ),
      _ModernMetricCard(
        icon: Icons.article_rounded,
        title: 'Articles Published',
        value: dashboardProvider.getArticlesPublishedForTimeRange().toString(),
        subtitle: _getSubtitleForTimeRange(timeRange),
        color: AppColors.primary,
      ),
      _ModernMetricCard(
        icon: Icons.category_rounded,
        title: 'Most Popular Category',
        value: dashboardProvider.getMostPopularCategoryForTimeRange(),
        subtitle: 'Highest engagement',
        color: AppColors.secondary,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive grid configuration
        int crossAxisCount;
        double aspectRatio;
        double spacing;
        
        if (isSmallMobile) {
          crossAxisCount = 1;
          aspectRatio = 2.2;
          spacing = 12;
        } else if (isMobile) {
          crossAxisCount = 2;
          aspectRatio = 1.6;
          spacing = 16;
        } else if (isTablet) {
          crossAxisCount = 2;
          aspectRatio = 2.0;
          spacing = 18;
        } else {
          crossAxisCount = 4;
          aspectRatio = 2.6;
          spacing = 20;
        }
        
        return ConstrainedBox(
          constraints: BoxConstraints(maxWidth: constraints.maxWidth),
          child: GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: aspectRatio,
            children: metrics,
          ),
        );
      },
    );
  }

  String _getSubtitleForTimeRange(String timeRange) {
    switch (timeRange) {
      case 'day':
        return 'Today';
      case 'week':
        return 'This Week';
      case 'month':
        return 'This Month';
      case 'year':
        return 'This Year';
      default:
        return '';
    }
  }

  Widget _buildRecentArticlesSummary(BuildContext context, [bool isMobile = false]) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 400;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '',
              style: GoogleFonts.poppins(
                  fontSize: isSmallMobile ? 14 : (isMobile ? 16 : 18),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                final appState = Provider.of<AppStateProvider>(context, listen: false);
                appState.setSelectedAdminTab(1);
                appState.setScreen(AppScreen.articleManagement);
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                  fontSize: isSmallMobile ? 12 : (isMobile ? 13 : 15),
                ),
              ),
            ),
          ],
        ),
        ),
        Consumer<ArticleProvider>(
          builder: (context, articleProvider, child) {
            final recentArticles = articleProvider.articles
                .where((article) => article.status != ArticleStatus.deleted)
                .toList()
              ..sort((a, b) => (b.updatedAt ?? DateTime(1970)).compareTo(a.updatedAt ?? DateTime(1970)));
            final recentArticlesToShow = recentArticles.take(3).toList();
            if (recentArticlesToShow.isEmpty) {
              return _EmptyStateCard(
                icon: Icons.article_outlined,
                title: 'No articles yet',
                subtitle: 'Create your first article to get started',
              );
            }
                        return RefreshIndicator(
              onRefresh: () async {
                // Refresh articles data
                await articleProvider.initialize();
              },
              color: AppColors.secondary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: recentArticlesToShow.map((article) => Padding(
                    padding: EdgeInsets.only(bottom: isSmallMobile ? 8 : 12),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to article management with this article selected
                        final appState = Provider.of<AppStateProvider>(context, listen: false);
                        appState.setSelectedAdminTab(1);
                        appState.setScreen(AppScreen.articleManagement);
                        // You could also set a filter to show this specific article
                      },
                                            child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 16)),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: isSmallMobile ? 80 : (isMobile ? 90 : 100),
                            maxHeight: isSmallMobile ? 90 : (isMobile ? 100 : 110),
                          ),
                          padding: const EdgeInsets.all(0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.horizontal(
                                  left: Radius.circular(isSmallMobile ? 12 : 16)
                                ),
                                // ignore: sized_box_for_whitespace
                                child: Container(
                                  width: isSmallMobile ? 80 : (isMobile ? 90 : 100),
                                  height: isSmallMobile ? 90 : (isMobile ? 100 : 110),
                                  child: Image.asset(
                                    article.featuredImage ?? '',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: AppColors.surface,
                                      child: Icon(
                                        Icons.image_not_supported, 
                                        color: Colors.grey, 
                                        size: isSmallMobile ? 20 : 24
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isSmallMobile ? 10 : 14, 
                                    vertical: isSmallMobile ? 6 : 10
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          article.title,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontSize: isSmallMobile ? 11 : (isMobile ? 12 : 14),
                                            color: AppColors.textPrimary,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(height: isSmallMobile ? 2 : 4),
                                      Text(
                                        'By ${article.author}',
                                        style: GoogleFonts.poppins(
                                          fontSize: isSmallMobile ? 9 : (isMobile ? 10 : 11),
                                          color: AppColors.textSecondary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: isSmallMobile ? 2 : 4),
                                      // Responsive stats row
                                      if (!isSmallMobile) ...[
                                        Row(
                                          children: [
                                            Icon(Icons.remove_red_eye_rounded, size: 12, color: AppColors.secondary),
                                            const SizedBox(width: 2),
                                            Text(
                                              article.views.toString(), 
                                              style: GoogleFonts.poppins(fontSize: 10)
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(Icons.favorite_rounded, size: 12, color: Colors.pinkAccent),
                                            const SizedBox(width: 2),
                                            Text(
                                              article.likes.toString(), 
                                              style: GoogleFonts.poppins(fontSize: 10)
                                            ),
                                            const SizedBox(width: 8),
                                            Icon(Icons.comment_rounded, size: 12, color: AppColors.secondary),
                                            const SizedBox(width: 2),
                                            Text(
                                              article.comments.toString(), 
                                              style: GoogleFonts.poppins(fontSize: 10)
                                            ),
                                          ],
                                        ),
                                      ] else ...[
                                        // Simplified stats for small mobile
                                        Row(
                                          children: [
                                            Icon(Icons.remove_red_eye_rounded, size: 10, color: AppColors.secondary),
                                            const SizedBox(width: 2),
                                            Text(
                                              article.views.toString(), 
                                              style: GoogleFonts.poppins(fontSize: 9)
                                            ),
                                            const SizedBox(width: 6),
                                            Icon(Icons.favorite_rounded, size: 10, color: Colors.pinkAccent),
                                            const SizedBox(width: 2),
                                            Text(
                                              article.likes.toString(), 
                                              style: GoogleFonts.poppins(fontSize: 9)
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              )).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// Helper Widgets
class _TimeRangeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeRangeChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary 
                : AppColors.primary.withOpacity(0.5), 
            width: isSelected ? 2.8 : 2.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// Modern Metric Card with glassmorphism, gradient, and hover effect
class _MetricCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  final String trend;
  final bool trendUp;
  const _MetricCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
    required this.trend,
    required this.trendUp,
  });
  @override
  State<_MetricCard> createState() => _MetricCardState();
}

class _MetricCardState extends State<_MetricCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [widget.color.withOpacity(0.3), Colors.white.withOpacity(0.2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        boxShadow: [
          BoxShadow(
              color: widget.color.withOpacity(_hovered ? 0.13 : 0.07),
              blurRadius: _hovered ? 12 : 6,
              offset: const Offset(0, 3),
          ),
        ],
          border: Border.all(
            color: widget.color.withOpacity(0.13),
            width: 1,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: widget.color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(widget.icon, color: widget.color, size: 20, semanticLabel: widget.title),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 120),
                          child: Text(
                            widget.value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.trendUp ? AppColors.primary.withOpacity(0.10) : AppColors.secondary.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  widget.trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                  size: 11,
                                  color: widget.trendUp ? AppColors.primary : AppColors.secondary,
                                  semanticLabel: widget.trendUp ? 'Upward trend' : 'Downward trend',
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  widget.trend,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: widget.trendUp ? AppColors.primary : AppColors.secondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(widget.title,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                  const SizedBox(height: 1),
                  Text(widget.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modern Quick Action Card with hover/press effect
class _QuickActionCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
  @override
  State<_QuickActionCard> createState() => _QuickActionCardState();
}
class _QuickActionCardState extends State<_QuickActionCard> {
  bool _hovered = false;
  @override
  Widget build(BuildContext context) {
    return FocusableActionDetector(
      mouseCursor: SystemMouseCursors.click,
      onShowHoverHighlight: (hovering) => setState(() => _hovered = hovering),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
          decoration: BoxDecoration(
          color: widget.color.withOpacity(_hovered ? 0.15 : 0.09),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            if (_hovered)
              BoxShadow(
                color: widget.color.withOpacity(0.10),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
            border: Border.all(
            color: widget.color.withOpacity(0.15),
            width: 0.8,
            ),
          ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
          child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
            children: [
                  Icon(widget.icon, color: widget.color, size: 22, semanticLabel: widget.title),
                  const SizedBox(height: 6),
              Text(
                    widget.title,
                style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
                      fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
                ],
                ),
              ),
          ),
        ),
      ),
    );
  }
}

class _RecentArticleCard extends StatelessWidget {
  final Article article;

  const _RecentArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: article.featuredImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article.featuredImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported_rounded,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.article_rounded,
                  color: AppColors.secondary,
                ),
        ),
        title: Text(
          article.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          maxLines: 2,
            overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'By ${article.author} • ${article.readTime} min read',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(article.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getStatusText(article.status),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: _getStatusColor(article.status),
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16,
          color: AppColors.textSecondary.withOpacity(0.5),
        ),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              insetPadding: const EdgeInsets.all(24),
              backgroundColor: Colors.transparent,
              child: ArticlePreviewModal(articleId: article.id),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getStatusColor(ArticleStatus status) {
    switch (status) {
      case ArticleStatus.draft:
        return AppColors.secondary;
      case ArticleStatus.published:
        return AppColors.primary;
      case ArticleStatus.archived:
        return AppColors.textSecondary;
      case ArticleStatus.scheduled:
        return Colors.blue;
      case ArticleStatus.deleted:
        return Colors.red;
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

class _PopularArticleCard extends StatelessWidget {
  final PopularArticle article;

  const _PopularArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: article.featuredImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    article.featuredImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported_rounded,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.article_rounded,
                  color: AppColors.secondary,
                ),
        ),
        title: Text(
          article.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'By ${article.author}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.visibility_rounded,
                  size: 12,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${article.views} views',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.favorite_rounded,
                  size: 12,
                  color: AppColors.secondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${article.likes} likes',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 400;
    
    return Container(
      padding: EdgeInsets.all(isSmallMobile ? 24 : (isMobile ? 32 : 40)),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 20),
        border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSmallMobile ? 36 : (isMobile ? 42 : 48),
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: isSmallMobile ? 12 : (isMobile ? 14 : 16)),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: isSmallMobile ? 14 : (isMobile ? 15 : 16),
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isSmallMobile ? 6 : 8),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: isSmallMobile ? 12 : (isMobile ? 13 : 14),
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String category;
  final int count;
  final int total;

  const _CategoryItem({
    required this.category,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total * 100) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            flex: 2,
        child: Text(
              category,
          style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$count (${percentage.toStringAsFixed(1)}%)',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EngagementMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _EngagementMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
            fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
} 

// Mini summary cards for compact previews
class _MiniArticleCard extends StatelessWidget {
  final Article article;
  const _MiniArticleCard({required this.article});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) => Dialog(
              insetPadding: const EdgeInsets.all(24),
              backgroundColor: Colors.transparent,
              child: ArticlePreviewModal(articleId: article.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                article.title,
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'By ${article.author}',
                style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniPopularCard extends StatelessWidget {
  final PopularArticle article;
  const _MiniPopularCard({required this.article});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'By ${article.author}',
              style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
} 

// Skeleton loader for dashboard overview
class _DashboardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 400;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: isSmallMobile ? 1 : (isMobile ? 2 : 4),
          crossAxisSpacing: isSmallMobile ? 12 : (isMobile ? 16 : 20),
          mainAxisSpacing: isSmallMobile ? 12 : (isMobile ? 16 : 20),
          childAspectRatio: isSmallMobile ? 2.2 : (isMobile ? 1.6 : 2.6),
          children: List.generate(4, (i) => _SkeletonCard()),
        ),
        SizedBox(height: isSmallMobile ? 16 : (isMobile ? 20 : 24)),
        Row(
          children: List.generate(3, (i) => Expanded(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 4 : 6),
            child: _SkeletonCard(height: isSmallMobile ? 60 : 80),
          ))),
        ),
        SizedBox(height: isSmallMobile ? 16 : (isMobile ? 20 : 24)),
        Row(
          children: List.generate(3, (i) => Expanded(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isSmallMobile ? 4 : 6),
            child: _SkeletonCard(height: isSmallMobile ? 40 : 60),
          ))),
        ),
      ],
    );
  }
}
class _SkeletonCard extends StatelessWidget {
  final double height;
  const _SkeletonCard({this.height = 120});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 400;
    final isMobile = screenWidth < 600;
    
    return Container(
      height: height,
      margin: EdgeInsets.symmetric(vertical: isSmallMobile ? 2 : 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.18),
        borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 18),
        gradient: LinearGradient(
          colors: [AppColors.surface.withOpacity(0.18), Colors.white.withOpacity(0.13)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SizedBox(
          width: isSmallMobile ? 30 : 40,
          height: isSmallMobile ? 30 : 40,
          child: CircularProgressIndicator(
            strokeWidth: isSmallMobile ? 2.0 : 2.5,
          ),
        ),
      ),
    );
  }
} 

class _ModernMetricCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;
  const _ModernMetricCard({required this.icon, required this.title, required this.value, required this.subtitle, required this.color});
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 400;
    
    return Container(
      constraints: BoxConstraints(
        minHeight: isSmallMobile ? 100 : (isMobile ? 120 : 140),
        minWidth: 0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.13),
            Colors.white.withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.07),
            blurRadius: isSmallMobile ? 12 : 16,
            offset: Offset(0, isSmallMobile ? 3 : 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isSmallMobile ? 12 : (isMobile ? 14 : 16),
        vertical: isSmallMobile ? 8 : (isMobile ? 10 : 12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(isSmallMobile ? 8 : 12),
            ),
            padding: EdgeInsets.all(isSmallMobile ? 6 : (isMobile ? 7 : 8)),
            child: Icon(
              icon, 
              color: color, 
              size: isSmallMobile ? 20 : (isMobile ? 24 : 32)
            ),
          ),
          SizedBox(width: isSmallMobile ? 12 : (isMobile ? 14 : 18)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallMobile ? 14 : (isMobile ? 16 : 18),
                    fontWeight: FontWeight.bold,
                    color: color
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: isSmallMobile ? 1 : 2),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: isSmallMobile ? 10 : (isMobile ? 11 : 13),
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                SizedBox(height: isSmallMobile ? 1 : 2),
                Text(
                  subtitle, 
                  style: GoogleFonts.poppins(
                    fontSize: isSmallMobile ? 8 : (isMobile ? 9 : 11),
                    color: AppColors.textSecondary
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 