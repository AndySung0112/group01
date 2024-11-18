import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String text;
  final String senderId;
  final String senderName;
  final Timestamp timestamp;

  Message({
    required this.text,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
  });

  factory Message.fromDocument(DocumentSnapshot doc) {
    Timestamp timestamp = doc['timestamp'] ?? Timestamp.now();
    return Message(
      text: doc['text'],
      senderId: doc['senderId'],
      senderName: doc['senderName'],
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'senderName': senderName,
      'timestamp': timestamp,
    };
  }
}
