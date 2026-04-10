import 'package:flutter/material.dart';
import '../../controllers/main_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/glass_nav_bar.dart';
import '../home/home_view.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  final MainController _controller = MainController();

  final List<Widget> _pages = [
    const HomeView(),
    const Center(child: Text("Search Page", style: TextStyle(color: AppColors.textMain, fontSize: 20))),
    const Center(child: Text("Add Listing", style: TextStyle(color: AppColors.textMain, fontSize: 20))),
    const Center(child: Text("Profile Page", style: TextStyle(color: AppColors.textMain, fontSize: 20))),
  ];

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
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
      extendBody: true, // Important so body goes behind bottom nav
      body: Stack(
        children: [
          _pages[_controller.currentIndex],
          Align(
            alignment: Alignment.bottomCenter,
            child: GlassNavBar(
              selectedIndex: _controller.currentIndex,
              onItemSelected: _controller.changeTab,
            ),
          ),
        ],
      ),
    );
  }
}
