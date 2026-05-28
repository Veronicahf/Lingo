import 'package:flutter/material.dart';

import '../views/challenges_view.dart';
import '../views/home_view.dart';
import '../views/news_view.dart';
import '../views/more_view.dart';
import '../views/profile_view.dart';
import '../views/ranking_view.dart';
import '../widgets/custom_bottom_navigation_bar.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  static const List<Widget> _views = <Widget>[
    HomeView(),
    ChallengesView(),
    RankingView(),
    NewsView(),
    ProfileView(),
    MoreView(),
  ];

  void _onItemSelected(int index) {
    if (index == 5) {
      _showMoreOptionsBottomSheet();
      return;
    }

    if (index == _currentIndex) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  void _showMoreOptionsBottomSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF101820),
      barrierColor: Colors.black.withValues(alpha: 0.72),
      isScrollControlled: true,
      enableDrag: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) {
        return const MoreView();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101820),
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: _currentIndex,
          children: _views,
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onItemSelected: _onItemSelected,
        onMorePressed: _showMoreOptionsBottomSheet,
      ),
    );
  }
}