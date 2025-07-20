// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import '../models/articles.dart';

class ArticleProvider extends ChangeNotifier {
  List<Article> _articles = [];
  List<Article> _filteredArticles = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  ArticleStatus? _statusFilter;
  String? _categoryFilter;

  ArticleProvider() {
    initialize(); 
  }

  // Getters
  List<Article> get articles => _articles;
  List<Article> get filteredArticles => _filteredArticles;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  ArticleStatus? get statusFilter => _statusFilter;
  String? get categoryFilter => _categoryFilter;

  // Available categories
  static const List<String> categories = [
    'News',
    'Feature',
    'Sports',
    'Academics',
  ];

  // Mock data for development
  void _loadMockData() {
    _articles = [
      // ACADEMICS ARTICLES
      Article(
        id: '1',
        title: 'The NEU\'s UAPSA renders 19 newly passed Architects, draws 59.38% in ALE June \'25',
        content: 'Beyond Engineering — Continuing the architectural legacy of BatStateU The NEU, United Architects of the Philippines Student Auxiliary (UAPSA) sketched 19 newly passed architects outlining 59.38% institutional rating in the June 2025 Architecture Licensure Examination (ALE), results released this evening, June 18. In the two-day board exams held last June 11 and 13, among the 19 new passers, were a joint success for the 8 first takers and 11 repeaters, highlighting 80% and 52.38% of the overall performance, accordingly.',
        excerpt: 'The NEU\'s UAPSA achieves 59.38% institutional rating in June 2025 Architecture Licensure Examination.',
        author: 'Jorge M. Gutierrez',
        categories: ['Academics'],
        featuredImage: 'assets/images/academics1.png',
        status: ArticleStatus.published,
        readTime: 2,
        publishedAt: DateTime.now().subtract(const Duration(days: 28)),
        likes: 120,
        comments: 0,
        views: 1500,
      ),

      // NEWS ARTICLES 
      Article(
        id: '2',
        title: 'The AXIS\' Sports Editor to lead 4A\'s Best Pub as its new Editor-In-Chief',
        content: 'Van Aeros Torres, Sports Editor and incoming 4th-year ME student, will be the next Editor-in-Chief of The AXIS for AY 2025–2026, continuing its legacy as CALABARZON\'s best student publication. Torres successfully secured his new position as the publication\'s fourth EIC after careful evaluations and deliberations from the Technical-Operational Examinations and Interviews during The AXIS\' BOARD EXAMINATIONS (TABE) 2025 from April 21 to May 31, with official results released last June 5 during Durungáwan \'25: The AXIS Strategic Planning and Conference.',
        excerpt: 'Van Aeros Torres appointed as new Editor-in-Chief of The AXIS for AY 2025-2026.',
        author: 'Ian Paul R. Gualberto',
        categories: ['News'],
        featuredImage: 'assets/images/news3.png',
        status: ArticleStatus.published,
        readTime: 3,
        publishedAt: DateTime.now().subtract(const Duration(days: 32)),
        likes: 105,
        comments: 0,
        views: 1300,
      ),

      // NEWS ARTICLES 
      Article(
        id: '3',
        title: 'PUKSAAN WITH A CAUSE',
        content: 'Drag Race PH Season 3 winner Maxie Andreison and finalist Angel Galang brought sparkle and empowerment to the crowd at Sparta Gymnasium on June 4. Beyond the glitter, Maxie raised awareness amid rising HIV cases in the country, urging students to stay informed and protected.',
        excerpt: 'Drag Race PH stars bring awareness to HIV prevention at BatStateU event.',
        author: 'Yanncy D. Chavez',
        categories: ['News'],
        featuredImage: 'assets/images/news4.png',
        status: ArticleStatus.published,
        readTime: 1,
        publishedAt: DateTime.now().subtract(const Duration(days: 41)),
        likes: 115,
        comments: 0,
        views: 1400,
      ),
      Article(
        id: '4',
        title: 'FANATIC EUPHORIA',
        content: 'The Itchyworms lit up the stage with their iconic hits, including a dreamlike surprise where a student strummed along live, on June 4 at Sparta Gymnasium.',
        excerpt: 'The Itchyworms perform live at BatStateU with special student collaboration.',
        author: 'Reighn Fabian, Tracy Lopez',
        categories: ['News'],
        featuredImage: 'assets/images/news5.png',
        status: ArticleStatus.published,
        readTime: 1,
        publishedAt: DateTime.now().subtract(const Duration(days: 41)),
        likes: 125,
        comments: 0,
        views: 1600,
      ),

      // NEWS ARTICLES - 
      Article(
        id: '5',
        title: 'APHRODITE\'S MAGIC',
        content: 'After hours of jamming with live music, butterflies filled the stomachs of the Red Spartan community as songs performed by The Ridleys left the crowd enchanted, at the Sparta Gymnasium, June 4.',
        excerpt: 'The Ridleys enchant BatStateU community with magical live performance.',
        author: 'Yanncy D. Chavez',
        categories: ['News'],
        featuredImage: 'assets/images/news1.png',
        status: ArticleStatus.published,
        readTime: 1,
        publishedAt: DateTime.now().subtract(const Duration(days: 42)),
        likes: 120,
        comments: 0,
        views: 1500,
      ),

      // ACADEMICS ARTICLES 
      Article(
        id: '6',
        title: 'The NEU undergoes steady state in May ChELE',
        content: 'Chemical Engineering alums from the country\'s National Engineering University synthesized 42 new engineers, attaining a 79.25% performance rating seen in the May 2025 Chemical Engineer Licensure Exam (ChELE) results, released today. Among the contributors to the triumph were the 39 first-timers, infusing a remarkable 90.70% performance on the computer-based examination conducted on May 21-23.',
        excerpt: 'BatStateU achieves 79.25% performance rating in May 2025 Chemical Engineer Licensure Exam.',
        author: 'Ingrid Lescano',
        categories: ['Academics'],
        featuredImage: 'assets/images/academics2.png',
        status: ArticleStatus.published,
        readTime: 2,
        publishedAt: DateTime.now().subtract(const Duration(days: 54)),
        likes: 95,
        comments: 0,
        views: 1100,
      ),

      // ACADEMICS ARTICLES 
      Article(
        id: '7',
        title: '17 newly passed Civil Engrs racks 27.42% rating',
        content: 'Attaining a 27.42% institutional rating, the country\'s National Engineering University failed to bend past the 29.21% national passing rate in the April 2025 Civil Engineering Licensure Examination (CELE), results released today, May 6. The Professional Regulation Comission announced a total of 4,940 passers out of 16,913 examinees passed the two-day examination conducted last April 28-29.',
        excerpt: 'BatStateU achieves 27.42% institutional rating in April 2025 Civil Engineering Licensure Exam.',
        author: 'Kurt Justine Silang',
        categories: ['Academics'],
        featuredImage: 'assets/images/academics3.png',
        status: ArticleStatus.published,
        readTime: 1,
        publishedAt: DateTime.now().subtract(const Duration(days: 71)),
        likes: 85,
        comments: 0,
        views: 900,
      ),

      // ACADEMICS ARTICLES 
      Article(
        id: '8',
        title: 'RMELE performance near perfect for BatStateU, generates 18 new RMEs',
        content: '18 out of 20 examinees from the country\'s National Engineering University who took the April 2025 Registered Master Electrician Licensure Examination amped up a collective passing rate of 90%, representing both the Alangilan and Balayan campuses. April 2025\'s RMELE accounted for a 68.37% Nat\'l Passing Rate involving 668 out of 977 newly passed Master Electricians nationwide.',
        excerpt: 'BatStateU achieves 90% passing rate in April 2025 Registered Master Electrician Licensure Exam.',
        author: 'Paul Adrian K. Paraiso',
        categories: ['Academics'],
        featuredImage: 'assets/images/academics4.png',
        status: ArticleStatus.published,
        readTime: 1,
        publishedAt: DateTime.now().subtract(const Duration(days: 77)),
        likes: 90,
        comments: 0,
        views: 950,
      ),
      Article(
        id: '9',
        title: 'BatStateU, The NEU caps April 2025 REELE with 120 newly passed Electrical Engineers',
        content: 'The Philippines\' National Engineering University rolled out a 75.00% showing in the national licensure examination, energizing 120 out of 160 newly passed Electrical Engineers, the biggest number of passers in the last two years. 4,137 out of 6,741 aspiring Electrical Engineers comprised the Nat\'l Passing Rate of 61.37%',
        excerpt: 'BatStateU produces 120 new Electrical Engineers with 75% institutional passing rate.',
        author: 'Paul Adrian K. Paraiso',
        categories: ['Academics'],
        featuredImage: 'assets/images/academics5.png',
        status: ArticleStatus.published,
        readTime: 2,
        publishedAt: DateTime.now().subtract(const Duration(days: 77)),
        likes: 100,
        comments: 0,
        views: 1200,
      ),

      // NEWS ARTICLES 
      Article(
        id: '10',
        title: 'Trilogy of SDGs 13-15 colors AFES\' Paint the Town Movement',
        content: 'AFES\' celebration tackled climate action, life below water, and life on land through plenary talks. Engineering students were inspired to engage in sustainable projects such as tree-planting and clean-up drives.',
        excerpt: 'AFES promotes sustainable development goals through environmental awareness campaign.',
        author: 'Mary Rose Espenilla',
        categories: ['News'],
        featuredImage: 'assets/images/news2.png',
        status: ArticleStatus.published,
        readTime: 3,
        publishedAt: DateTime.now().subtract(const Duration(days: 92)),
        likes: 98,
        comments: 0,
        views: 1100,
      ),

      // SPORTS ARTICLES 
      Article(
        id: '11',
        title: 'SHANKED SHOT | AL\'s Unsteady Start Costs Them Gold',
        content: 'The Alangilan Lady Spikers fell short as Pablo Borbon seized the early momentum and secured victory at the Intramurals volleyball finals. Pablo Borbon pulled off a shocking final sweep against the home favorites from Alangilan, who were plagued by unforced errors. Alangilan\'s middle blocker Abegael Manalo led the team on both ends with 15 points, including four blocks, but her efforts weren\'t enough to secure the crown. Despite the loss, Alangilan Campus was hailed as the overall champions of the University-Wide Intramurals.',
        excerpt: 'Alangilan Lady Spikers fall short in volleyball finals but campus wins overall championship.',
        author: 'Marian Dollano, Mattheaus Immaculata',
        categories: ['Sports'],
        featuredImage: 'assets/images/sports1.png',
        status: ArticleStatus.published,
        readTime: 5,
        publishedAt: DateTime.now().subtract(const Duration(days: 94)),
        likes: 150,
        comments: 0,
        views: 2500,
      ),
      Article(
        id: '12',
        title: 'TOSSING TRAPS | AL Spikers outsmart JPLC-Malvar, capture MVB title',
        content: 'Alangilan Spikers\' strategy and deception sealed a 2-0 win over JPLC-Malvar in the men\'s volleyball championship. Twin-towers Neil Joshua Abutal and Mark Justine Nier snapped the neck-and-neck start of the opening set, aiding in AL\'s hard-earned seven-point edge, 12-5, at the first-half of the set. However, JPLC-Malvar came back stronger in the latter half as they redeemed the tight match through decoys and sneaky drops.',
        excerpt: 'Alangilan Spikers claim men\'s volleyball championship with strategic gameplay.',
        author: 'Marian Faye G. Dollano',
        categories: ['Sports'],
        featuredImage: 'assets/images/sports2.png',
        status: ArticleStatus.published,
        readTime: 2,
        publishedAt: DateTime.now().subtract(const Duration(days: 94)),
        likes: 130,
        comments: 0,
        views: 2000,
      ),
      Article(
        id: '13',
        title: 'LABAN-BAWI | Barcelona umeskapo sa twice-to-beat na bentaha kontra Arellano',
        content: 'Alangilan\'s Shemaiah Barcelona overcame a twice-to-beat disadvantage to clinch the Women\'s Singles A badminton championship against Pablo Borbon. Nagrehistro ng malaking kawang sa palitan ng mga pulidong ratsada si Barcelona sa first match, sapat para pawiin ang kumpiyansa mula sa winning-bracket na ipinoste ni Arellano, 14-8. "The days before the u-wide, unfortunately, so many bad things kept happening, kaya sabi ko sa sarili ko, \'I needed to win\', so that meron akong redemption era," ani Barcelona.',
        excerpt: 'Shemaiah Barcelona overcomes twice-to-beat disadvantage to win badminton championship.',
        author: 'Jodel P. Cruz',
        categories: ['Sports'],
        featuredImage: 'assets/images/sports3.png',
        status: ArticleStatus.published,
        readTime: 5,
        publishedAt: DateTime.now().subtract(const Duration(days: 94)),
        likes: 140,
        comments: 0,
        views: 2200,
      ),
      Article(
        id: '14',
        title: 'Alangilan duos net twin titles in badminton doubles',
        content: 'Alangilan dominated the badminton doubles finals as both men\'s and women\'s teams secured championships after intense matches at Sparta Gymnasium. Atienza-Salagubang duo\'s vie for the gold in the men\'s division set off to a gritty start until half the game, bringing the match into a tie, 15-15. However, Alangilan power smashers did not let the rival Lipa stand a chance on their twice-to-beat standing as they carved up momentous four straight points, 19-15, installing their winning momentum until the final stretch with victory on their hand, 25-18.',
        excerpt: 'Alangilan dominates badminton doubles with both men\'s and women\'s championships.',
        author: 'Mary Rose P. Espenilla',
        categories: ['Sports'],
        featuredImage: 'assets/images/sports4.png',
        status: ArticleStatus.published,
        readTime: 3,
        publishedAt: DateTime.now().subtract(const Duration(days: 94)),
        likes: 120,
        comments: 0,
        views: 1800,
      ),
      Article(
        id: '15',
        title: 'Dribblers go down against Nasugbu',
        content: 'Alangilan Dribblers lost another close match to ARASOF-Nasugbu, 38–35, falling short in the Women\'s Basketball finals. Facing the twice-to-beat disadvantage, Alangilan geared up for another clash with Nasugbu to claim the women\'s crown. With their guns out early by opening tip-off, Alangilan fired away nine quick points right off the bat led by Micah Nicolette Rodelas and Aira Erigbuagas, but Nasugbu answered back with an eight-point run to keep the game at their toes, ending the half at 18 a-piece.',
        excerpt: 'Alangilan Dribblers fall short in women\'s basketball finals against Nasugbu.',
        author: 'Mattheaus Hrodrich G. Immaculata',
        categories: ['Sports'],
        featuredImage: 'assets/images/sports5.png',
        status: ArticleStatus.published,
        readTime: 2,
        publishedAt: DateTime.now().subtract(const Duration(days: 94)),
        likes: 160,
        comments: 0,
        views: 2400,
      ),

      // FEATURE ARTICLES 
      Article(
      id: '3006',
      title: 'GREATEST COME BACK!',
      content: 'Indeed, manifestation works. After its triumphant debut on the Luzon stage last year in Naga City, The AXIS Group of Publications, the Official Student Publication of Batangas State University, The National Engineering University Alangilan Campus, came back stronger and proved its persisting oath to journalistic excellence, securing multiple victories in the Individual Categories and topping its first recognitions in the Group entries during the 20th Luzon-wide Higher Education Press Conference (LHEPC), held at Batis Aramin Hotel and Resort, Lucban Quezon, April 2–4. In the three-day Luzon-wide journalism confab, qualifiers from the publication represented Region IV-A CALABARZON, vying amongst over 1000 delegates from 151 colleges and universities, spanning over six regions in Luzon and a special case for a delegation from Visayas’ Region 7. Meanwhile, Region IV-A CALABARZON was hailed as the Overall Best Performing Region during the conference, accumulating a total of 957 points — 643 for group and 314 for individual categories.',
      excerpt: 'Indeed, manifestation works. After its triumphant debut on the Luzon stage last year in Naga City, The AXIS Group of Publications, the Official Student Publication of Batangas State University, The National Engineering University Alangilan Campus, came back stronger and proved its persisting oath to journalistic excellence, securing multiple victories in the Individual Categories and topping its first recognitions in the Group entries during the 20th Luzon-wide Higher Education Press Conference (LHEPC), held at Batis Aramin Hotel and Resort, Lucban Quezon, April 2–4.',
      author: 'Ian Paul R. Gualberto',
      categories: ['Feature'],
      featuredImage: 'assets/images/featured1.png',
      status: ArticleStatus.published,
      readTime: 3,
      publishedAt: DateTime(2025, 4, 5),
      likes: 130,
      comments: 0,
      views: 1500,
    ),
    Article(
      id: '3007',
      title: 'AND NOW, BEST IN CALABARZON!',
      content: 'Fever dream— in only its second outing, The AXIS Group of Publications, the Official Student Publication of Batangas State University, The National Engineering University Alangilan Campus, attested its triumphant ode to journalism excellence in the A.Y. 2024–2025 Regional Higher Education Press Conference (RHEPC), hailed as the Top Performing Campus Publication, besting more than 30 campus press groups with almost 550 participants across CALABARZON, held at Batis Aramin Hotel and Resort, Lucban Quezon, February 18–20. In the three-day regional journalism confab, the publication, backed by a 34-member delegation, amassed 59 awards across both Group and Individual Categories. Winners from The AXIS have secured spots in the Luzon-wide Higher Education Press Conference (LHEPC), set to be hosted by Region IV-A on April 2–4, 2025.',
      excerpt: 'Fever dream— in only its second outing, The AXIS Group of Publications, the Official Student Publication of Batangas State University, The National Engineering University Alangilan Campus, attested its triumphant ode to journalism excellence in the A.Y. 2024–2025 Regional Higher Education Press Conference (RHEPC), hailed as the Top Performing Campus Publication, besting more than 30 campus press groups with almost 550 participants across CALABARZON, held at Batis Aramin Hotel and Resort, Lucban Quezon, February 18–20.',
      author: 'Ian Paul R. Gualberto',
      categories: ['Feature'],
      featuredImage: 'assets/images/featured2.png',
      status: ArticleStatus.published,
      readTime: 4,
      publishedAt: DateTime(2024, 2, 21),
      likes: 140,
      comments: 0,
      views: 1600,
    ),
    Article(
      id: '3008',
      title: 'NOW ON THE NATIONAL SCENE!',
      content: 'The AXIS gains foothold in National Tertiary Press, feted in awards nationwide. Six days from celebrating the publication’s 2nd Founding Anniversary, The AXIS, the Official Student Publication of Batangas State University, The National Engineering University Alangilan Campus, attested its mettle in its debut at the School Press Advisers\' Movement, Inc. (SPAM, Inc.)\'s 15th National Campus Media Conference (NCMC), Angels\' Hills Tagaytay Retreat and Formation Center from September 18–20, 2024, besting 877 participants and 67 campus publications nationwide and housing the Philippines’ 7th Best Newspaper. Together with this achievement, The AXIS also earned individual merits, solidifying their places among the echelons of national campus press.',
      excerpt: 'The AXIS gains foothold in National Tertiary Press, feted in awards nationwide. Six days from celebrating the publication’s 2nd Founding Anniversary, The AXIS, the Official Student Publication of Batangas State University, The National Engineering University Alangilan Campus, attested its mettle in its debut at the School Press Advisers\' Movement, Inc. (SPAM, Inc.)\'s 15th National Campus Media Conference (NCMC), Angels\' Hills Tagaytay Retreat and Formation Center from September 18–20, 2024, besting 877 participants and 67 campus publications nationwide and housing the Philippines’ 7th Best Newspaper.',
      author: 'Ian Paul R. Gualberto',
      categories: ['Feature'],
      featuredImage: 'assets/images/featured3.png',
      status: ArticleStatus.published,
      readTime: 2,
      publishedAt: DateTime(2024, 9, 20),
      likes: 150,
      comments: 0,
      views: 1800,
    ),

      // DRAFT ARTICLES for testing
      Article(
        id: '4001',
        title: 'Campus Life: A Day in the Life of a BatStateU Student',
        content: 'This is a draft article about campus life that will be completed later.',
        excerpt: 'A glimpse into the daily routine of students at BatStateU.',
        author: 'Student Reporter',
        categories: ['News'],
        featuredImage: 'assets/images/news1.png',
        status: ArticleStatus.draft,
        readTime: 3,
        likes: 0,
        comments: 0,
        views: 0,
      ),
      Article(
        id: '4002',
        title: 'Upcoming Events: What\'s Happening This Month',
        content: 'This article will list all the upcoming events on campus.',
        excerpt: 'Stay updated with all the exciting events happening this month.',
        author: 'Events Team',
        categories: ['News'],
        featuredImage: 'assets/images/news2.png',
        status: ArticleStatus.draft,
        readTime: 2,
        likes: 0,
        comments: 0,
        views: 0,
      ),
    ];
    _filteredArticles = _articles;
  }

  // Initialize provider
  Future<void> initialize() async {
    _setLoading(true);
    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 800));
      _loadMockData();
      _error = null;
    } catch (e) {
      _error = 'Failed to load articles: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // CRUD Operations
  Future<void> createArticle(Article article) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      _articles.add(article);
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Failed to create article: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateArticle(Article article) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 500));
      final index = _articles.indexWhere((a) => a.id == article.id);
      if (index != -1) {
        _articles[index] = article.copyWith(updatedAt: DateTime.now());
        _applyFilters();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to update article: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteArticle(String id) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _articles.indexWhere((article) => article.id == id);
      if (index != -1) {
        // Soft delete - change status to deleted instead of removing
        _articles[index] = _articles[index].copyWith(
          status: ArticleStatus.deleted,
          updatedAt: DateTime.now(),
        );
        _applyFilters();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to delete article: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Restore a deleted article
  Future<void> restoreArticle(String id) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      final index = _articles.indexWhere((article) => article.id == id);
      if (index != -1) {
        _articles[index] = _articles[index].copyWith(
          status: ArticleStatus.draft,
          updatedAt: DateTime.now(),
        );
        _applyFilters();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to restore article: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Permanently delete an article (for items already in trash)
  Future<void> permanentlyDeleteArticle(String id) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      _articles.removeWhere((article) => article.id == id);
      _applyFilters();
      _error = null;
    } catch (e) {
      _error = 'Failed to permanently delete article: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Get deleted articles
  List<Article> getDeletedArticles() {
    return _articles.where((article) => article.status == ArticleStatus.deleted).toList();
  }

  // Get non-deleted articles (for normal display)
  List<Article> getActiveArticles() {
    return _articles.where((article) => article.status != ArticleStatus.deleted).toList();
  }

  Future<void> publishArticle(String id) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 400));
      final index = _articles.indexWhere((a) => a.id == id);
      if (index != -1) {
        _articles[index] = _articles[index].copyWith(
          status: ArticleStatus.published,
          publishedAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        _applyFilters();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to publish article: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> archiveArticle(String id) async {
    _setLoading(true);
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 400));
      final index = _articles.indexWhere((a) => a.id == id);
      if (index != -1) {
        _articles[index] = _articles[index].copyWith(
          status: ArticleStatus.archived,
          updatedAt: DateTime.now(),
        );
        _applyFilters();
      }
      _error = null;
    } catch (e) {
      _error = 'Failed to archive article: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Search and Filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void setStatusFilter(ArticleStatus? status) {
    _statusFilter = status;
    _applyFilters();
  }

  void setCategoryFilter(String? category) {
    _categoryFilter = category;
    _applyFilters();
  }

  void clearFilters() {
    _searchQuery = '';
    _statusFilter = null;
    _categoryFilter = null;
    _applyFilters();
  }

  void _applyFilters() {
    _filteredArticles = _articles.where((article) {
      // Exclude deleted articles by default (unless specifically filtered for deleted)
      if (_statusFilter != ArticleStatus.deleted && article.status == ArticleStatus.deleted) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesSearch = article.title.toLowerCase().contains(query) ||
            article.content.toLowerCase().contains(query) ||
            article.author.toLowerCase().contains(query);
        if (!matchesSearch) return false;
      }

      // Status filter
      if (_statusFilter != null && article.status != _statusFilter) {
        return false;
      }

      // Category filter
      if (_categoryFilter != null && !article.categories.contains(_categoryFilter)) {
        return false;
      }

      return true;
    }).toList();

    // Sort by published date (newest first)
    _filteredArticles.sort((a, b) => (b.publishedAt ?? DateTime(1970)).compareTo(a.publishedAt ?? DateTime(1970)));
    
    notifyListeners();
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

  // Get article by ID
  Article? getArticleById(String id) {
    try {
      return _articles.firstWhere((article) => article.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get articles by status
  List<Article> getArticlesByStatus(ArticleStatus status) {
    return _articles.where((article) => article.status == status).toList();
  }

  // Get articles by category
  List<Article> getArticlesByCategory(String category) {
    return _articles.where((article) => article.categories.contains(category)).toList();
  }

  // Add like and comment logic for real-time updates
  final Set<String> _likedArticleIds = {};

  bool isArticleLiked(String articleId) => _likedArticleIds.contains(articleId);

  void toggleLike(String articleId) {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index == -1) return;
    if (_likedArticleIds.contains(articleId)) {
      // Unlike
      _likedArticleIds.remove(articleId);
      if (_articles[index].likes > 0) _articles[index].likes -= 1;
    } else {
      // Like
      _likedArticleIds.add(articleId);
      _articles[index].likes += 1;
    }
    notifyListeners();
  }

  void incrementComments(String articleId) {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index == -1) return;
    _articles[index].comments += 1;
    notifyListeners();
  }

  void incrementViews(String articleId) {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index == -1) return;
    _articles[index].views += 1;
    notifyListeners();
  }

  // Enhanced connection methods for admin-reader synchronization
  void notifyArticleAdded(Article article) {
    // Add the article to the list
    _articles.add(article);
    _applyFilters();
    notifyListeners();
    
    // Log the action for debugging
    print('Article added: ${article.title} (ID: ${article.id})');
  }

  void notifyArticleUpdated(Article article) {
    final index = _articles.indexWhere((a) => a.id == article.id);
    if (index != -1) {
      _articles[index] = article;
      _applyFilters();
      notifyListeners();
      
      // Log the action for debugging
      print('Article updated: ${article.title} (ID: ${article.id})');
    }
  }

  void notifyArticleDeleted(String articleId) {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      final deletedArticle = _articles[index];
      _articles.removeAt(index);
      _applyFilters();
      notifyListeners();
      
      // Log the action for debugging
      print('Article deleted: ${deletedArticle.title} (ID: $articleId)');
    }
  }

  void notifyArticlePublished(String articleId) {
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(
        status: ArticleStatus.published,
        publishedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      _applyFilters();
      notifyListeners();
      
      // Log the action for debugging
      print('Article published: ${_articles[index].title} (ID: $articleId)');
    }
  }

  // Get real-time article count for different statuses
  int getPublishedArticleCount() {
    return _articles.where((article) => article.status == ArticleStatus.published).length;
  }

  int getDraftArticleCount() {
    return _articles.where((article) => article.status == ArticleStatus.draft).length;
  }

  int getDeletedArticleCount() {
    return _articles.where((article) => article.status == ArticleStatus.deleted).length;
  }

  // Get latest published articles for reader view
  List<Article> getLatestPublishedArticles({int limit = 10}) {
    final published = _articles.where((article) => article.status == ArticleStatus.published).toList();
    published.sort((a, b) => (b.publishedAt ?? DateTime(1970)).compareTo(a.publishedAt ?? DateTime(1970)));
    return published.take(limit).toList();
  }

  // Get popular articles based on views
  List<Article> getPopularArticles({int limit = 5}) {
    final published = _articles.where((article) => article.status == ArticleStatus.published).toList();
    published.sort((a, b) => b.views.compareTo(a.views));
    return published.take(limit).toList();
  }
} 