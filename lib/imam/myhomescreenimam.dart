import 'dart:ui';

import 'package:firstproject/imam/creationsession.dart';
import 'package:firstproject/imam/publication.dart';
import 'package:firstproject/imam/settingscreenimam.dart';
import 'package:flutter/material.dart';

/*import 'package:asmaa/screens/MapScreen.dart';
import 'package:asmaa/locales/en.json';
import 'package:asmaa/locales/ar.json';*/

class MyHomeScreenImam extends StatefulWidget {
  MyHomeScreenImam();

  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreenImam> {
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
            icon: Icon(Icons.assignment),
            label: 'طلبات',
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
          child: MosequiPublicationsPage(),
        );
      case 0:
        return  Center(
          child: ConfirmationPage(),
        );
      case 2:
        return Center(
          child: SettingsScreenImam(),
        );
      default:
        return const Center(
          child: Text('Page inconnue'),
        );
    }
  }
}

