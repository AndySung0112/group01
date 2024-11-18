import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_01/bloc/exam/exam_bloc.dart';

class StudentExamPage extends StatefulWidget {
  final String groupId;
  StudentExamPage({required this.groupId});

  @override
  _StudentExamPageState createState() => _StudentExamPageState();
}

class _StudentExamPageState extends State<StudentExamPage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 每次進入此頁面刷新exam
    context.read<ExamBloc>().add(LoadPublishedExams(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    // 頁面初始化時加載已發布測驗
    return Scaffold(
      appBar: AppBar(title: Text('可用測驗')),
      body: BlocBuilder<ExamBloc, ExamState>(
        builder: (context, state) {
          if (state is ExamLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is ExamLoadSuccess) {
            final exams = state.tests; // 顯示已發布測驗
            if (exams.isEmpty) {
              return Center(
                child: Text("沒有測驗"),
              );
            }
            return ListView.builder(
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final exam = exams[index];
                return ListTile(
                  title: Text(exam.title),
                  subtitle: Text('問題數量: ${exam.questions.length}'),
                  onTap: () {},
                );
              },
            );
          } else if (state is ExamError) {
            return Center(child: Text(state.message));
          }
          return Container();
        },
      ),
    );
  }
}
