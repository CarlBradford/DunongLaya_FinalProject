import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import 'auth/login_register_screen.dart';
import 'home/home_screen.dart';
import 'article/article_detail_page.dart';
import 'staff/staff_dashboard.dart';
import 'staff/article_management_screen.dart';
import 'profile/profile_page.dart';
import 'welcome_screen.dart';
import 'admin/user_management_screen.dart';
import 'admin/analytics_screen.dart';

class AppNavigator extends StatelessWidget {
  const AppNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        Widget screen;
        switch (appState.currentScreen) {
          case AppScreen.splash:
            screen = const WelcomeScreen();
            break;
          case AppScreen.login:
            if (appState.role == UserRole.staff) {
              screen = const LoginRegisterScreen();
            } else {
              screen = const HomeScreen();
            }
            break;
          case AppScreen.home:
            screen = const HomeScreen();
            break;
          case AppScreen.articleDetail:
            screen = ArticleDetailPage(article: appState.selectedArticle!);
            break;
          case AppScreen.staffDashboard:
            screen = StaffDashboard(isAdmin: appState.role == UserRole.admin);
            break;
          case AppScreen.articleManagement:
            screen = ArticleManagementScreen(isAdmin: appState.role == UserRole.admin);
            break;
          case AppScreen.userManagement:
            screen = const UserManagementScreen();
            break;
          case AppScreen.profile:
            screen = const ProfilePage();
            break;
          case AppScreen.analytics:
            screen = const AnalyticsScreen();
            break;
          default:
            screen = const WelcomeScreen();
        }
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          switchInCurve: Curves.easeInOut,
          switchOutCurve: Curves.easeInOut,
          child: screen,
        );
      },
    );
  }
} 