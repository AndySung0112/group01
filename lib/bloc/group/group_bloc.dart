import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_01/model/group/group_model.dart';
part 'group_event.dart';
part 'group_state.dart';

class GroupBloc extends Bloc<GroupEvent, GroupState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  GroupBloc() : super(GroupLoading()) {
    on<GroupLoadRequested>(_onLoadGroups);
    on<GroupJoinRequested>(_onJoinGroup);
    on<GroupCreateRequested>(_onCreateGroup);
  }

  Future<void> _onLoadGroups(
      GroupLoadRequested event, Emitter<GroupState> emit) async {
    emit(GroupLoading());
    try {
      //從Firebase加載群組數據
      //獲取群組數據邏輯
      final userId = FirebaseAuth.instance.currentUser!.uid;
      //列出使用者所有的群組
      final groupsSnapshot = await _firestore
          .collection('groups')
          .where('members', arrayContains: userId)
          .get();
      final groups =
          groupsSnapshot.docs.map((doc) => Group.fromDocument(doc)).toList();
      emit(GroupLoaded(groups));
    } catch (e) {
      emit(GroupError("無法載入群組列表: ${e.toString()}"));
    }
  }

  Future<void> _onCreateGroup(
      GroupCreateRequested event, Emitter<GroupState> emit) async {
    emit(GroupLoading());
    try {
      //在firebase創建群組
      //創建者ID保存為群組老師身分
      //自動創建的group.id為groupcode
      final groupDoc = await _firestore.collection('groups').add({
        'name': event.groupName,
        'creatorId': FirebaseAuth.instance.currentUser!.uid,
        'members': [FirebaseAuth.instance.currentUser!.uid],
      });
      //使用group.id來當作群組代碼
      await _firestore.collection('groups').doc(groupDoc.id).update({
        'groupCode': groupDoc.id,
      });
      add(GroupLoadRequested());
      if (state is GroupLoaded) {
        final currentGroups = (state as GroupLoaded).groups;
        emit(GroupLoaded([...currentGroups])); // 更新群組列表
      }
    } catch (e) {
      emit(GroupError("創建群組失敗: ${e.toString()}"));
    }
  }

  Future<void> _onJoinGroup(
      GroupJoinRequested event, Emitter<GroupState> emit) async {
    emit(GroupLoading());
    try {
      //根據groupcode加入群組
      final groupSnapshot = await _firestore
          .collection('groups')
          .where('groupCode', isEqualTo: event.groupCode)
          .get();
      if (groupSnapshot.docs.isNotEmpty) {
        //找到群組並更新成員列表
        final groupDoc = groupSnapshot.docs.first;
        await groupDoc.reference.update({
          'members':
              FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
        });
        add(GroupLoadRequested());
      } else {
        emit(GroupError("找不到對應的群組代碼"));
      }
    } catch (e) {
      emit(GroupError("加入群組失敗: ${e.toString()}"));
    }
  }
}
