import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 900;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'About Us',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  child: Column(
                    children: [
                      _buildAppInfoCard(isSmallScreen, isMediumScreen),
                      SizedBox(height: isSmallScreen ? 20 : 24),
                      _buildDevelopmentTeamCard(isSmallScreen, isMediumScreen),
                      SizedBox(height: isSmallScreen ? 20 : 24),
                      _buildContactCard(isSmallScreen, isMediumScreen),
                      SizedBox(height: isSmallScreen ? 20 : 24),
                      // Copyright and version info under Contact & Support
                      Column(
                        children: [
                          Text(
                            '© 2025 The AXIS Group of Publication',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 10 : 12,
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 2 : 4),
                          Text(
                            'Made with love for BatStateU Alangilan Students',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 12 : 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 2 : 4),
                          Text(
                            'Version 1.0.0',
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 10 : 12,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
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
      ),
    );
  }

  Widget _buildAppInfoCard(bool isSmallScreen, bool isMediumScreen) {
    final logoSize = isSmallScreen ? 60.0 : (isMediumScreen ? 70.0 : 80.0);
    final titleSize = isSmallScreen ? 24.0 : (isMediumScreen ? 28.0 : 30.0);
    final subtitleSize = isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);
    final descriptionSize = isSmallScreen ? 14.0 : (isMediumScreen ? 15.0 : 16.0);
    final padding = isSmallScreen ? 20.0 : (isMediumScreen ? 24.0 : 28.0);
    
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/the_axis_logo.png',
                  width: logoSize,
                  height: logoSize,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Text(
              'DunongLaya',
              style: GoogleFonts.playfairDisplay(
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                letterSpacing: 1.2,
              ),
            ),
            SizedBox(height: isSmallScreen ? 6 : 8),
            Text(
              'The AXIS - Student Publication Platform',
              style: GoogleFonts.poppins(
                fontSize: subtitleSize,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Container(
              height: 3,
              width: isSmallScreen ? 50 : 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Text(
              'The official student publication platform of The AXIS, Batangas State University—committed to delivering timely news, sharing inspiring stories, and championing the voices of the student community.',
              style: GoogleFonts.poppins(
                fontSize: descriptionSize,
                color: AppColors.textSecondary,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevelopmentTeamCard(bool isSmallScreen, bool isMediumScreen) {
    final developers = [
      {
        'name': 'Carl Bradford M. De Sagun',
        'role': 'IT-BA-3305',
        'image': 'assets/images/carl.png', 
      },
      {
        'name': 'Gio Kervin P. Lucero',
        'role': 'IT-BA-3305',
        'image': 'assets/images/gio.png', 
      },
      {
        'name': 'Maria Lourdes M. Magnaye',
        'role': 'IT-BA-3305',
        'image': 'assets/images/ml.png',
      },
    ];

    final titleSize = isSmallScreen ? 18.0 : (isMediumScreen ? 19.0 : 20.0);
    final padding = isSmallScreen ? 20.0 : (isMediumScreen ? 22.0 : 24.0);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.code, 
                  color: AppColors.primary, 
                  size: isSmallScreen ? 20 : 24
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Text(
                  'Development Team',
                  style: GoogleFonts.poppins(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            // 3 rows, one per developer
            Column(
              children: developers.map((developer) => _buildDeveloperCard(developer, isSmallScreen, isMediumScreen)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeveloperCard(Map<String, String> developer, bool isSmallScreen, bool isMediumScreen) {
    final avatarRadius = isSmallScreen ? 32.0 : (isMediumScreen ? 38.0 : 44.0);
    final nameSize = isSmallScreen ? 16.0 : (isMediumScreen ? 17.0 : 18.0);
    final roleSize = isSmallScreen ? 13.0 : (isMediumScreen ? 14.0 : 15.0);
    final padding = isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
    final margin = isSmallScreen ? 12.0 : (isMediumScreen ? 14.0 : 16.0);
    final spacing = isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);

    return Container(
      margin: EdgeInsets.only(bottom: margin),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: ClipOval(
              child: Image.asset(
                developer['image']!,
                width: avatarRadius * 2,
                height: avatarRadius * 2,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.person,
                    size: avatarRadius,
                    color: AppColors.primary,
                  );
                },
              ),
            ),
          ),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  developer['name']!,
                  style: GoogleFonts.poppins(
                    fontSize: nameSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Text(
                  developer['role']!,
                  style: GoogleFonts.poppins(
                    fontSize: roleSize,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(bool isSmallScreen, bool isMediumScreen) {
    final titleSize = isSmallScreen ? 18.0 : (isMediumScreen ? 19.0 : 20.0);
    final padding = isSmallScreen ? 20.0 : (isMediumScreen ? 22.0 : 24.0);
    final descriptionSize = isSmallScreen ? 13.0 : (isMediumScreen ? 13.5 : 14.0);

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: AppColors.surface,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.contact_support_outlined, 
                  color: AppColors.primary, 
                  size: isSmallScreen ? 20 : 24
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Text(
                  'Contact & Support',
                  style: GoogleFonts.poppins(
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            _buildContactItem(Icons.email_outlined, 'theaxispub.alangilan@g.batstate-u.edu.ph', isSmallScreen, isMediumScreen),
            _buildContactItem(Icons.web_outlined, 'www.theaxis-batsu.org', isSmallScreen, isMediumScreen),
            _buildContactItem(Icons.location_on_outlined, 'Batangas State University Alangilan, Batangas City', isSmallScreen, isMediumScreen),
            SizedBox(height: isSmallScreen ? 12 : 16),
            Text(
              'For suggestions, bug reports, or general inquiries, please don\'t hesitate to contact us. We value your feedback!',
              style: GoogleFonts.poppins(
                fontSize: descriptionSize,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text, bool isSmallScreen, bool isMediumScreen) {
    final iconSize = isSmallScreen ? 18.0 : (isMediumScreen ? 19.0 : 20.0);
    final textSize = isSmallScreen ? 12.0 : (isMediumScreen ? 13.0 : 14.0);
    final spacing = isSmallScreen ? 8.0 : (isMediumScreen ? 10.0 : 12.0);
    final padding = isSmallScreen ? 8.0 : (isMediumScreen ? 10.0 : 12.0);

    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondary, size: iconSize),
          SizedBox(width: spacing),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: textSize,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}