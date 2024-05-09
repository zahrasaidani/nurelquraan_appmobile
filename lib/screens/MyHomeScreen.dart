import 'package:flutter/material.dart';
import 'package:firstproject/screens/SettingsScreen.dart';
import 'package:firstproject/screens/PublicationScreen.dart';
/*import 'package:asmaa/screens/MapScreen.dart';
import 'package:asmaa/locales/en.json';
import 'package:asmaa/locales/ar.json';*/

class MyHomeScreen extends StatefulWidget {
  MyHomeScreen();

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreen> {
  int _selectedIndex = 1;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPage(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts),
            label: 'الإعدادات',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 1:
        return Center(
          child: PublicationScreen(),
        );
      case 0:
        return const Center(
          child: Text('Map'),
        );
      case 2:
        return Center(
          child: SettingsScreen(),
        );
      default:
        return const Center(
          child: Text('Page inconnue'),
        );
    }
  }
}