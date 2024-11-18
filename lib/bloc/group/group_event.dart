part of 'group_bloc.dart';

abstract class GroupEvent {}

class GroupLoadRequested extends GroupEvent {}

class GroupCreateRequested extends GroupEvent {
  final String groupName;
  GroupCreateRequested(this.groupName);
}

class GroupJoinRequested extends GroupEvent {
  final String groupCode;
  GroupJoinRequested(this.groupCode);
}
