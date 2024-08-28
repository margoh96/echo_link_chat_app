import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:echo_link/data/datasources/firebase_datasource.dart';
import 'package:echo_link/data/models/user_model.dart';
import 'package:echo_link/pages/widgets/chat_tile.dart';

class FrendsPage extends StatefulWidget {
  const FrendsPage({super.key});

  @override
  State<FrendsPage> createState() => _FrendsPageState();
}

class _FrendsPageState extends State<FrendsPage> {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: StreamBuilder<List<UserModel>>(
          stream: FirebaseDatasource.instance.allUser(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final List<UserModel> users = (snapshot.data ?? [])
                .where((e) => e.id != currentUser!.uid)
                .toList();

            if (users.isEmpty) {
              return const Center(child: Text('No users'));
            }
            return ListView.separated(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  return ChatTile(
                      leading: users[index].userName[0],
                      name: users[index].userName,
                      lastMessage: users[index].email,
                      partnerUser: users[index]);
                 
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                });
          }),
    );
  }
}
