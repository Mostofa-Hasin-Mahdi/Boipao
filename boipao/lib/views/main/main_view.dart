import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/main_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/notification_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_nav_bar.dart';
import '../home/home_view.dart';
import '../profile/profile_view.dart';
import '../listings/create_listing_view.dart';
import '../chat/inbox_view.dart';
import '../notifications/notifications_view.dart';
import 'search_view.dart';

/// The central scaffolding view for the application.
class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final MainController _controller = MainController();

  final List<Widget> _pages = [
    const HomeView(),
    const SearchView(),
    const InboxView(),
    const NotificationsView(),
    const ProfileView(),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifCtrl = context.read<NotificationController>();
      notifCtrl.fetchNotifications();
      notifCtrl.subscribeToNotifications();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(
            index: _controller.currentIndex,
            children: _pages,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GlassNavBar(
              selectedIndex: _controller.currentIndex,
              onItemSelected: _controller.changeTab,
            ),
          ),
          Positioned(
            bottom: 105,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                final auth = context.read<AuthController>();
                final user = auth.currentUser;
                
                if (user != null && !user.isVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please verify your student identity to post a listing!', style: TextStyle(color: Colors.black)),
                      backgroundColor: AppColors.warning,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateListingView()),
                  );
                }
              },
              backgroundColor: AppColors.navBar,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          )
        ],
      ),
    );
  }
}
