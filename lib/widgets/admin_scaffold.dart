import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../screens/profile/profile_page.dart';

class AdminScaffold extends StatefulWidget {
  final Widget child;
  final List<String> breadcrumbs;
  final int selectedIndex;
  final void Function(int) onDestinationSelected;
  final Widget? floatingActionButton;
  final String? userName;
  final String? userEmail;
  final VoidCallback? onLogout;
  final bool isLoading;
  final UserRole? userRole;

  const AdminScaffold({
    Key? key,
    required this.child,
    required this.breadcrumbs,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.floatingActionButton,
    this.userName,
    this.userEmail,
    this.onLogout,
    this.isLoading = false,
    this.userRole,
  }) : super(key: key);

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  bool _sidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    final isMobile = MediaQuery.of(context).size.width < 900;
    if (!isDesktop && !_sidebarCollapsed) {
      _sidebarCollapsed = true;
    }
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: isDesktop ? null : _buildDrawer(context),
      body: Row(
        children: [
          if (isDesktop) _buildSidebar(context),
          Expanded(
            child: Column(
              children: [
                if (widget.isLoading)
                  const LinearProgressIndicator(
                    minHeight: 3,
                    color: AppColors.primary,
                    backgroundColor: Color(0x11000000),
                  ),
                _ModernHeader(
                  breadcrumbs: widget.breadcrumbs,
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                  onLogout: widget.onLogout,
                  onMenuPressed: !isDesktop ? () => _scaffoldKey.currentState?.openDrawer() : null,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(0),
                    child: widget.child,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: isMobile ? _buildResponsiveBottomNav() : null,
      floatingActionButton: widget.floatingActionButton,
    );
  }

  Widget _buildSidebar(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Container(
      width: isMobile
          ? MediaQuery.of(context).size.width.clamp(220, 350)
          : 260,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: isMobile ? null : const BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 24,
            offset: const Offset(2, 0),
          ),
        ],
        border: Border(
          right: BorderSide(color: Colors.black.withOpacity(0.08), width: 1),
        ),
        // Glassmorphism effect
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: Column(
        children: [
          // Main content scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gradient header section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color.fromRGBO(31, 58, 52, 1), Color(0xFFE4B646)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/images/the_axis_logo.png',
                            height: 48,
                            width: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Make text flexible to avoid overflow
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DunongLaya',
                                style: GoogleFonts.playfairDisplay(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'The Student Publication Platform for The AXIS',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.white.withOpacity(0.85),
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Navigation items (modern look)
                  _SidebarItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    selected: widget.selectedIndex == 0,
                    collapsed: false,
                    onTap: () => widget.onDestinationSelected(0),
                  ),
                  _SidebarItem(
                    icon: Icons.article_rounded,
                    label: 'Article Management',
                    selected: widget.selectedIndex == 1,
                    collapsed: false,
                    onTap: () => widget.onDestinationSelected(1),
                  ),
                  // User Management - Only for Admin users
                  if (widget.userRole == UserRole.admin)
                    _SidebarItem(
                      icon: Icons.people_rounded,
                      label: 'User Management',
                      selected: widget.selectedIndex == 2,
                      collapsed: false,
                      onTap: () => widget.onDestinationSelected(2),
                    ),
                  _SidebarItem(
                    icon: Icons.analytics_rounded,
                    label: 'Analytics',
                    selected: widget.selectedIndex == (widget.userRole == UserRole.admin ? 3 : 2),
                    collapsed: false,
                    onTap: () => widget.onDestinationSelected(widget.userRole == UserRole.admin ? 3 : 2),
                  ),
                ],
              ),
            ),
          ),
          // Logout button fixed at the bottom
          if (widget.onLogout != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: ElevatedButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: Text('Logout', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: _buildSidebar(context),
    );
  }

  Widget _buildResponsiveBottomNav() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Calculate responsive icon size based on screen dimensions
    double iconSize;
    double fontSize;
    double navHeight;
    
    if (screenWidth < 400) {
      // Small phones
      iconSize = 20.0;
      fontSize = 10.0;
      navHeight = 60.0;
    } else if (screenWidth < 600) {
      // Medium phones
      iconSize = 22.0;
      fontSize = 11.0;
      navHeight = 65.0;
    } else {
      // Large phones/tablets
      iconSize = 24.0;
      fontSize = 12.0;
      navHeight = 70.0;
    }
    
    // Adjust for very tall screens
    if (screenHeight > 800) {
      navHeight += 5.0;
    }

    return Container(
      height: navHeight,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: widget.selectedIndex,
        onTap: widget.onDestinationSelected,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedFontSize: fontSize,
        unselectedFontSize: fontSize,
        iconSize: iconSize,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded, size: iconSize),
            activeIcon: Icon(Icons.dashboard_rounded, size: iconSize),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.article_rounded, size: iconSize),
            activeIcon: Icon(Icons.article_rounded, size: iconSize),
            label: 'Articles',
          ),
          // User Management - Only for Admin users
          if (widget.userRole == UserRole.admin)
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded, size: iconSize),
              activeIcon: Icon(Icons.people_rounded, size: iconSize),
              label: 'Users',
            ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded, size: iconSize),
            activeIcon: Icon(Icons.analytics_rounded, size: iconSize),
            label: 'Analytics',
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool collapsed;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.collapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary.withOpacity(0.12) : Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: collapsed ? 0 : 20, vertical: 12),
          child: Row(
            mainAxisAlignment: collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
            children: [
              Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 24),
              if (!collapsed) ...[
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
                      color: selected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Modern sticky header with title, breadcrumbs, search, notifications, and user menu
class _ModernHeader extends StatelessWidget {
  final List<String> breadcrumbs;
  final String? userName;
  final String? userEmail;
  final VoidCallback? onLogout;
  final VoidCallback? onMenuPressed;
  const _ModernHeader({
    required this.breadcrumbs,
    this.userName,
    this.userEmail,
    this.onLogout,
    this.onMenuPressed,
  });
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;
    final String pageTitle = breadcrumbs.isNotEmpty ? breadcrumbs.last : '';
    final bool showBreadcrumbs = breadcrumbs.length > 1 && !isMobile;
    return Container(
      height: isMobile ? 56 : 72,
      margin: EdgeInsets.only(top: isMobile ? 8 : 12, left: 12, right: 12),
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 32),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(isMobile ? 12 : 18),
        boxShadow: [
          BoxShadow(color: Colors.black12.withOpacity(0.10), blurRadius: 16, offset: Offset(0, 4)),
        ],
        backgroundBlendMode: BlendMode.overlay,
      ),
      child: Row(
        children: [
          if (isMobile && onMenuPressed != null)
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.primary),
              onPressed: onMenuPressed,
              tooltip: 'Menu',
            ),
          if (!isMobile)
            SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pageTitle,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 18 : 22,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (showBreadcrumbs)
                  Row(children: _buildBreadcrumbs()),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Material(
                color: Colors.transparent,
                child: IconButton(
                  icon: Icon(Icons.notifications_none_rounded, color: AppColors.primary, size: isMobile ? 22 : 26),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: Text('Notifications', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: AppColors.primary)),
                        content: Text('No new notifications.', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text('OK', style: GoogleFonts.poppins(color: AppColors.primary)),
                          ),
                        ],
                      ),
                    );
                  },
                  tooltip: 'Notifications',
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    );
                  },
                  child: CircleAvatar(
                    radius: isMobile ? 16 : 20,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Icon(Icons.person, color: AppColors.primary, size: isMobile ? 20 : 24),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  List<Widget> _buildBreadcrumbs() {
    final List<Widget> crumbs = [];
    for (int i = 0; i < breadcrumbs.length; i++) {
      crumbs.add(
        Text(
          breadcrumbs[i],
          style: GoogleFonts.poppins(
            fontWeight: i == breadcrumbs.length - 1 ? FontWeight.bold : FontWeight.w500,
            fontSize: 15,
            color: i == breadcrumbs.length - 1 ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      );
      if (i < breadcrumbs.length - 1) {
        crumbs.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.textSecondary),
        ));
      }
    }
    return crumbs;
  }
}


class ProfileInfoDialog extends StatelessWidget {
  const ProfileInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final userName = appState.currentUserName ?? 'Unknown';
    final userEmail = appState.currentUserEmail ?? '';
    final userRole = appState.currentUserRole == null
        ? 'Unknown'
        : appState.currentUserRole == UserRole.admin
            ? 'Admin'
            : appState.currentUserRole == UserRole.staff
                ? 'Staff Writer'
                : 'Reader';
    // You can add more fields as needed
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.10), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Back',
                  ),
                  const SizedBox(width: 8),
                  Text('Profile Info', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                ],
              ),
              const SizedBox(height: 16),
              // Profile avatar with circular border and shadow
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 35,
                  backgroundColor: AppColors.primary.withOpacity(0.13),
                  child: Icon(Icons.person, size: 38, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 14),
              Text(userName, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(userEmail, style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_rounded, size: 16, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(userRole, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.w600)),
                ],
              ),
              // ... keep the rest of the dialog as is, or remove stats if not available ...
            ],
          ),
        ),
      ),
    );
  }
}
