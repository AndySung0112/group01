import 'package:cloud_firestore/cloud_firestore.dart';

class Group {
  final String id;
  final String name;

  Group({required this.id, required this.name});

  factory Group.fromDocument(DocumentSnapshot doc) {
    return Group(
      id: doc.id,
      name: doc['name'], // 從DocumentSnapshot獲得名稱
    );
  }
}
