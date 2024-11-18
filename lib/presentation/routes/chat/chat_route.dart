import 'package:flutter/material.dart';
import 'package:group_01/model/group/group_model.dart';
import 'package:group_01/presentation/routes/chat/widgets/chat_page.dart';

class ChatRoute extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final group = ModalRoute.of(context)!.settings.arguments as Group; //類型轉換

    return Scaffold(
      body: ChatPage(
        groupId: group.id,
        groupName: group.name,
      ), //(child: Text('歡迎加入 ${group.name} 的聊天室')),
    );
  }
}
