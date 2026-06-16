import 'package:flutter/material.dart';

import './TabScreens/home_tab_screen.dart';
import './app_sections.dart';
import '../widgets/app_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _didReadInitialIndex = false;

  static const List<Widget> _pages = <Widget>[
    HomeTabScreen(),
    OrdersScreen(),
    CarsScreen(),
    AnimalsScreen(),
    ConsultantsScreen(),
    AccountScreen(),
  ];

  static const List<String> _titles = [
    'شور',
    'الطلبات',
    'السيارات',
    'الحيوانات',
    'المستشارون',
    'الحساب',
  ];

  @override
  Widget build(BuildContext context) {
    if (!_didReadInitialIndex) {
      final initialIndex = ModalRoute.of(context)?.settings.arguments;
      if (initialIndex is int &&
          initialIndex >= 0 &&
          initialIndex < _pages.length) {
        _selectedIndex = initialIndex;
      }
      _didReadInitialIndex = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            tooltip: 'الإشعارات',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNav(selectedIndex: _selectedIndex),
    );
  }
}
