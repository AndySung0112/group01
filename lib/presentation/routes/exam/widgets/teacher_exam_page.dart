import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_01/bloc/exam/exam_bloc.dart';
import 'package:group_01/presentation/routes/exam/widgets/exam_create.dart';
import 'package:group_01/presentation/routes/exam/widgets/modify_exam_page.dart';

class TeacherExamPage extends StatefulWidget {
  final String groupId;
  TeacherExamPage({required this.groupId});

  @override
  _TeacherExamPageState createState() => _TeacherExamPageState();
}

class _TeacherExamPageState extends State<TeacherExamPage> {
  @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   // 每次進入此頁面刷新exam
  //   context.read<ExamBloc>().add(LoadAllExams(widget.groupId));
  // }
  void initState() {
    super.initState();
    context.read<ExamBloc>().add(LoadAllExams(widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("我的測驗"),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context2) {
                  return BlocProvider.value(
                    value: BlocProvider.of<ExamBloc>(context),
                    child: CreateTestPage(
                      groupId: widget.groupId,
                    ),
                  );
                },
              ));
            },
          )
        ],
      ),
      body: BlocBuilder<ExamBloc, ExamState>(builder: (context, state) {
        if (state is ExamLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is ExamLoadSuccess) {
          final tests = state.tests;
          if (tests.isEmpty) {
            return Center(
              child: Text("沒有測驗"),
            );
          }
          return ListView.builder(
              itemCount: tests.length,
              itemBuilder: (context, index) {
                final test = tests[index];
                return ListTile(
                  title: Text(test.title),
                  subtitle: Text("問題數量: ${test.questions.length}"),
                  onTap: () async {
                    await Navigator.push(context, MaterialPageRoute(
                      builder: (context2) {
                        return BlocProvider.value(
                          value: BlocProvider.of<ExamBloc>(context)
                            ..add(LoadTestByIdEvent(test.id, widget.groupId)),
                          child: ModifyExamPage(
                            groupId: widget.groupId,
                            examId: test.id,
                          ),
                        );
                      },
                    ));
                  },
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      context
                          .read<ExamBloc>()
                          .add(DeleteExamEvent(test.id, widget.groupId));
                    },
                  ),
                );
              });
        } else if (state is ExamError) {
          return Center(child: Text(state.message));
        }
        return Center(child: CircularProgressIndicator()
            // child: Text("無法讀取測驗"),
            );
      }),
    );
  }
}
