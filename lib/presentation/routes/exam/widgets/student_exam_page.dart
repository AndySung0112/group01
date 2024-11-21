// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_01/bloc/exam/exam_bloc.dart';
import 'package:group_01/presentation/routes/exam/widgets/exam_detail.dart';

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
    // final userId = FirebaseAuth.instance.currentUser!.uid;
    // 每次進入此頁面刷新exam
    // context.read<ExamBloc>().add(LoadCompletedExams(widget.groupId, userId));
    context.read<ExamBloc>().add(LoadPublishedExams(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    // final userId = FirebaseAuth.instance.currentUser!.uid;
    // 頁面初始化時加載已發布測驗
    return Scaffold(
      appBar: AppBar(title: Text('可用測驗')),
      body: BlocBuilder<ExamBloc, ExamState>(
        builder: (context, state) {
          if (state is ExamLoading) {
            return Center(child: CircularProgressIndicator());
          }
          // else if (state is ExamListLoaded) {
          //   final exams = state.test; // 顯示已發布測驗
          //   if (exams.isEmpty) {
          //     return Center(
          //       child: Text("沒有測驗"),
          //     );
          //   }
          //   return ListView.builder(
          //     itemCount: exams.length,
          //     itemBuilder: (context, index) {
          //       final exam = exams[index];
          //       final isCompleted = state.completionStatus[exam.id] ?? false;
          //       return ListTile(
          //         title: Text(exam.title),
          //         subtitle: isCompleted
          //             ? Text(
          //                 '已完成',
          //                 style: TextStyle(color: Colors.green),
          //               )
          //             : null,
          //         onTap: () {
          //           if (isCompleted) {
          //             // 如果已完成，查看總分及作答情況
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => ExamResultPage(
          //                   groupId: widget.groupId,
          //                   examId: exam.id,
          //                   userId: event.userId,
          //                 ),
          //               ),
          //             );
          //           } else {
          //             // 如果未完成，進入測驗頁面
          //             Navigator.push(
          //               context,
          //               MaterialPageRoute(
          //                 builder: (context) => ExamDetailPage(
          //                   groupId: event.groupId,
          //                   examId: exam.id,
          //                   userId: event.userId,
          //                 ),
          //               ),
          //             );
          //           }
          //         },
          //       );
          //     },
          //   );
          // }
          else if (state is ExamLoadSuccess) {
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
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context2) {
                        return BlocProvider.value(
                          value: BlocProvider.of<ExamBloc>(context),
                          // ..add(LoadTestByIdEvent(exam.id, widget.groupId)),
                          // ..add(StudentStartExam(
                          //     widget.groupId, exam.id, userId)),
                          child: ExamDetailPage(
                            groupId: widget.groupId,
                            examId: exam.id,
                            test: exam,
                          ),
                        );
                      },
                    ));
                  },
                );
              },
            );
          } else if (state is ExamError) {
            return Center(child: Text(state.message));
          }
          // else if (state is StudentExamSubmitted) {
          //   return Center(
          //     child: Text(state.score.toString()),
          //   );
          // }
          return Container();
        },
      ),
    );
  }
}
