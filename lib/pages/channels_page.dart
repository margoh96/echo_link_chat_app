import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:echo_link/data/datasources/firebase_datasource.dart';
import 'package:echo_link/data/models/channel_model.dart';
import 'package:echo_link/pages/widgets/chat_tile.dart';

class ChannelsPage extends StatefulWidget {
  const ChannelsPage({super.key});

  @override
  State<ChannelsPage> createState() => _ChannelsPageState();
}

class _ChannelsPageState extends State<ChannelsPage> {
  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Channel>>(
          stream: FirebaseDatasource.instance
              .channelStream(currentUser!.uid)
              .asBroadcastStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final List<Channel> channels = snapshot.data ?? [];

            if (channels.isEmpty) {
              return const Center(child: Text('No chats found'));
            }
            return ListView.separated(
                itemCount: channels.length,
                itemBuilder: (context, index) {
                  return ChatTile(
                      leading: channels[index]
                          .members
                          .where((e) => e.id != currentUser!.uid)
                          .first
                          .userName[0],
                      name: channels[index]
                          .members
                          .where((e) => e.id != currentUser!.uid)
                          .first
                          .userName,
                      lastMessage: channels[index].lastMessage,
                      partnerUser: channels[index]
                          .members
                          .where((e) => e.id != currentUser!.uid)
                          .first);
                },
                separatorBuilder: (context, index) {
                  return const Divider();
                });
          }),
    );
  }
}
