import 'package:firstproject/imam/ajoutesession.dart';
import 'package:firstproject/imam/createens.dart';
import 'package:firstproject/imam/publication.dart';
import 'package:firstproject/imam/settingscreenimam.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyHomeScreenImam extends StatefulWidget {
  @override
  _MyHomeScreenState createState() => _MyHomeScreenState();
}

class _MyHomeScreenState extends State<MyHomeScreenImam> {
  int _selectedIndex = 1;
  List<String> _appBarTitles = [
    'الطلبات',
    'الصفحة الرئيسية',
    'الإعدادات',
  ];

  late Stream<DocumentSnapshot<Map<String, dynamic>>> _mosqueStream;

  @override
  void initState() {
    super.initState();
    _mosqueStream = FirebaseFirestore.instance
        .collection('mosques')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B9FD0), // Custom background color
        title: Text(
          _appBarTitles[_selectedIndex],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Custom text color
          ),
        ),
        elevation: 0, // No shadow
        centerTitle: true, // Center the title
      ),
      drawer: Drawer(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _mosqueStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error loading mosque data'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Mosque data not found'));
            }

            Map<String, dynamic> data = snapshot.data!.data()!;
            String? mosqueName = data['name'];

            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B9FD0),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.mosque, color: Colors.white, size: 32),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          mosqueName ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.article),
                  title: const Text('اساتذة المسجد'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EnseignantsMosequiPage()),
                    );
                  },
                ),
               /* ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('افواج المسجد'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  GroupList()),
                    );
                  },
                ),*/
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          const Divider(
            color: Colors.grey,
            thickness: 1,
            height: 0,
          ),
          Expanded(
            child: _buildPage(_selectedIndex),
          ),
        ],
      ),
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
        return MosequiPublicationsPage();
      case 0:
        return AllSessionPage();
      case 2:
        return SettingsScreen();
      default:
        return const Center(
          child: Text('Page inconnue'),
        );
    }
  }
}
