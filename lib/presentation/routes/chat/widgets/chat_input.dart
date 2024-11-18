import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatInputField extends StatefulWidget {
  final String groupId;
  final ScrollController scrollController; //接收scrollcontroller
  ChatInputField({
    required this.groupId,
    required this.scrollController,
  });

  @override
  _ChatInputFieldState createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField> {
  final TextEditingController _controller = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  late Future<String> _currentUuserName;
  @override
  void initState() {
    super.initState();
    _currentUuserName = _getCurrentUserName();
  }

  Future<String> _getCurrentUserName() async {
    DocumentSnapshot userDocc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .get();
    return userDocc.exists ? userDocc['name'] : '匿名';
  }

  void _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isNotEmpty) {
      try {
        //獲得名稱
        final senderName = await _currentUuserName;
        FirebaseFirestore.instance
            .collection('groups')
            .doc(widget.groupId)
            .collection('messages')
            .add({
          'senderId': currentUserId,
          'senderName': senderName,
          'text': message,
          'timestamp': FieldValue.serverTimestamp(),
        });
        _controller.clear(); // 清空輸入框
      } catch (e) {
        print('發送訊息錯誤: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: '輸入訊息...'),
            ),
          ),
          IconButton(
            icon: Icon(Icons.send),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
