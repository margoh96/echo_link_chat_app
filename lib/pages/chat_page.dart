// ignore_for_file: public_member_api_docs, sort_constructors_first, prefer_const_constructors
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:echo_link/constant/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:echo_link/data/datasources/firebase_datasource.dart';
import 'package:echo_link/data/models/channel_model.dart';
import 'package:echo_link/data/models/message_model.dart';
import 'package:echo_link/data/models/user_model.dart';

import 'widgets/chat_bubble.dart';

class ChatPage extends StatefulWidget {
  final UserModel partnerUser;
  const ChatPage({
    Key? key,
    required this.partnerUser,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final currentUser = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CupertinoButton(
          child: const Icon(
            Icons.arrow_back_ios,
            color: AppColors.quaternary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.partnerUser.userName.toUpperCase(),
            style: TextStyle(color: AppColors.quaternary)),
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Message>>(
                stream: FirebaseDatasource.instance.messageStream(
                    channelid(widget.partnerUser.id, currentUser!.uid)),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final List<Message> messages = snapshot.data ?? [];

                  if (messages.isEmpty) {
                    return const Center(child: Text('No messages found'));
                  }
                  return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics()),
                      reverse: true,
                      padding: const EdgeInsets.all(10),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        return ChatBubble(
                          direction: message.senderId == currentUser!.uid
                              ? Direction.right
                              : Direction.left,
                          message: message.textMessage,
                          type: determineBubbleType(messages, index),
                        );
                      });
                }),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    // Send message logic here
                    sendMessage();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }
    // channel not created yet

    final channel = Channel(
      id: channelid(currentUser!.uid, widget.partnerUser.id),
      memberIds: [currentUser!.uid, widget.partnerUser.id],
      members: [UserModel.fromFirebaseUser(currentUser!), widget.partnerUser],
      lastMessage: _messageController.text.trim(),
      sendBy: currentUser!.uid,
      lastTime: Timestamp.now(),
      unRead: {
        currentUser!.uid: false,
        widget.partnerUser.id: true,
      },
    );

    await FirebaseDatasource.instance
        .updateChannel(channel.id, channel.toMap());

    var docRef = FirebaseFirestore.instance.collection('messages').doc();
    var message = Message(
      id: docRef.id,
      textMessage: _messageController.text.trim(),
      senderId: currentUser!.uid,
      sendAt: Timestamp.now(),
      channelId: channel.id,
    );
    FirebaseDatasource.instance.addMessage(message);

    var channelUpdateData = {
      'lastMessage': message.textMessage,
      'sendBy': currentUser!.uid,
      'lastTime': message.sendAt,
      'unRead': {
        currentUser!.uid: false,
        widget.partnerUser.id: true,
      },
    };
    FirebaseDatasource.instance.updateChannel(channel.id, channelUpdateData);

    _messageController.clear();
  }

  BubbleType determineBubbleType(List<Message> messages, int index) {
    if (messages.isEmpty || index < 0 || index >= messages.length) {
      return BubbleType.alone;
    }

    String currentSender = messages[index].senderId;
    String? nextSender = index > 0 ? messages[index - 1].senderId : null;
    String? previousSender =
        index < messages.length - 1 ? messages[index + 1].senderId : null;

    // Periksa kondisi untuk pesan pertama
    // if (previousSender == null && nextSender != currentSender) {
    //   return BubbleType.alone;
    // } else
    if (previousSender == null && nextSender == currentSender) {
      return BubbleType.top;
    } else if (previousSender != currentSender && nextSender == currentSender) {
      return BubbleType.top;
    } else if (previousSender == currentSender && nextSender == currentSender) {
      return BubbleType.middle;
    } else if (previousSender == currentSender && nextSender != currentSender) {
      return BubbleType.bottom;
    }

    return BubbleType.alone;
  }
}
