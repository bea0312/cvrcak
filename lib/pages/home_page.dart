import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cvrcak2/pages/home_page_content.dart';
import 'package:cvrcak2/pages/settings_page.dart';
import 'package:cvrcak2/pages/timeline_page.dart';
import 'package:cvrcak2/pages/livechat_page.dart';
import 'package:cvrcak2/pages/user_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;
  String? username;

  int _selectedIndex = 0;

  //static const TextStyle optionStyle = TextStyle(fontSize: 30);

  final List<Widget> _widgetOptions = <Widget>[
    const HomePageContent(),
    const TimelinePage(),
    const LivechatPage(),
    const UserPage(),
    const SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  Future<void> fetchUsername() async {
    user.updateProfile(displayName: username);
    final uid = user.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (userDoc.exists) {
      setState(() {
        username = userDoc['username'];
      });
    }
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
        backgroundColor: Colors.deepOrange.shade400,
        title: const Center(
          child: Text(
            "Cvrčak",
            style: TextStyle(color: Colors.white),
          ),
        ),
        leading: Text(username != null ? 'Welcome, $username!' : 'Loading...'),
        actions: [
          IconButton(
            color: Colors.white.withOpacity(0.3),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
            ),
          )
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(0.0),
        child: GNav(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          gap: 8,
          tabBackgroundColor: Colors.deepOrange.shade400
              .withOpacity(1), // Background color for active tab
          activeColor: Colors.white, // Text and icon color for active tab
          color: Colors.black, // Text and icon color for inactive tabs
          selectedIndex: _selectedIndex,
          onTabChange: _onItemTapped,
          tabs: const [
            GButton(
              icon: Icons.home,
              text: 'Home',
            ),
            GButton(
              icon: Icons.notifications_sharp,
              text: 'Timeline',
            ),
            GButton(
              icon: Icons.groups_sharp,
              text: 'Livechat',
            ),
            GButton(
              icon: Icons.person,
              text: 'User',
            ),
            GButton(
              icon: Icons.settings,
              text: 'Settings',
            )
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
    );
  }
}
