import 'package:flutter/material.dart';

class ExamDetailPage extends StatelessWidget {
  final int examId;

  ExamDetailPage({required this.examId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("學生測驗頁面 $examId"),
      ),
      body: Center(
        child: Text(" $examId "),
      ),
    );
  }
}
