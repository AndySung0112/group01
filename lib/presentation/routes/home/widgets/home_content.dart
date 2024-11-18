import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_01/bloc/group/group_bloc.dart';

class HomeContent extends StatelessWidget {
  final TextEditingController _groupCodeController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupBloc, GroupState>(
      builder: (context, state) {
        if (state is GroupLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is GroupError) {
          return Center(
            child: Text(state.message),
          );
        } else if (state is GroupLoaded) {
          return Column(
            children: [
              Expanded(
                  child: ListView.builder(
                      itemCount: state.groups.length,
                      itemBuilder: (context, index) {
                        final group = state.groups[index];
                        return ListTile(
                          title: Text(group.name),
                          trailing: GroupCodeButton(
                              groupId: group.id,
                              onPressed: (groupId) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text("群組代碼"),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text("群組代碼: $groupId"),
                                            SizedBox(height: 10),
                                            ElevatedButton(
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: groupId));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(SnackBar(
                                                  content: Text("群組代碼已複製"),
                                                ));
                                              },
                                              child: Text("複製代碼"),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              }),
                          onTap: () {
                            //導航置聊天室
                            Navigator.of(context)
                                .pushNamed('/chat', arguments: group);
                          },
                        );
                      })),
              TextField(
                controller: _groupCodeController,
                decoration: InputDecoration(labelText: '加入群組代碼'),
              ),
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<GroupBloc>(context).add(
                    GroupJoinRequested(_groupCodeController.text),
                  );
                },
                child: Text('加入群組'),
              ),
              TextField(
                controller: _groupNameController,
                decoration: InputDecoration(labelText: '創建新群組名稱'),
              ),
              ElevatedButton(
                onPressed: () {
                  BlocProvider.of<GroupBloc>(context).add(
                    GroupCreateRequested(_groupNameController.text),
                  );
                },
                child: Text('創建群組'),
              ),
            ],
          );
        }
        return Container(); //其他情況
      },
    );
  }
}

class GroupCodeButton extends StatelessWidget {
  final String groupId;
  final Function(String groupId) onPressed;

  GroupCodeButton({
    required this.groupId,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.share),
      onPressed: () => onPressed(groupId),
    );
  }
}
