import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';
import '../../theme/app_colors.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _selectedLanguage = 'English';
  bool _twoFactorEnabled = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Helper method to get role display text
  String _getRoleDisplayText(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.staff:
        return 'Staff';
      case UserRole.reader:
        return 'Reader';
      default:
        return 'User';
    }
  }

  // Helper method to get role icon
  IconData _getRoleIcon(UserRole? role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.staff:
        return Icons.work_rounded;
      case UserRole.reader:
        return Icons.person_rounded;
      default:
        return Icons.person_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final userName = appState.userName ?? 'Unknown';
    final userRole = _getRoleDisplayText(appState.userRole);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth < 600;
    final isSmallScreen = screenHeight < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Modern Gradient App Bar with Flexible Height
            SliverAppBar(
              expandedHeight: isSmallScreen 
                  ? (isMobile ? 180 : 200)
                  : (isMobile ? 240 : 280),
              floating: false,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1F3A34),
                        Color(0xFFE4B646),
                        Color(0xFF2D5A4F),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Background pattern
                      Positioned(
                        top: -60,
                        right: -60,
                        child: Container(
                          width: 240,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -40,
                        left: -40,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                      // Profile content with flexible layout
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final availableHeight = constraints.maxHeight;
                          final isCompact = availableHeight < 200;
                          
                          return Padding(
                            padding: EdgeInsets.fromLTRB(
                              24, 
                              isCompact ? 40 : (isMobile ? 60 : 80), 
                              24, 
                              isCompact ? 16 : 24
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Profile Avatar with Status
                                Stack(
                                  children: [
                                    Container(
                                      width: isCompact 
                                          ? (isMobile ? 60 : 70)
                                          : (isMobile ? 80 : 100),
                                      height: isCompact 
                                          ? (isMobile ? 60 : 70)
                                          : (isMobile ? 80 : 100),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 4),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.25),
                                            blurRadius: 24,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: isCompact 
                                            ? (isMobile ? 26 : 31)
                                            : (isMobile ? 36 : 46),
                                        backgroundColor: Colors.white.withOpacity(0.15),
                                        child: Icon(
                                          Icons.person,
                                          size: isCompact 
                                              ? (isMobile ? 30 : 35)
                                              : (isMobile ? 40 : 50),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    // Online status indicator
                                    Positioned(
                                      bottom: isCompact ? 4 : (isMobile ? 6 : 8),
                                      right: isCompact ? 4 : (isMobile ? 6 : 8),
                                      child: Container(
                                        width: isCompact ? 16 : (isMobile ? 20 : 24),
                                        height: isCompact ? 16 : (isMobile ? 20 : 24),
                                        decoration: BoxDecoration(
                                          color: Colors.green,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 3),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.green.withOpacity(0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.fiber_manual_record,
                                          color: Colors.white,
                                          size: 8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isCompact ? 8 : (isMobile ? 12 : 16)),
                                // User Name with flexible text handling
                                Flexible(
                                  child: Center(
                                    child: Text(
                                      userName,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.bold,
                                        fontSize: isCompact 
                                            ? (isMobile ? 16 : 18)
                                            : (isMobile ? 20 : 24),
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: isCompact ? 1 : 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(height: isCompact ? 4 : 6),
                                                                // User Role with icon and text only
                                Flexible(
                                  child: Center(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _getRoleIcon(appState.userRole),
                                          color: Colors.white,
                                          size: isCompact ? 14 : 16,
                                        ),
                                        SizedBox(width: isCompact ? 8 : 10),
                                        Text(
                                          userRole,
                                          style: GoogleFonts.poppins(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: isCompact 
                                                ? (isMobile ? 11 : 12)
                                                : (isMobile ? 13 : 15),
                                          ),
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Content with improved overflow handling
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 16 : 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Account Settings
                      _buildSectionCard(
                        title: 'Account Settings',
                        icon: Icons.account_circle_rounded,
                        children: [
                          _buildActionTile(
                            icon: Icons.edit_rounded,
                            title: 'Edit Profile',
                            subtitle: 'Update your personal information',
                            onTap: () => _showEditProfileDialog(context),
                          ),
                          _buildActionTile(
                            icon: Icons.photo_camera_rounded,
                            title: 'Change Photo',
                            subtitle: 'Upload a new profile picture',
                            onTap: () => _showPhotoUploadDialog(context),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                      
                      // App Settings
                      _buildSectionCard(
                        title: 'App Settings',
                        icon: Icons.settings_rounded,
                        children: [
                          _buildSwitchTile(
                            icon: Icons.notifications_rounded,
                            title: 'Push Notifications',
                            subtitle: 'Receive updates and alerts',
                            value: _notificationsEnabled,
                            onChanged: (value) => setState(() => _notificationsEnabled = value),
                            color: Colors.purple,
                          ),
                          _buildSwitchTile(
                            icon: Icons.dark_mode_rounded,
                            title: 'Dark Mode',
                            subtitle: 'Switch to dark theme',
                            value: _darkModeEnabled,
                            onChanged: (value) => setState(() => _darkModeEnabled = value),
                            color: Colors.indigo,
                          ),
                          _buildDropdownTile(
                            icon: Icons.language_rounded,
                            title: 'Language',
                            subtitle: 'Choose your preferred language',
                            value: _selectedLanguage,
                            options: ['English', 'Filipino', 'Spanish'],
                            onChanged: (value) => setState(() => _selectedLanguage = value!),
                            color: Colors.teal,
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 16 : 20),
                      
                      // Security & Privacy
                      _buildSectionCard(
                        title: 'Security & Privacy',
                        icon: Icons.security_rounded,
                        children: [
                          _buildActionTile(
                            icon: Icons.lock_rounded,
                            title: 'Change Password',
                            subtitle: 'Update your account password',
                            onTap: () => _showChangePasswordDialog(context),
                          ),
                          _buildSwitchTile(
                            icon: Icons.verified_user_rounded,
                            title: 'Two-Factor Authentication',
                            subtitle: 'Add an extra layer of security',
                            value: _twoFactorEnabled,
                            onChanged: (value) => setState(() => _twoFactorEnabled = value),
                            color: Colors.red,
                          ),
                          _buildActionTile(
                            icon: Icons.privacy_tip_rounded,
                            title: 'Privacy Settings',
                            subtitle: 'Manage your privacy preferences',
                            onTap: () => _showPrivacySettingsDialog(context),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 32 : 40),
                      
                      // Sign Out Button with flexible positioning
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(
                          bottom: isSmallScreen ? 16 : 20,
                          top: isSmallScreen ? 16 : 0,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _showSignOutDialog(context),
                          icon: const Icon(Icons.logout_rounded, color: Colors.white),
                          label: Text(
                            'Log Out',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: isMobile ? 14 : 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              vertical: isMobile ? 16 : 18,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                          ),
                        ),
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Icon(icon, color: AppColors.primary, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 16 : 18,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
                const SizedBox(height: 18),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
    bool isDestructive = false,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 16),
            child: Row(
                children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (color ?? AppColors.primary).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (color ?? AppColors.primary).withOpacity(0.2)),
                  ),
                  child: Icon(
                    icon,
                    color: isDestructive ? Colors.red : (color ?? AppColors.primary),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 13 : 14,
                          color: isDestructive ? Colors.red : AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: isMobile ? 12 : 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                  size: 22,
                  ),
                ],
              ),
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 13 : 14,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 12 : 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
            activeTrackColor: color.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
    required Color color,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(isMobile ? 14 : 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 13 : 14,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: isMobile ? 12 : 13,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: value,
            onChanged: onChanged,
            underline: Container(),
            icon: Icon(Icons.arrow_drop_down, color: color, size: 24),
            items: options.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: GoogleFonts.poppins(fontSize: isMobile ? 13 : 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Dialog methods
  void _showEditProfileDialog(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context, listen: false);
    final currentName = appState.userName ?? '';
    final currentEmail = appState.userEmail ?? '';
    
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.edit_rounded, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                Text('Edit Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              ],
            ),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        if (value.trim().length > 50) {
                          return 'Name must be less than 50 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email address',
                        prefixIcon: Icon(Icons.email, color: AppColors.primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: AppColors.primary, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        
                        final trimmedValue = value.trim();
                        
                        // Check minimum length
                        if (trimmedValue.length < 5) {
                          return 'Email must be at least 5 characters';
                        }
                        
                        // Check maximum length
                        if (trimmedValue.length > 254) {
                          return 'Email must be less than 254 characters';
                        }
                        
                        // Check for @ symbol
                        if (!trimmedValue.contains('@')) {
                          return 'Email must contain @ symbol';
                        }
                        
                        // Check for multiple @ symbols
                        if (trimmedValue.split('@').length > 2) {
                          return 'Email cannot contain multiple @ symbols';
                        }
                        
                        // Split email into local and domain parts
                        final parts = trimmedValue.split('@');
                        final localPart = parts[0];
                        final domainPart = parts[1];
                        
                        // Validate local part
                        if (localPart.isEmpty) {
                          return 'Local part of email cannot be empty';
                        }
                        
                        if (localPart.length > 64) {
                          return 'Local part of email must be less than 64 characters';
                        }
                        
                        // Check for valid characters in local part
                        final localPartRegex = RegExp(r'^[a-zA-Z0-9._%+-]+$');
                        if (!localPartRegex.hasMatch(localPart)) {
                          return 'Local part contains invalid characters';
                        }
                        
                        // Check for consecutive dots in local part
                        if (localPart.contains('..')) {
                          return 'Local part cannot contain consecutive dots';
                        }
                        
                        // Check if local part starts or ends with dot
                        if (localPart.startsWith('.') || localPart.endsWith('.')) {
                          return 'Local part cannot start or end with a dot';
                        }
                        
                        // Validate domain part
                        if (domainPart.isEmpty) {
                          return 'Domain part of email cannot be empty';
                        }
                        
                        if (domainPart.length > 253) {
                          return 'Domain part must be less than 253 characters';
                        }
                        
                        // Check for valid domain format
                        final domainRegex = RegExp(r'^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                        if (!domainRegex.hasMatch(domainPart)) {
                          return 'Please enter a valid domain (e.g., gmail.com)';
                        }
                        
                        // Check for consecutive dots in domain
                        if (domainPart.contains('..')) {
                          return 'Domain cannot contain consecutive dots';
                        }
                        
                        // Check if domain starts or ends with dot
                        if (domainPart.startsWith('.') || domainPart.endsWith('.')) {
                          return 'Domain cannot start or end with a dot';
                        }
                        
                        // Check for valid TLD (Top Level Domain)
                        final tldRegex = RegExp(r'\.[a-zA-Z]{2,}$');
                        if (!tldRegex.hasMatch(domainPart)) {
                          return 'Domain must have a valid top-level domain (e.g., .com, .org)';
                        }
                        
                        // Check for minimum TLD length
                        final tld = domainPart.split('.').last;
                        if (tld.length < 2) {
                          return 'Top-level domain must be at least 2 characters';
                        }
                        
                        // Check for maximum TLD length
                        if (tld.length > 6) {
                          return 'Top-level domain cannot exceed 6 characters';
                        }
                        
                        // Check for common email providers (optional enhancement)
                        final commonProviders = [
                          'gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com',
                          'icloud.com', 'protonmail.com', 'aol.com', 'live.com',
                          'batstate-u.edu.ph', 'g.batstate-u.edu.ph'
                        ];
                        
                        final isCommonProvider = commonProviders.any(
                          (provider) => domainPart.toLowerCase() == provider
                        );
                        
                        if (!isCommonProvider) {
                          // Allow custom domains but show a warning
                          return null; // You could return a warning message here if desired
                        }
                        
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: GoogleFonts.poppins()),
              ),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    // Update the user information
                    appState.setCurrentUser(
                      name: nameController.text.trim(),
                      email: emailController.text.trim(),
                      role: appState.userRole ?? UserRole.reader,
                    );
                    Navigator.pop(context);
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Profile updated successfully!', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text('Save Changes', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPhotoUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.photo_camera_rounded, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Text('Change Profile Photo', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_camera_rounded,
              size: 48,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Photo upload feature coming soon!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }



  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Change Password', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Password change feature coming soon!', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Privacy Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Privacy settings feature coming soon!', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }



  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Log Out', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to log out?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Sign out logic - navigate back to welcome screen
              final appState = Provider.of<AppStateProvider>(context, listen: false);
              appState.setRole(UserRole.reader);
              appState.setScreen(AppScreen.welcome);
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: Text('Log Out', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }
} 