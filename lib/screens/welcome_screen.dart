import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/app_state_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () => _slideController.forward());
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 500;
    return Scaffold(
      body: Container(
        decoration: _buildGradientBackground(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 18.0 : 52.0),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: isMobile ? 10 : 20),
                      _buildAnimatedLogo(isMobile: isMobile),
                      SizedBox(height: isMobile ? 18 : 32),
                      _buildTitle(isMobile: isMobile),
                      SizedBox(height: isMobile ? 6 : 10),
                      _buildSubtitle(isMobile: isMobile),
                      SizedBox(height: isMobile ? 18 : 30),
                      _buildReaderButton(context, isMobile: isMobile),
                      SizedBox(height: isMobile ? 12 : 20),
                      _buildStaffButton(context, isMobile: isMobile),
                      SizedBox(height: isMobile ? 24 : 40),
                      _buildFooter(isMobile: isMobile),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.surface,
          AppColors.surface.withOpacity(0.8),
          AppColors.secondary.withOpacity(0.1),
        ],
        stops: const [0.0, 0.7, 1.0],
      ),
    );
  }

  Widget _buildAnimatedLogo({bool isMobile = false}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.8, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.all(isMobile ? 10 : 20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: isMobile ? 18 : 30,
                  spreadRadius: isMobile ? 2 : 5,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/the_axis_logo.png',
                height: isMobile ? 110 : 200,
                width: isMobile ? 110 : 200,
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTitle({bool isMobile = false}) {
    return ShaderMask(
      shaderCallback: (bounds) => LinearGradient(
        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
      ).createShader(bounds),
      child: Text(
        "DunongLaya",
        style: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: isMobile ? 28 : 42,
          letterSpacing: 2.0,
          shadows: [
            Shadow(
              color: AppColors.primary.withOpacity(0.5),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle({bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 20, vertical: isMobile ? 6 : 8),
      decoration: BoxDecoration(
        color: AppColors.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
      ),
      child: Text(
        "A Student Publication Platform for The AXIS",
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: AppColors.textSecondary,
          fontSize: isMobile ? 12 : 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildReaderButton(BuildContext context, {bool isMobile = false}) {
    return _AnimatedButton(
      onPressed: () {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        appState.setRole(UserRole.reader);
        appState.setScreen(AppScreen.home);
      },
      isPrimary: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            "Continue as Reader",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: isMobile ? 14 : 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffButton(BuildContext context, {bool isMobile = false}) {
    return _AnimatedButton(
      onPressed: () {
        final appState = Provider.of<AppStateProvider>(context, listen: false);
        appState.setRole(UserRole.staff);
        appState.setScreen(AppScreen.login);
      },
      isPrimary: false,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.admin_panel_settings_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            "Continue as Publication Staff",
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: isMobile ? 14 : 16, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter({bool isMobile = false}) {
    return Text(
      "© 2025 The AXIS Group of Publication",
      style: GoogleFonts.poppins(
        color: AppColors.textSecondary.withOpacity(0.7),
        fontSize: isMobile ? 10 : 12,
      ),
    );
  }
}

class _AnimatedButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isPrimary;
  final Widget child;

  const _AnimatedButton({
    required this.onPressed,
    required this.isPrimary,
    required this.child,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: GestureDetector(
          onTapDown: (_) => _controller.forward(),
          onTapUp: (_) {
            _controller.reverse();
            widget.onPressed();
          },
          onTapCancel: () => _controller.reverse(),
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: BoxDecoration(
                    gradient: widget.isPrimary
                        ? LinearGradient(colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)])
                        : null,
                    color: widget.isPrimary ? null : Colors.transparent,
                    borderRadius: BorderRadius.circular(28),
                    border: widget.isPrimary ? null : Border.all(color: AppColors.primary, width: 2),
                    boxShadow: [
                      if (widget.isPrimary)
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                    ],
                  ),
                  child: Center(child: widget.child),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
