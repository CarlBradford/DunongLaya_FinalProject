// ignore_for_file: dead_code, use_build_context_synchronously, prefer_interpolation_to_compose_strings

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/article_provider.dart';
import '../../models/articles.dart';
import '../../widgets/article_preview_modal.dart';
import '../../widgets/admin_scaffold.dart';
import 'dart:async'; // Added for Timer
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import '../../screens/home/home_screen.dart' show galleryImages;

class ArticleManagementScreen extends StatefulWidget {
  final bool isAdmin;
  const ArticleManagementScreen({Key? key, this.isAdmin = false}) : super(key: key);

  @override
  State<ArticleManagementScreen> createState() => _ArticleManagementScreenState();
}

class _ArticleManagementScreenState extends State<ArticleManagementScreen> {
  final _searchController = TextEditingController();
  // ignore: unused_field, prefer_final_fields
  bool _showTrash = false;

  @override
  void initState() {
    super.initState();
    // Removed: context.read<ArticleProvider>().initialize();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openForm([Article? article]) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(24),
        backgroundColor: Colors.transparent,
        child: _ArticleForm(
          article: article,
          onCancel: () => Navigator.of(context).pop(),
          onSave: (String message) {
            Navigator.of(context).pop();
            final articleProvider = context.read<ArticleProvider>();
            // Refresh the article list to show changes immediately
            articleProvider.initialize();
            
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                duration: const Duration(seconds: 2),
              ),
            );
            
            // Notify readers about the update
            // ignore: avoid_print
            print('Article management: $message - Reader view will be updated automatically');
          },
        ),
      ),
    );
  }

  void _showDeleteConfirmation(Article article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Move to Trash',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to move "${article.title}" to trash? You can restore it later.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ArticleProvider>().deleteArticle(article.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Article moved to trash', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text('Move to Trash', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showPermanentDeleteConfirmation(Article article) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Permanently Delete Article',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to permanently delete "${article.title}"? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ArticleProvider>().permanentlyDeleteArticle(article.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Article permanently deleted', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Text('Permanently Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showPreview(Article article) {
    showDialog(
      context: context,
      builder: (context) => ArticlePreviewModal(articleId: article.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 400;
    
    return AdminScaffold(
      breadcrumbs: ['Dashboard', 'Article Management'],
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
              }
            }
          },
      userName: widget.isAdmin ? 'Admin' : 'Staff',
      userEmail: null,
      onLogout: () {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        appState.setRole(UserRole.reader);
        appState.setScreen(AppScreen.welcome);
      },
      // ignore: sort_child_properties_last
      child: Consumer<ArticleProvider>(
        builder: (context, articleProvider, child) {
          if (articleProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }
          if (articleProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
        children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: isSmallMobile ? 48 : 64,
                    color: AppColors.textSecondary.withOpacity(0.5),
                  ),
                  SizedBox(height: isSmallMobile ? 12 : 16),
                  Text(
                    'Error loading articles',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallMobile ? 16 : (isMobile ? 17 : 18),
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallMobile ? 6 : 8),
                  Text(
                    articleProvider.error!,
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: isSmallMobile ? 12 : 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: isSmallMobile ? 12 : 16),
                  ElevatedButton(
                    onPressed: () => articleProvider.initialize(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: AppColors.onPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallMobile ? 16 : 20,
                        vertical: isSmallMobile ? 10 : 12,
                      ),
                    ),
                    child: Text(
                      'Retry', 
                      style: GoogleFonts.poppins(
                        fontSize: isSmallMobile ? 12 : 14,
                        fontWeight: FontWeight.w600,
                      )
                    ),
                  ),
                ],
              ),
            );
          }
          return Stack(
            children: [
              Column(
                children: [
                  // Search and Filter Section
                  Container(
                    padding: EdgeInsets.all(isSmallMobile ? 8 : (isMobile ? 12 : 20)),
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        // Search Bar and Trash Button Row
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: articleProvider.setSearchQuery,
                                style: GoogleFonts.poppins(fontSize: isSmallMobile ? 12 : (isMobile ? 13 : 15)),
                                decoration: InputDecoration(
                                  hintText: 'Search articles...',
                                  prefixIcon: Icon(
                                    Icons.search_rounded, 
                                    color: AppColors.secondary,
                                    size: isSmallMobile ? 20 : 24,
                                  ),
                                  suffixIcon: _searchController.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear_rounded, 
                                            color: AppColors.textSecondary,
                                            size: isSmallMobile ? 18 : 24,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            articleProvider.setSearchQuery('');
                                          },
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 16),
                                    borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 16),
                                    borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 16),
                                    borderSide: BorderSide(color: AppColors.secondary, width: 2),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: isSmallMobile ? 8 : (isMobile ? 10 : 16),
                                    horizontal: isSmallMobile ? 8 : (isMobile ? 10 : 16),
                                ),
                              ),
                            ),
                            ),
                            SizedBox(width: isSmallMobile ? 8 : 12),
                            // Trash Button
                            Container(
                              decoration: BoxDecoration(
                                color: articleProvider.statusFilter == ArticleStatus.deleted 
                                    ? Colors.red 
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 16),
                                border: Border.all(
                                  color: articleProvider.statusFilter == ArticleStatus.deleted 
                                      ? Colors.red 
                                      : AppColors.secondary.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: IconButton(
                                onPressed: () {
                                  if (articleProvider.statusFilter == ArticleStatus.deleted) {
                                    articleProvider.setStatusFilter(null);
                                  } else {
                                    articleProvider.setStatusFilter(ArticleStatus.deleted);
                                  }
                                },
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  color: articleProvider.statusFilter == ArticleStatus.deleted 
                                      ? Colors.white 
                                      : Colors.red,
                                  size: isSmallMobile ? 20 : 24,
                                ),
                                tooltip: articleProvider.statusFilter == ArticleStatus.deleted 
                                    ? 'Hide Trash' 
                                    : 'Show Trash',
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallMobile ? 8 : 12),
                        // Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                    children: [
                              _FilterChip(
                                label: 'All',
                                isSelected: articleProvider.statusFilter == null && articleProvider.categoryFilter == null,
                                onTap: () => articleProvider.clearFilters(),
                              ),
                              SizedBox(width: isSmallMobile ? 6 : 8),
                              _FilterChip(
                                label: 'Draft',
                                isSelected: articleProvider.statusFilter == ArticleStatus.draft,
                                onTap: () => articleProvider.setStatusFilter(ArticleStatus.draft),
                              ),
                              SizedBox(width: isSmallMobile ? 6 : 8),
                              _FilterChip(
                                label: 'Published',
                                isSelected: articleProvider.statusFilter == ArticleStatus.published,
                                onTap: () => articleProvider.setStatusFilter(ArticleStatus.published),
                              ),
                              SizedBox(width: isSmallMobile ? 6 : 8),
                              _FilterChip(
                                label: 'Archived',
                                isSelected: articleProvider.statusFilter == ArticleStatus.archived,
                                onTap: () => articleProvider.setStatusFilter(ArticleStatus.archived),
                              ),
                              SizedBox(width: isSmallMobile ? 6 : 8),
                              _FilterChip(
                                label: 'Trash',
                                isSelected: articleProvider.statusFilter == ArticleStatus.deleted,
                                onTap: () => articleProvider.setStatusFilter(ArticleStatus.deleted),
                              ),
                              SizedBox(width: isSmallMobile ? 12 : 16),
                              // Category filters
                              ...ArticleProvider.categories.map((category) => Padding(
                                padding: EdgeInsets.only(right: isSmallMobile ? 6 : 8),
                                child: _FilterChip(
                                  label: category,
                                  isSelected: articleProvider.categoryFilter == category,
                                  onTap: () => articleProvider.setCategoryFilter(category),
                                ),
                              )),
                            ],
                          ),
                      ),
                    ],
                  ),
                ),
                  // Articles List
                  Expanded(
                    child: articleProvider.filteredArticles.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: isSmallMobile ? 48 : 64,
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                ),
                                SizedBox(height: isSmallMobile ? 12 : 16),
                                Text(
                                  'No articles found',
                                  style: GoogleFonts.poppins(
                                    fontSize: isSmallMobile ? 16 : (isMobile ? 17 : 18),
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: isSmallMobile ? 6 : 8),
                                Text(
                                  'Try adjusting your search or filters',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.textSecondary,
                                    fontSize: isSmallMobile ? 12 : 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.all(isSmallMobile ? 6 : (isMobile ? 8 : 20)),
                            itemCount: articleProvider.filteredArticles.length,
                            // ignore: unnecessary_underscores
                            separatorBuilder: (_, __) => SizedBox(height: isSmallMobile ? 12 : 16),
                            itemBuilder: (context, index) {
                              final article = articleProvider.filteredArticles[index];
                              return _ArticleCard(
                                article: article,
                                onEdit: () => _openForm(article),
                                onDelete: () => _showDeleteConfirmation(article),
                                onPreview: () => _showPreview(article),
                                onPublish: () => articleProvider.publishArticle(article.id),
                                onArchive: () => articleProvider.archiveArticle(article.id),
                                onPermanentDelete: () => _showPermanentDeleteConfirmation(article),
                              );
                            },
                          ),
                  ),
                ],
          ),
        ],
          );
        },
      ),
      floatingActionButton: AnimatedScale(
        scale: false ? 0.0 : 1.0, 
        duration: const Duration(milliseconds: 250),
        child: AnimatedOpacity(
          opacity: false ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: FloatingActionButton.extended(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.onPrimary,
            onPressed: () => _openForm(),
            icon: Icon(Icons.add_rounded, size: isSmallMobile ? 20 : 24),
            label: Text(
              'New Article', 
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: isSmallMobile ? 12 : 14,
              )
            ),
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallMobile = screenWidth < 400;
    
    return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 20),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallMobile ? 12 : 16, 
            vertical: isSmallMobile ? 6 : 8
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : AppColors.background,
            borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 20),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.secondary.withOpacity(0.3),
              width: isSmallMobile ? 1.0 : 1.5,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: isSmallMobile ? 11 : 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? AppColors.onPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPreview;
  final VoidCallback onPublish;
  final VoidCallback onArchive;
  final VoidCallback onPermanentDelete;

  const _ArticleCard({
    required this.article,
    required this.onEdit,
    required this.onDelete,
    required this.onPreview,
    required this.onPublish,
    required this.onArchive,
    required this.onPermanentDelete,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 400;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isSmallMobile ? 10 : 12)),
      child: Padding(
        padding: EdgeInsets.all(isSmallMobile ? 8 : (isMobile ? 12 : 16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
          children: [
                // Article image
                  ClipRRect(
                  borderRadius: BorderRadius.circular(isSmallMobile ? 6 : 8),
                    child: Container(
                    width: isSmallMobile ? 50 : 60,
                    height: isSmallMobile ? 50 : 60,
                        color: AppColors.background,
                    child: article.featuredImage != null
                          ? (article.featuredImage!.startsWith('assets/')
                              ? Image.asset(
                            article.featuredImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.image_not_supported_rounded,
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                  size: isSmallMobile ? 16 : 20,
                                );
                              },
                            )
                              : kIsWeb
                                  ? Image.asset(
                                      'assets/images/news1.png',
                                      fit: BoxFit.cover,
                                    )
                                  : Image.file(
                                      File(article.featuredImage!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(
                                          Icons.image_not_supported_rounded,
                                          color: AppColors.textSecondary.withOpacity(0.5),
                                          size: isSmallMobile ? 16 : 20,
                                        );
                                      },
                                    ))
                          : Icon(
                            Icons.article_rounded,
                            color: AppColors.secondary,
                            size: isSmallMobile ? 20 : 24,
                            ),
                    ),
                  ),
                SizedBox(width: isSmallMobile ? 8 : 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                        article.title,
                          style: GoogleFonts.poppins(
                          fontSize: isSmallMobile ? 12 : (isMobile ? 14 : 16),
                                fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: isSmallMobile ? 2 : 4),
                      Text(
                        'By ${article.author}',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallMobile ? 10 : 12,
                          color: AppColors.textSecondary,
                        ),
                        ),
                      SizedBox(height: isSmallMobile ? 2 : 4),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallMobile ? 6 : 8, 
                          vertical: isSmallMobile ? 2 : 4
                        ),
                          decoration: BoxDecoration(
                          color: _getStatusColor(article.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(isSmallMobile ? 6 : 8),
                          ),
                        child: Text(
                          _getStatusText(article.status),
                          style: GoogleFonts.poppins(
                            fontSize: isSmallMobile ? 8 : 10,
                            fontWeight: FontWeight.w600,
                            color: _getStatusColor(article.status),
                          ),
                    ),
                  ),
                ],
              ),
            ),
              ],
            ),
            SizedBox(height: isSmallMobile ? 8 : 12), 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                            IconButton(
                  onPressed: onPreview,
                  icon: Icon(
                    Icons.preview_rounded, 
                    size: isSmallMobile ? 16 : 20
                  ),
                              tooltip: 'Preview',
                              color: AppColors.secondary,
                      ),
                            IconButton(
                  onPressed: onEdit,
                  icon: Icon(
                    Icons.edit_rounded, 
                    size: isSmallMobile ? 16 : 20
                  ),
                              tooltip: 'Edit',
                              color: AppColors.primary,
                      ),
                if (article.status == ArticleStatus.draft)
                  IconButton(
                    onPressed: () async {
                      final articleProvider = context.read<ArticleProvider>();
                      final updated = article.copyWith(
                        status: ArticleStatus.published,
                        publishedAt: article.publishedAt ?? DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      await articleProvider.updateArticle(updated);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Article published!', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                      // UI will update automatically via provider
                    },
                    icon: Icon(
                      Icons.publish_rounded, 
                      size: isSmallMobile ? 16 : 20
                    ),
                    tooltip: 'Publish',
                    color: Colors.green,
                  ),
                if (article.status == ArticleStatus.published)
                  IconButton(
                    onPressed: onArchive,
                    icon: Icon(
                      Icons.archive_rounded, 
                      size: isSmallMobile ? 16 : 20
                    ),
                    tooltip: 'Archive',
                    color: Colors.orange,
                          ),
                if (article.status == ArticleStatus.deleted) ...[
                  IconButton(
                    onPressed: () {
                      context.read<ArticleProvider>().restoreArticle(article.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Article restored', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.restore_rounded, 
                      size: isSmallMobile ? 16 : 20
                    ),
                    tooltip: 'Restore',
                    color: Colors.green,
                  ),
                  IconButton(
                    onPressed: onPermanentDelete,
                    icon: Icon(
                      Icons.delete_forever_rounded, 
                      size: isSmallMobile ? 16 : 20
                    ),
                    tooltip: 'Permanently Delete',
                    color: Colors.red,
                  ),
                ] else
                  IconButton(
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_rounded, 
                      size: isSmallMobile ? 16 : 20
                    ),
                    tooltip: 'Move to Trash',
                    color: Colors.red,
                  ),
              ],
            ),
          ],
        ),
      ),
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

class _ArticleForm extends StatefulWidget {
  final Article? article;
  final VoidCallback onCancel;
  final ValueChanged<String> onSave;

  const _ArticleForm({
    this.article,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<_ArticleForm> createState() => _ArticleFormState();
}

class _ArticleFormState extends State<_ArticleForm> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _authorController = TextEditingController();
  final _excerptController = TextEditingController();
  final _readTimeController = TextEditingController();
  final _imageUrlController = TextEditingController();
  
  ArticleStatus _selectedStatus = ArticleStatus.draft;
  Set<String> _selectedCategories = {};
  bool _isLoading = false;
  File? _selectedImageFile;
  String? _selectedAssetImage; 

  Future<void> _pickImage() async {
    if (_selectedCategories.contains('Gallery')) {
      // Do nothing, handled by asset picker below
      return;
    }
    if (kIsWeb) {
      // Use FilePicker for web/desktop
      try {
        FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        
        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          setState(() {
            _imageUrlController.text = file.name;
            // For web, we store the file name since we can't access the actual file path
            _selectedImageFile = null; 
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Image selected: ${file.name}', style: GoogleFonts.poppins()),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: ${e.toString()}', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Use ImagePicker for mobile
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
        requestFullMetadata: false,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImageFile = File(pickedFile.path);
          _imageUrlController.text = pickedFile.path;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      _titleController.text = widget.article!.title;
      _contentController.text = widget.article!.content;
      _authorController.text = widget.article!.author;
      _excerptController.text = widget.article!.excerpt;
      _readTimeController.text = widget.article!.readTime.toString();
      _imageUrlController.text = widget.article!.featuredImage ?? '';
      if (widget.article!.featuredImage != null && widget.article!.featuredImage!.startsWith('assets/')) {
        _selectedAssetImage = widget.article!.featuredImage;
        _selectedImageFile = null;
      } else if (widget.article!.featuredImage != null && widget.article!.featuredImage!.isNotEmpty) {
        _selectedImageFile = File(widget.article!.featuredImage!);
        _selectedAssetImage = null;
      } else {
        _selectedAssetImage = null;
        _selectedImageFile = null;
      }
      _selectedStatus = widget.article!.status;
      _selectedCategories = Set.from(widget.article!.categories);
    }
  }

  void _updateStatusOnly(ArticleStatus newStatus) async {
    if (widget.article == null) return;
    final articleProvider = context.read<ArticleProvider>();
    final updated = widget.article!.copyWith(
      status: newStatus,
      updatedAt: DateTime.now(),
    );
    await articleProvider.updateArticle(updated);
    setState(() => _selectedStatus = newStatus);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${_getStatusText(newStatus)}', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _authorController.dispose();
    _excerptController.dispose();
    _readTimeController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ArticleForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When editing a new article, re-initialize the form fields
    if (widget.article != null && widget.article != oldWidget.article) {
      _titleController.text = widget.article!.title;
      _contentController.text = widget.article!.content;
      _authorController.text = widget.article!.author;
      _excerptController.text = widget.article!.excerpt;
      _readTimeController.text = widget.article!.readTime.toString();
      _imageUrlController.text = widget.article!.featuredImage ?? '';
      if (widget.article!.featuredImage != null && widget.article!.featuredImage!.startsWith('assets/')) {
        _selectedAssetImage = widget.article!.featuredImage;
        _selectedImageFile = null;
      } else if (widget.article!.featuredImage != null && widget.article!.featuredImage!.isNotEmpty) {
        _selectedImageFile = File(widget.article!.featuredImage!);
        _selectedAssetImage = null;
      } else {
        _selectedAssetImage = null;
        _selectedImageFile = null;
      }
      _selectedStatus = widget.article!.status;
      _selectedCategories = Set.from(widget.article!.categories);
    }
  }

  Future<void> _saveArticle() async {
    final articleProviderLocal = context.read<ArticleProvider>();
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one category.', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter article content.', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final old = widget.article;
      final article = Article(
        id: old?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text.trim(),
        content: content,
        excerpt: _excerptController.text.trim().isEmpty 
            ? (content.length > 100 ? content.substring(0, 100) + '...' : content)
            : _excerptController.text.trim(),
        author: _authorController.text.trim(),
        categories: _selectedCategories.toList(),
        featuredImage: _selectedCategories.contains('Gallery') ? _selectedAssetImage : (_selectedImageFile?.path ?? _imageUrlController.text.trim()),
        status: _selectedStatus,
        readTime: int.tryParse(_readTimeController.text.trim()) ?? 1,
        publishedAt: _selectedStatus == ArticleStatus.published && old?.publishedAt == null
            ? DateTime.now()
            : old?.publishedAt,
        scheduledAt: old?.scheduledAt,
        updatedAt: DateTime.now(),
        likes: old?.likes ?? 0,
        comments: old?.comments ?? 0,
        views: old?.views ?? 0,
        shares: old?.shares ?? 0,
        metaTitle: old?.metaTitle,
        metaDescription: old?.metaDescription,
        keywords: old?.keywords ?? const [],
        slug: old?.slug,
        lastSaved: old?.lastSaved,
        hasUnsavedChanges: old?.hasUnsavedChanges ?? false,
      );
      if (widget.article != null) {
        await articleProviderLocal.updateArticle(article);
      } else {
        await articleProviderLocal.createArticle(article);
      }
      if (mounted) {
        widget.onSave(widget.article != null ? 'Article updated successfully!' : 'Article created successfully!');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving article: ${e.toString()}', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildImagePreview() {
    if (_selectedAssetImage != null && _selectedAssetImage!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          _selectedAssetImage!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    } else if (_selectedImageFile != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedImageFile!,
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      );
    } else if (kIsWeb && _imageUrlController.text.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 30, color: AppColors.secondary),
              const SizedBox(height: 4),
              Text(
                'Image\nSelected',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                _imageUrlController.text.isNotEmpty 
                    ? _imageUrlController.text.split('/').last.split('\\').last
                    : 'File',
                style: GoogleFonts.poppins(
                  fontSize: 8,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    } else if (widget.article != null && widget.article!.featuredImage != null && widget.article!.featuredImage!.isNotEmpty) {
      if (widget.article!.featuredImage!.startsWith('assets/')) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            widget.article!.featuredImage!,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        );
      } else {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(widget.article!.featuredImage!),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        );
      }
    } else {
      return Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondary.withOpacity(0.2)),
        ),
        child: const Icon(Icons.image, size: 40, color: Colors.grey),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isSmallMobile = screenWidth < 400;
    final size = MediaQuery.of(context).size;
    
    bool isGallery = _selectedCategories.contains('Gallery');
    // Reset image state when switching between gallery/non-gallery
    // ignore: no_leading_underscores_for_local_identifiers
    void _handleCategoryChange(String category, bool selected) {
      setState(() {
        if (selected) {
          _selectedCategories.add(category);
        } else {
          _selectedCategories.remove(category);
        }
        // Reset image state when switching
        if (_selectedCategories.contains('Gallery')) {
          _selectedImageFile = null;
          _selectedAssetImage = null;
          _imageUrlController.clear();
        } else {
          _selectedAssetImage = null;
          _imageUrlController.clear();
        }
      });
    }
    
    return Center(
        child: Container(
        width: isSmallMobile ? size.width * 0.95 : (isMobile ? size.width * 0.9 : (size.width > 600 ? 600 : size.width * 0.9)),
          margin: EdgeInsets.symmetric(vertical: isSmallMobile ? 8 : 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(isSmallMobile ? 20 : 24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.2),
                blurRadius: 24,
              offset: const Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Container(
              padding: EdgeInsets.all(isSmallMobile ? 12 : (isMobile ? 16 : 24)),
                decoration: BoxDecoration(
                  color: AppColors.surface,
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
                      widget.article != null ? Icons.edit_rounded : Icons.add_rounded,
                      color: AppColors.secondary,
                      size: isSmallMobile ? 22 : (isMobile ? 26 : 28),
                    ),
                    SizedBox(width: isSmallMobile ? 8 : 12),
                    Expanded(
                      child: Text(
                        widget.article != null ? 'Edit Article' : 'Create New Article',
                        style: GoogleFonts.poppins(
                        fontSize: isSmallMobile ? 14 : (isMobile ? 18 : 20),
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: widget.onCancel,
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: isSmallMobile ? 20 : 24,
                      ),
                      tooltip: 'Close',
                    ),
                  ],
                ),
              ),
              // Form Content
              Expanded(
          child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallMobile ? 12 : (isMobile ? 16 : 24)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                        // Image Picker or Asset Picker
                        Text(
                          'Featured Image',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallMobile ? 12 : 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: isSmallMobile ? 6 : 8),
                        if (isGallery) ...[
                          // Asset image picker grid
                          SizedBox(
                            height: 120,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: galleryImages.length,
                              // ignore: unnecessary_underscores
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, idx) {
                                final img = galleryImages[idx];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedAssetImage = img;
                                      _imageUrlController.text = img;
                                    });
                                  },
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _selectedAssetImage == img ? AppColors.secondary : Colors.transparent,
                                        width: 3,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(img, fit: BoxFit.cover, width: 100, height: 100),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          if (_selectedAssetImage != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('Selected: ${_selectedAssetImage!.split('/').last}', style: GoogleFonts.poppins(fontSize: 12)),
                            ),
                        ] else ...[
                          Row(
                            children: [
                              _buildImagePreview(),
                              const SizedBox(width: 16),
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.image_search_rounded),
                                label: const Text('Import Image'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: AppColors.onPrimary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 16),
                        // Title Field
                  TextFormField(
                    controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Title *',
                            prefixIcon: Icon(Icons.title_rounded, color: AppColors.secondary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.secondary, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          style: GoogleFonts.poppins(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Title is required';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 16),
                        // Author Field
                  TextFormField(
                          controller: _authorController,
                          decoration: InputDecoration(
                            labelText: 'Author *',
                            prefixIcon: Icon(Icons.person_rounded, color: AppColors.secondary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.secondary, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          style: GoogleFonts.poppins(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Author is required';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 16),
                        // Excerpt Field
                        TextFormField(
                          controller: _excerptController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Excerpt (Optional)',
                            hintText: 'Brief summary of the article...',
                            prefixIcon: Icon(Icons.description_rounded, color: AppColors.secondary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.secondary, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          style: GoogleFonts.poppins(),
                        ),
                        const SizedBox(height: 16),
                        // Read Time Field
                        TextFormField(
                          controller: _readTimeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Read Time (minutes)',
                            hintText: 'e.g., 3',
                            prefixIcon: Icon(Icons.timer_rounded, color: AppColors.secondary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.secondary, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          style: GoogleFonts.poppins(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Read time is required';
                            }
                            final readTime = int.tryParse(value.trim());
                            if (readTime == null || readTime <= 0) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      // Categories
                      Text(
                        'Categories *',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                            ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ArticleProvider.categories.map((category) {
                          final isSelected = _selectedCategories.contains(category);
                          return FilterChip(
                            label: Text(category, style: GoogleFonts.poppins()),
                            selected: isSelected,
                              onSelected: (selected) => _handleCategoryChange(category, selected),
                            backgroundColor: AppColors.background,
                            selectedColor: AppColors.secondary.withOpacity(0.2),
                            checkmarkColor: AppColors.secondary,
                            labelStyle: GoogleFonts.poppins(
                              color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppColors.secondary : AppColors.secondary.withOpacity(0.3),
                              ),
                            ),
                          );
                        }).toList(),
                        ),
                      const SizedBox(height: 16),
                      // Status
                        DropdownButtonFormField<ArticleStatus>(
                          value: _selectedStatus,
                          decoration: InputDecoration(
                            labelText: 'Status *',
                            prefixIcon: Icon(Icons.publish_rounded, color: AppColors.secondary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.secondary, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          style: GoogleFonts.poppins(),
                          items: ArticleStatus.values.map((status) {
                            return DropdownMenuItem(
                              value: status,
                              child: Row(
                                children: [
                                  Icon(
                                    _getStatusIcon(status),
                                    color: _getStatusColor(status),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _getStatusText(status),
                                    style: GoogleFonts.poppins(),
                      ),
                    ],
                  ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              if (widget.article != null) {
                                _updateStatusOnly(value);
                              } else {
                                setState(() => _selectedStatus = value);
                              }
                            }
                          },
                        ),
                      const SizedBox(height: 16),
                      // Content
                        TextFormField(
                          controller: _contentController,
                          maxLines: 15,
                          decoration: InputDecoration(
                          labelText: 'Content *',
                          hintText: 'Write your article content here...',
                            prefixIcon: Icon(Icons.edit_note_rounded, color: AppColors.secondary),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.secondary.withOpacity(0.3)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: AppColors.secondary, width: 2),
                            ),
                            filled: true,
                            fillColor: AppColors.background,
                          ),
                          style: GoogleFonts.poppins(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Content is required';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 24),
                        // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary, width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        onPressed: widget.onCancel,
                              child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                          foregroundColor: AppColors.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              ),
                              onPressed: _isLoading ? null : _saveArticle,
                              child: _isLoading
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.onPrimary),
                                      ),
                                    )
                                  : Text(
                                      widget.article != null ? 'Update' : 'Create',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                    ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
                ),
              ),
            ],
        ),
      ),
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

  // Helper to display article images from asset or file
  Widget buildArticleImage(String? path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (path == null || path.isEmpty) {
      return Container(
        width: width,
        height: height,
        color: AppColors.background,
        child: const Icon(Icons.image, color: Colors.grey),
      );
    }
    if (path.startsWith('assets/')) {
      return Image.asset(path, width: width, height: height, fit: fit, errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: AppColors.background,
          child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
        );
      });
    } else {
      return kIsWeb
        ? Image.asset('assets/images/news1.png', width: width, height: height, fit: fit)
        : Image.file(File(path), width: width, height: height, fit: fit, errorBuilder: (context, error, stackTrace) {
            return Container(
              width: width,
              height: height,
              color: AppColors.background,
              child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
            );
          });
    }
  }
} 