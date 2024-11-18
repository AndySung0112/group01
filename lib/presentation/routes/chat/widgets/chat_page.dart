import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_01/model/chat/message_model.dart';
import 'package:group_01/presentation/routes/chat/widgets/chat_input.dart';
import 'package:group_01/presentation/routes/exam/exam_route.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  ChatPage({required this.groupId, required this.groupName});
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ScrollController _scrollController = ScrollController();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  //滾動
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              //選擇功能
              if (value == "測驗") {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ExamRoute(
                              groupId: widget.groupId,
                            )));
              }
            },
            itemBuilder: (context) {
              return ['測驗', '公告', '作業'].map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('沒有訊息'));
                }

                final messages = snapshot.data!.docs
                    .map((doc) => Message.fromDocument(doc))
                    .toList();

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });

                return ListView.builder(
                  controller: _scrollController,
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isSelf = message.senderId == currentUserId;
                    return Align(
                      alignment:
                          isSelf ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: isSelf ? Colors.blue : Colors.grey[200],
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message.senderName,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 4,
                                ),
                                Text(message.text),
                              ])),
                    );
                  },
                );
              },
            ),
          ),
          ChatInputField(
              groupId: widget.groupId, scrollController: _scrollController),
        ],
      ),
    );
  }
}
