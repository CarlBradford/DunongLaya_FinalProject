import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/article_provider.dart';
import '../article/article_detail_page.dart';
import '../profile/profile_page.dart';
import '../../models/articles.dart';
import 'package:dunonglaya_finalproject_app/screens/about_us.dart';
import 'package:dunonglaya_finalproject_app/screens/contact_us.dart';
import 'package:intl/intl.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

// Gallery images for the Gallery category
final List<String> galleryImages = [
  'assets/images/news1.png',
  'assets/images/news2.png',
  'assets/images/news3.png',
  'assets/images/news4.png',
  'assets/images/news5.png',
  'assets/images/sports1.png',
  'assets/images/sports2.png',
  'assets/images/sports3.png',
  'assets/images/sports4.png',
  'assets/images/sports5.png',
  'assets/images/featured1.png',
  'assets/images/featured2.png',
  'assets/images/featured3.png',
  'assets/images/academics1.png',
  'assets/images/academics2.png',
  'assets/images/academics3.png',
  'assets/images/academics4.png',
  'assets/images/academics5.png',
];

class CategoryItem {
  final String id;
  final String label;
  final IconData icon;

  CategoryItem({
    required this.id,
    required this.label,
    required this.icon,
  });
}

class StatItem {
  final String label;
  final String value;
  final IconData icon;

  StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });
}

final List<CategoryItem> allCategories = [
  CategoryItem(id: 'latest', label: 'Latest', icon: Icons.newspaper),
  CategoryItem(id: 'featured', label: 'Featured', icon: Icons.star),
  CategoryItem(id: 'news', label: 'News', icon: Icons.campaign),
  CategoryItem(id: 'sports', label: 'Sports', icon: Icons.sports_basketball),
  CategoryItem(id: 'academics', label: 'Academics', icon: Icons.school),
  CategoryItem(id: 'feature', label: 'Feature', icon: Icons.edit),
  CategoryItem(id: 'gallery', label: 'Gallery', icon: Icons.photo_library),
];

final List<CategoryItem> visibleCategories = [
  CategoryItem(id: 'news', label: 'News', icon: Icons.campaign),
  CategoryItem(id: 'sports', label: 'Sports', icon: Icons.sports_basketball),
  CategoryItem(id: 'academics', label: 'Academics', icon: Icons.school),
  CategoryItem(id: 'feature', label: 'Feature', icon: Icons.edit),
  CategoryItem(id: 'gallery', label: 'Gallery', icon: Icons.photo_library),
];

final List<StatItem> quickStats = [
  StatItem(label: 'Articles Published', value: '1,247', icon: Icons.article),
  StatItem(label: 'Active Writers', value: '89', icon: Icons.people),
  StatItem(label: 'Monthly Readers', value: '15.2K', icon: Icons.book),
  StatItem(label: 'Campus Events', value: '23', icon: Icons.calendar_today),
];

class StudentPublicationApp extends StatelessWidget {
  const StudentPublicationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The AXIS - Student Publication',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: GoogleFonts.poppins().fontFamily,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation: 1,
          titleTextStyle: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class _StatItemCard extends StatelessWidget {
  final StatItem stat;
  final bool isMobile;
  const _StatItemCard({required this.stat, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent, // No background color
        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        // No boxShadow for flat look
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 18,
        vertical: isMobile ? 8 : 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            stat.icon,
            color: Colors.white,
            size: isMobile ? 22 : 28,
          ),
          SizedBox(height: isMobile ? 4 : 8),
          Text(
            stat.value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isMobile ? 15 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            stat.label,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: isMobile ? 10 : 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedBottomTab = 0;
  String _selectedCategory = 'latest';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedSort = 'recent';
  final ScrollController _scrollController = ScrollController();

  // Get articles from ArticleProvider instead of static mock data
  List<Article> get publishedArticles => context.read<ArticleProvider>().articles.where((article) => 
    article.status == ArticleStatus.published && article.status != ArticleStatus.deleted
  ).toList();
  
  List<Article> get filteredFeaturedArticles {
    final articles = context.read<ArticleProvider>().articles.where((a) => a.status != ArticleStatus.deleted);
    if (_selectedCategory == 'latest') {
      final latest = articles.where((a) => a.status == ArticleStatus.published).toList();
      latest.sort((a, b) => (b.publishedAt ?? DateTime(1970)).compareTo(a.publishedAt ?? DateTime(1970)));
      return latest.take(6).toList();
    } else if (_selectedCategory == 'featured') {
      return articles.where((a) => a.status == ArticleStatus.published).toList();
    } else {
      final catLabel = allCategories.firstWhere((c) => c.id == _selectedCategory).label.toLowerCase();
      return articles.where((a) => a.status == ArticleStatus.published && a.categories.any((cat) => cat.toLowerCase() == catLabel)).toList();
    }
  }

  List<Article> get filteredRegularArticles {
    final articles = context.read<ArticleProvider>().articles.where((a) => a.status != ArticleStatus.deleted);
    if (_selectedCategory == 'latest') {
      final latest = articles.where((a) => a.status == ArticleStatus.published).toList();
      latest.sort((a, b) => (b.publishedAt ?? DateTime(1970)).compareTo(a.publishedAt ?? DateTime(1970)));
      return latest.take(6).toList();
    } else if (_selectedCategory == 'featurred') {
      return [];
    } else if (_selectedCategory == 'feature') {
      // Show only the three feature articles in the Feature tab
      return articles.where((a) => ['3006', '3007', '3008'].contains(a.id)).toList();
    } else {
      final catLabel = allCategories.firstWhere((c) => c.id == _selectedCategory).label.toLowerCase();
      return articles.where((a) => a.status == ArticleStatus.published && a.categories.any((cat) => cat.toLowerCase() == catLabel)).toList();
    }
  }

  // Returns the most popular published article for each main category
  List<Article> get featuredByCategory {
    final articles = context.read<ArticleProvider>().articles.where((a) => a.status != ArticleStatus.deleted);
    final categories = ['News', 'Sports', 'Academics', 'Feature'];
    List<Article> result = [];
    for (final cat in categories) {
      final articlesInCat = articles.where((a) => a.status == ArticleStatus.published && a.categories.any((c) => c.toLowerCase() == cat.toLowerCase())).toList();
      if (articlesInCat.isNotEmpty) {
        articlesInCat.sort((a, b) => b.views.compareTo(a.views));
        result.add(articlesInCat.first);
      }
    }
    return result;
  }

  // For displaying date:
  String getFormattedDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('MMMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(),
      drawer: _buildDrawer(),
      body: Consumer<ArticleProvider>(
        builder: (context, articleProvider, child) {
          // Show loading state if articles are being loaded
          if (articleProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.secondary),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () async {
              // Refresh articles when user pulls down
              await articleProvider.initialize();
            },
            color: AppColors.secondary,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  if (_selectedBottomTab != 1) _buildCategoryTabs(),
                  if (_selectedBottomTab != 1) _buildStatsBar(),
                  if (_selectedBottomTab != 1 && _selectedCategory != 'gallery') _buildFeaturedSection(),
                  if (_selectedBottomTab == 1)
                    Consumer<AppStateProvider>(
                      builder: (context, appState, _) {
                        return _buildArticleGrid(appState);
                      },
                    )
                  else if (_selectedCategory == 'gallery') ...[
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Gallery',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildGalleryGrid(),
                  ] else ...[
                    Consumer<AppStateProvider>(
                      builder: (context, appState, _) => _buildArticleGrid(appState),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      shape: null, 
      toolbarHeight: 72, 
      title: LayoutBuilder(
        builder: (context, constraints) {
          final isMobile = constraints.maxWidth < 600;
          final isSmallMobile = constraints.maxWidth < 400;
          
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 4), 
              Container(
                width: isSmallMobile ? 32 : (isMobile ? 36 : 40),
                height: isSmallMobile ? 32 : (isMobile ? 36 : 40),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isSmallMobile ? 8 : 10),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/the_axis_logo.png', 
                    width: isSmallMobile ? 32 : (isMobile ? 36 : 40),
                    height: isSmallMobile ? 32 : (isMobile ? 36 : 40),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(width: isSmallMobile ? 8 : (isMobile ? 10 : 12)),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'DunongLaya',
                      style: GoogleFonts.playfairDisplay(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallMobile ? 14 : (isMobile ? 16 : 20),
                        letterSpacing: isSmallMobile ? 0.8 : 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      'A Student Publication Platform for The AXIS',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallMobile ? 9 : (isMobile ? 10 : 10),
                        color: AppColors.onPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      centerTitle: false,
      actions: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            final isSmallMobile = constraints.maxWidth < 400;
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.search,
                    size: isSmallMobile ? 20 : (isMobile ? 22 : 24),
                  ),
                  onPressed: () => _showSearchDialog(),
                  padding: EdgeInsets.all(isSmallMobile ? 4 : 8),
                  constraints: BoxConstraints(
                    minWidth: isSmallMobile ? 32 : 40,
                    minHeight: isSmallMobile ? 32 : 40,
                  ),
                ),
                SizedBox(width: isSmallMobile ? 4 : 8),
                if (Provider.of<AppStateProvider>(context).role != UserRole.reader) ...[
                  IconButton(
                    icon: Icon(
                      Icons.person_outline,
                      size: isSmallMobile ? 20 : (isMobile ? 22 : 24),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      );
                    },
                    padding: EdgeInsets.all(isSmallMobile ? 4 : 8),
                    constraints: BoxConstraints(
                      minWidth: isSmallMobile ? 32 : 40,
                      minHeight: isSmallMobile ? 32 : 40,
                    ),
                  ),
                  SizedBox(width: isSmallMobile ? 4 : 8),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                            child: Image.asset(
                            'assets/images/the_axis_logo.png', 
                            width: 55,
                            height: 55,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'DunongLaya',
                        style: GoogleFonts.playfairDisplay(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'A Student Publication Platform for The AXIS',
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildDrawerItem(Icons.home, 'Home', () {
                  setState(() {
                    _selectedBottomTab = 0;
                    _selectedCategory = 'latest';
                  });
                  Navigator.of(context).pop();
                }),
                _buildDrawerItem(Icons.newspaper, 'News', () {
                  setState(() {
                    _selectedBottomTab = 0;
                    _selectedCategory = 'news';
                  });
                  Navigator.of(context).pop();
                }),
                _buildDrawerItem(Icons.sports_basketball, 'Sports', () {
                  setState(() {
                    _selectedBottomTab = 0;
                    _selectedCategory = 'sports';
                  });
                  Navigator.of(context).pop();
                }),
                _buildDrawerItem(Icons.school, 'Academics', () {
                  setState(() {
                    _selectedBottomTab = 0;
                    _selectedCategory = 'academics';
                  });
                  Navigator.of(context).pop();
                }),
                _buildDrawerItem(Icons.edit, 'Feature', () {
                  setState(() {
                    _selectedBottomTab = 0;
                    _selectedCategory = 'feature';
                  });
                  Navigator.of(context).pop();
                }),
                _buildDrawerItem(Icons.photo_library, 'Gallery', () {
                  setState(() {
                    _selectedBottomTab = 0;
                    _selectedCategory = 'gallery';
                  });
                  Navigator.of(context).pop();
                }),
                const Divider(),
                _buildDrawerItem(Icons.info, 'About Us', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutUsPage()),
                  );
                }),
                _buildDrawerItem(Icons.contact_mail, 'Contact Us', () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ContactUsPage()),
                  );
                }),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text(
                'Go Back',
                style: GoogleFonts.poppins(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                final appState = Provider.of<AppStateProvider>(context, listen: false);
                appState.setRole(UserRole.reader);
                appState.setScreen(AppScreen.welcome);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: AppColors.background,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: visibleCategories.map((category) {
            final isSelected = _selectedCategory == category.id;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category.id;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.textSecondary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      category.icon,
                      size: 18,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.label,
                      style: GoogleFonts.poppins(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return Consumer<ArticleProvider>(
      builder: (context, articleProvider, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 500;
            if (isMobile) return const SizedBox.shrink();
            
            final publishedCount = articleProvider.getPublishedArticleCount();
            final totalViews = articleProvider.articles
                .where((article) => article.status != ArticleStatus.deleted)
                .fold<int>(0, (sum, article) => sum + article.views);
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.secondary.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItemCard(
                      stat: StatItem(
                        label: 'Published',
                        value: '$publishedCount',
                        icon: Icons.article_rounded,
                      ),
                      isMobile: false,
                    ),
                    _StatItemCard(
                      stat: StatItem(
                        label: 'Readers',
                        value: '2.5K+',
                        icon: Icons.people_rounded,
                      ),
                      isMobile: false,
                    ),
                    _StatItemCard(
                      stat: StatItem(
                        label: 'Views',
                        // ignore: unnecessary_string_interpolations
                        value: '${totalViews.toStringAsFixed(0)}',
                        icon: Icons.visibility_rounded,
                      ),
                      isMobile: false,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }


  Widget _buildFeaturedSection() {
    final featured = featuredByCategory;
    if (featured.isEmpty) return const SizedBox.shrink();
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isSmallMobile = constraints.maxWidth < 400;
        
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.all(isSmallMobile ? 12 : (isMobile ? 16 : 20)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Featured Stories',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallMobile ? 16 : (isMobile ? 18 : 22),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              // ignore: sized_box_for_whitespace
              child: Container(
                width: double.infinity,
                child: CarouselSlider(
                  options: CarouselOptions(
                    height: isSmallMobile ? 200 : (isMobile ? 240 : 280),
                    enlargeCenterPage: true,
                    autoPlay: true,
                    aspectRatio: 16 / 9,
                    viewportFraction: isSmallMobile ? 0.85 : (isMobile ? 0.8 : 0.75),
                    padEnds: true,
                  ),
                  items: featured.map((article) {
                    return Builder(
                      builder: (BuildContext context) {
                        return _buildFeaturedCard(article, isMobile: isMobile, isSmallMobile: isSmallMobile);
                      },
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFeaturedCard(Article article, {bool isMobile = false, bool isSmallMobile = false}) {
    // Calculate card width to match the viewportFraction of the CarouselSlider
    double cardWidth = isSmallMobile
        ? MediaQuery.of(context).size.width * 0.85
        : isMobile
            ? MediaQuery.of(context).size.width * 0.8
            : MediaQuery.of(context).size.width * 0.75;
    return GestureDetector(
      onTap: () {
        // Increment views before navigating
        final articleProvider = context.read<ArticleProvider>();
        articleProvider.incrementViews(article.id);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArticleDetailPage(article: article),
          ),
        );
      },
      child: Container(
        width: cardWidth,
        margin: EdgeInsets.symmetric(horizontal: isSmallMobile ? 4 : (isMobile ? 6 : 8)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: isSmallMobile ? 12 : 20,
              offset: Offset(0, isSmallMobile ? 6 : 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 20),
          child: Stack(
            children: [
              SizedBox(
                height: isSmallMobile ? 200 : (isMobile ? 240 : 280),
                width: cardWidth,
                child: buildArticleImage(article.featuredImage, width: cardWidth, fit: BoxFit.cover),
              ),
              Positioned(
                top: isSmallMobile ? 12 : 16,
                left: isSmallMobile ? 12 : 16,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallMobile ? 8 : 12, 
                    vertical: isSmallMobile ? 4 : 6
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(isSmallMobile ? 16 : 20),
                  ),
                  child: Text(
                    article.categories.isNotEmpty ? article.categories[0] : 'Uncategorized',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: isSmallMobile ? 10 : 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: EdgeInsets.all(isSmallMobile ? 12 : (isMobile ? 16 : 20)),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.title,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: isSmallMobile ? 14 : (isMobile ? 16 : 18),
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallMobile ? 6 : 8),
                      Text(
                        article.excerpt,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: isSmallMobile ? 11 : (isMobile ? 12 : 14),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isSmallMobile ? 8 : 12),
                      Row(
                        children: [
                          Text(
                            'By ${article.author}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: isSmallMobile ? 10 : 12,
                            ),
                          ),
                          Text(
                            ' • ${article.readTime}',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: isSmallMobile ? 10 : 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                right: 16,
                top: 16,
                child: Consumer<AppStateProvider>(
                  builder: (context, appState, _) {
                    final isBookmarked = appState.isBookmarked(article.id);
                    return IconButton(
                      icon: Icon(
                        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: isBookmarked ? AppColors.secondary : Colors.white,
                      ),
                      onPressed: () => appState.toggleBookmark(article.id),
                      splashRadius: 22,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleGrid(AppStateProvider appState) {
    final bookmarkedIds = appState.bookmarkedArticleIds;
    final isSavedTab = _selectedBottomTab == 1;
    final articleProvider = context.read<ArticleProvider>();
    List<Article> articlesToShow = isSavedTab
        ? articleProvider.articles.where((a) => bookmarkedIds.contains(a.id) && a.status != ArticleStatus.deleted).toList()
        : filteredRegularArticles;

    // Sort articles based on _selectedSort
    if (_selectedSort == 'recent') {
      articlesToShow.sort((a, b) => b.publishedAt!.compareTo(a.publishedAt!));
    } else if (_selectedSort == 'liked') {
      articlesToShow.sort((a, b) => b.likes.compareTo(a.likes));
    }

    // Always show top 6 for latest
    List<Article> displayArticles = articlesToShow;
    if (_selectedCategory == 'latest' && !isSavedTab) {
      displayArticles = articlesToShow.take(6).toList();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isSmallMobile = constraints.maxWidth < 400;
        
        return Padding(
          padding: EdgeInsets.all(isSmallMobile ? 12 : (isMobile ? 16 : 20)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSavedTab
                      ? 'Saved Articles'
                      : _selectedCategory == 'latest'
                          ? 'Latest Articles'
                          : _selectedCategory == 'featured'
                              ? 'Featured Articles'
                              : '${allCategories.firstWhere((c) => c.id == _selectedCategory).label} ',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallMobile ? 16 : (isMobile ? 18 : 22),
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
              Padding(
                padding: EdgeInsets.only(left: isSmallMobile ? 12 : (isMobile ? 16 : 24)),
                child: DropdownButton<String>(
                  value: _selectedSort,
                  items: [
                    DropdownMenuItem(
                      value: 'recent',
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time, 
                            size: isSmallMobile ? 14 : (isMobile ? 16 : 18), 
                            color: AppColors.primary
                          ),
                          SizedBox(width: isSmallMobile ? 8 : (isMobile ? 10 : 12)),
                          Text(
                            'Most Recent', 
                            style: TextStyle(
                              fontSize: isSmallMobile ? 12 : (isMobile ? 14 : 17)
                            )
                          ),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'liked',
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite, 
                            size: isSmallMobile ? 14 : (isMobile ? 16 : 18), 
                            color: Colors.redAccent
                          ),
                          SizedBox(width: isSmallMobile ? 8 : (isMobile ? 10 : 12)),
                          Text(
                            'Most Liked', 
                            style: TextStyle(
                              fontSize: isSmallMobile ? 12 : (isMobile ? 14 : 17)
                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _selectedSort = value);
                  },
                  underline: Container(),
                  borderRadius: BorderRadius.circular(isSmallMobile ? 12 : 18),
                  dropdownColor: AppColors.surface,
                  style: GoogleFonts.poppins(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: isSmallMobile ? 10 : (isMobile ? 11 : 12),
                  ),
                  icon: Icon(
                    Icons.arrow_drop_down_rounded, 
                    color: AppColors.primary, 
                    size: isSmallMobile ? 20 : (isMobile ? 24 : 30)
                  ),
                  iconSize: isSmallMobile ? 20 : (isMobile ? 24 : 30),
                  isDense: false,
                  alignment: Alignment.centerRight,
                  menuMaxHeight: 300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (isSavedTab && articlesToShow.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(Icons.bookmark_border, size: 60, color: AppColors.textSecondary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No saved articles yet.',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: AppColors.textSecondary.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the bookmark icon on any article to save it here.',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;
                int crossAxisCount;
                double aspectRatio;
                if (width >= 1200) {
                  crossAxisCount = 3;
                  aspectRatio = 1.1;
                }
                else if (width >= 700) {
                  crossAxisCount = 2;
                  aspectRatio = 0.9;
                } else {
                  crossAxisCount = 1;
                  aspectRatio = 0.9;
                }
                return GridView.count(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: aspectRatio,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(displayArticles.length, (index) {
                    return _buildArticleCard(displayArticles[index], isSavedTab: isSavedTab);
                  }),
                );
              },
            ),
          SizedBox(height: isSmallMobile ? 12 : (isMobile ? 16 : 20)),
        ],
      ),
    );
  }
  );
  }

  Widget _buildArticleCard(Article article, {bool isSavedTab = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cardWidth = constraints.maxWidth;
        // Responsive image height
        double imageHeight = cardWidth * 0.45;
        if (imageHeight < 100) imageHeight = 100;
        if (imageHeight > 220) imageHeight = 220;
        // Responsive font sizes
        double titleFont = cardWidth > 400 ? 18 : cardWidth > 300 ? 16 : 14;
        double excerptFont = cardWidth > 400 ? 14 : 12;
        double authorFont = cardWidth > 400 ? 12 : 10;
        double padding = cardWidth > 400 ? 16 : 12;
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ArticleDetailPage(article: article),
              ),
            );
          },
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: buildArticleImage(article.featuredImage, height: imageHeight),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          article.title,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: titleFont,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          article.excerpt,
                          style: GoogleFonts.poppins(
                            fontSize: excerptFont,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'By ${article.author} • ${article.readTime}',
                          style: GoogleFonts.poppins(
                            fontSize: authorFont,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Consumer<AppStateProvider>(
                            builder: (context, appState, _) {
                              final isLiked = appState.isArticleLiked(article.id);
                              return Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      isLiked ? Icons.favorite : Icons.favorite_border,
                                      color: isLiked ? Colors.redAccent : AppColors.textSecondary,
                                      size: 18,
                                    ),
                                    onPressed: () => appState.toggleArticleLike(article.id),
                                    splashRadius: 18,
                                  ),
                                  Text(
                                    article.likes.toString(),
                                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              const Icon(Icons.comment_outlined, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                article.comments.toString(),
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Row(
                            children: [
                              const Icon(Icons.remove_red_eye_outlined, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                article.views.toString(),
                                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Bookmark icon
                      Consumer<AppStateProvider>(
                        builder: (context, appState, _) {
                          final isBookmarked = appState.isBookmarked(article.id);
                          return IconButton(
                            icon: Icon(
                              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                              color: isBookmarked ? AppColors.secondary : Colors.grey,
                            ),
                            onPressed: () => appState.toggleBookmark(article.id),
                            splashRadius: 20,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    final userRole = Provider.of<AppStateProvider>(context).role;
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_rounded),
        label: 'Home',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.bookmark_outline),
        label: 'Saved',
      ),
    ];
    if (userRole != UserRole.reader) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      );
    }
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.secondary,
      unselectedItemColor: AppColors.textSecondary,
      currentIndex: _selectedBottomTab,
      onTap: (index) {
        setState(() {
          _selectedBottomTab = index;
          if (index == 0) {
            _selectedCategory = 'latest';
          }
        });
      },
      items: items,
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => _ArticleSearchDialog(),
    );
  }

  Widget _buildGalleryGrid() {
    // Just display all galleryImages as a grid
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        itemCount: galleryImages.length,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final img = galleryImages[index];
          final heights = [180.0, 240.0, 200.0, 260.0, 220.0];
          final tileHeight = heights[index % heights.length];
          return GestureDetector(
            onTap: () => _showGalleryImageDialog(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: buildArticleImage(img, height: tileHeight),
            ),
          );
        },
      ),
    );
  }

  void _showGalleryImageDialog(int initialIndex) {
    showDialog(
      context: context,
      builder: (context) {
        int currentIndex = initialIndex;
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              alignment: Alignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: InteractiveViewer(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: buildArticleImage(galleryImages[currentIndex], fit: BoxFit.contain),
                    ),
                  ),
                ),
                // Back button
                if (currentIndex > 0)
                  Positioned(
                    left: 8,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, size: 32, color: Colors.white.withOpacity(0.8)),
                      onPressed: () => setState(() => currentIndex--),
                    ),
                  ),
                // Next button
                if (currentIndex < galleryImages.length - 1)
                  Positioned(
                    right: 8,
                    child: IconButton(
                      icon: Icon(Icons.arrow_forward_ios_rounded, size: 32, color: Colors.white.withOpacity(0.8)),
                      onPressed: () => setState(() => currentIndex++),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ArticleSearchDialog extends StatefulWidget {
  const _ArticleSearchDialog();

  @override
  State<_ArticleSearchDialog> createState() => _ArticleSearchDialogState();
}

class _ArticleSearchDialogState extends State<_ArticleSearchDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final results = context.read<ArticleProvider>().articles.where((article) {
      // Exclude deleted articles from search results
      if (article.status == ArticleStatus.deleted) {
        return false;
      }
      
      final q = _query.toLowerCase();
      return article.title.toLowerCase().contains(q) ||
          article.excerpt.toLowerCase().contains(q) ||
          article.author.toLowerCase().contains(q);
    }).toList();
    return AlertDialog(
      title: const Text('Search Articles'),
      content: SizedBox(
        width: 350,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Enter search terms...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 16),
            if (_query.isNotEmpty)
              results.isEmpty
                  ? const Text('No results found.')
                  : SizedBox(
                      height: 250,
                      child: ListView.builder(
                        itemCount: results.length,
                        itemBuilder: (context, index) {
                          final article = results[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: AssetImage(article.featuredImage ?? ''),
                            ),
                            title: Text(article.title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                            subtitle: Text(article.author, style: GoogleFonts.poppins(fontSize: 13)),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ArticleDetailPage(article: article),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

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