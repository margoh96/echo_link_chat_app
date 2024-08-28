import 'package:echo_link/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:echo_link/constant/colors.dart';
import 'package:echo_link/pages/channels_page.dart';
import 'package:echo_link/pages/friends_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with the number of tabs
    _tabController = TabController(initialIndex: 1, length: 2, vsync: this);
  }

  @override
  void dispose() {
    // Dispose the TabController to avoid memory leaks
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.chat_outlined, color: AppColors.quaternary),
            SizedBox(width: 10),
            Text('Echo Link', style: TextStyle(color: AppColors.quaternary)),
          ],
        ),
        backgroundColor: AppColors.primary,
        bottom: TabBar(
          indicatorColor: AppColors.tertiary,
          indicatorWeight: 4,
          controller: _tabController,
          tabs: const [
            Tab(
              icon: Icon(
                Icons.group,
                color: AppColors.quaternary,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.chat,
                color: AppColors.quaternary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              icon: const Icon(
                Icons.logout,
                color: AppColors.quaternary,
              ))
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          FrendsPage(),
          ChannelsPage(),
        ],
      ),
    );
  }
}
