import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/group_creation_screen.dart';
import '../screens/group_chat_screen.dart';
import '../screens/user_profile_screen.dart';
import '../screens/admin_dashboard_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String dashboard = '/dashboard';
  static const String groupCreation = '/group-creation';
  static const String groupChat = '/group-chat';
  static const String userProfile = '/user-profile';
  static const String adminDashboard = '/admin-dashboard';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildPageRoute(const SplashScreen(), settings);
      case login:
        return _buildPageRoute(const LoginScreen(), settings);
      case signup:
        return _buildPageRoute(const SignupScreen(), settings);
      case dashboard:
        return _buildPageRoute(const DashboardScreen(), settings);
      case groupCreation:
        return _buildPageRoute(const GroupCreationScreen(), settings);
      case groupChat:
        final args = settings.arguments as Map<String, dynamic>?;
        return _buildPageRoute(
          GroupChatScreen(groupId: args?['groupId'] ?? ''),
          settings,
        );
      case userProfile:
        return _buildPageRoute(const UserProfileScreen(), settings);
      case adminDashboard:
        return _buildPageRoute(const AdminDashboardScreen(), settings);
      default:
        return _buildPageRoute(const LoginScreen(), settings);
    }
  }

  static PageRouteBuilder _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }
}