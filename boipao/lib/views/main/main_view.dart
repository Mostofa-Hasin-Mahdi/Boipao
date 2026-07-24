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
  final GlobalKey<HomeViewState> _homeKey = GlobalKey<HomeViewState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeView(key: _homeKey),
      const SearchView(),
      const InboxView(),
      const NotificationsView(),
      const ProfileView(),
    ];
    
    _controller.addListener(() {
      setState(() {});
      if (_controller.currentIndex == 4) {
        final auth = context.read<AuthController>();
        final user = auth.currentUser;
        if (user != null) {
          auth.fetchProfile(user.id);
        }
      }
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
    final notifCtrl = context.watch<NotificationController>();
    final hasUnreadNotifs = notifCtrl.unreadCount > 0;

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
              hasUnreadNotifications: hasUnreadNotifs,
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
                  ).then((_) {
                    _homeKey.currentState?.fetchRecentListings();
                    _homeKey.currentState?.fetchFeaturedMaterial();
                    // Also tell MaterialController to refresh my listings just in case they go to Profile tab next
                    // To do this we would need context, but MainView is above MyListingsView so the best place to refresh MyListings is when MyListingsView opens. But we can trigger a global refresh event if we want.
                  });
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
