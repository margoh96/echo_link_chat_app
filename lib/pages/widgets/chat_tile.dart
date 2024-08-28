// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:echo_link/constant/colors.dart';
import 'package:echo_link/data/models/user_model.dart';
import 'package:echo_link/pages/chat_page.dart';

class ChatTile extends StatelessWidget {
  final String leading;
  final String name;
  final String lastMessage;
  final UserModel partnerUser;
  const ChatTile({
    Key? key,
    required this.leading,
    required this.name,
    required this.lastMessage,
    required this.partnerUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppColors.tertiary,
        radius: 25,
        child: Text(leading.toUpperCase(),
            style: const TextStyle(color: Colors.white)),
      ),
      title: Text(
        name.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(lastMessage),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return ChatPage(partnerUser: partnerUser);
        }));
      },
    );
  }
}
