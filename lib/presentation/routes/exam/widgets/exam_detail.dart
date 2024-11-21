import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_01/bloc/exam/exam_bloc.dart';
import 'package:group_01/model/exam/exam_model.dart';

class ExamDetailPage extends StatefulWidget {
  final String examId;
  final String groupId;
  final Test test;

  const ExamDetailPage({
    Key? key,
    required this.groupId,
    required this.examId,
    required this.test,
  }) : super(key: key);

  @override
  _ExamDetailPageState createState() => _ExamDetailPageState();
}

class _ExamDetailPageState extends State<ExamDetailPage>
    with WidgetsBindingObserver {
  late Timer _timer;
  late DateTime _endTime;
  late int _remainingTime; // 剩餘時間（秒）
  int _currentQuestionIndex = 0;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  Map<int, Answer> studentAnswers = {};
  bool _isExamStarted = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // _initializeTimer();
  }

  void _initializeTimer() {
    final startTime = DateTime.now();
    _endTime = startTime.add(Duration(minutes: widget.test.timeLimit));
    print(_endTime);
    _updateRemainingTime();
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      _updateRemainingTime();
    });
  }

  void _updateRemainingTime() {
    setState(() {
      _remainingTime = _endTime
          .difference(DateTime.now())
          .inSeconds
          .clamp(0, double.infinity)
          .toInt();
      if (_remainingTime <= 0) {
        _submitExam();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_timer.isActive) _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isExamStarted) {
      _updateRemainingTime();
    }
  }

  void _submitExam() {
    _timer.cancel();
    context.read<ExamBloc>().add(StudentSubmitExam(
        groupId: widget.groupId,
        examId: widget.examId,
        userId: userId,
        studentAnswers: studentAnswers));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("開始測驗"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
              context.read<ExamBloc>().add(LoadPublishedExams(widget.groupId));
            }),
      ),
      body: !_isExamStarted ? _buildStartExamView() : _buildExamQuestionView(),
    );
  }

  Widget _buildStartExamView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "測驗標題: ${widget.test.title}",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          // Text(": "),
          Text("• 時間限制: ${widget.test.timeLimit} 分鐘"),
          Text("• 請在規定時間內完成，不可重複測驗"),
          Spacer(),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _isExamStarted = true;
                });
                context.read<ExamBloc>().add(
                    StudentStartExam(widget.groupId, widget.examId, userId));
                _initializeTimer();
              },
              child: Text("開始測驗"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExamQuestionView() {
    return Scaffold(
      body: BlocBuilder<ExamBloc, ExamState>(
        builder: (context, state) {
          if (state is ExamLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is StudentExamStarted) {
            final questions = state.test.questions;
            final question = questions[_currentQuestionIndex];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Time Remaining: ${(_remainingTime ~/ 60).toString().padLeft(2, '0')}:${(_remainingTime % 60).toString().padLeft(2, '0')}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Question ${_currentQuestionIndex + 1}/${questions.length}",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                // 題號列
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        widget.test.questions.length,
                        (index) {
                          final isCurrent = index == _currentQuestionIndex;
                          final isAnswered = studentAnswers.containsKey(index);

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isCurrent
                                    ? Colors.blue
                                    : isAnswered
                                        ? Colors.green
                                        : Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  _currentQuestionIndex = index;
                                  print("跳至第幾題: ${_currentQuestionIndex + 1}");
                                });
                              },
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                //上一題
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _currentQuestionIndex > 0
                          ? () {
                              setState(() {
                                _currentQuestionIndex--;
                              });
                            }
                          : null, //第一題禁用上一題
                      child: Text("上一題"),
                    ),
                    ElevatedButton(
                      onPressed: _currentQuestionIndex <
                              widget.test.questions.length - 1
                          ? () {
                              setState(() {
                                _currentQuestionIndex++;
                              });
                            }
                          : null, //最後一題禁用下一題
                      child: Text("下一題"),
                    ),
                  ],
                ),
                //問題內容
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    question.questionText,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                Expanded(
                  //問題選項
                  child: ListView.builder(
                    itemCount: question.options.length,
                    itemBuilder: (context, index) {
                      final option = question.options[index];
                      final isSelected =
                          studentAnswers[_currentQuestionIndex]?.answerText ==
                              option;
                      return ListTile(
                          title: Text(option,
                              style: TextStyle(
                                  color:
                                      isSelected ? Colors.blue : Colors.black,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal)),
                          onTap: () => {
                                setState(() {
                                  studentAnswers[_currentQuestionIndex] =
                                      studentAnswers[_currentQuestionIndex] ??
                                          Answer(answerText: option);
                                  studentAnswers[_currentQuestionIndex]!
                                      .answerText = option;
                                  print("選擇:$option");
                                })
                              });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton(
                        onPressed: () {
                          _submitExam();
                        },
                        child: Text("提交考卷")),
                  ),
                )
              ],
            );
          } else if (state is ExamError) {
            return Center(
              child: Text("錯誤: ${state.message}"),
            );
          } else if (state is StudentExamSubmitted) {
            final questions = widget.test.questions;
            final studentAnswers = state.studentAnswers;
            final score = state.score;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "總共: $score 分",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      questions.length,
                      (index) {
                        final isCorrect = questions[index].correctAnswer ==
                            studentAnswers[index]?.answerText;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isCorrect ? Colors.blue : Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                _currentQuestionIndex = index;
                              });
                            },
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "問題 ${_currentQuestionIndex + 1}/${questions.length}",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          questions[_currentQuestionIndex].questionText,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount:
                              questions[_currentQuestionIndex].options.length,
                          itemBuilder: (context, index) {
                            final option =
                                questions[_currentQuestionIndex].options[index];
                            final isCorrect = option ==
                                questions[_currentQuestionIndex].correctAnswer;
                            final isSelected = option ==
                                studentAnswers[_currentQuestionIndex]
                                    ?.answerText;

                            return ListTile(
                              title: Text(
                                option,
                                style: TextStyle(
                                  color: isCorrect
                                      ? Colors.blue
                                      : isSelected
                                          ? Colors.red
                                          : Colors.black,
                                  fontWeight: isSelected || isCorrect
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _currentQuestionIndex > 0
                          ? () {
                              setState(() {
                                _currentQuestionIndex--;
                              });
                            }
                          : null,
                      child: Text("上一題"),
                    ),
                    ElevatedButton(
                      onPressed: _currentQuestionIndex < questions.length - 1
                          ? () {
                              setState(() {
                                _currentQuestionIndex++;
                              });
                            }
                          : null,
                      child: Text("下一題"),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context
                            .read<ExamBloc>()
                            .add(LoadPublishedExams(widget.groupId));
                      },
                      child: Text("返回測驗列表"),
                    ),
                  ),
                ),
              ],
            );
            // return Center(
            //   child: Text(state.score.toString()),
            // );
          }
          return Center(child: Text("Error loading exam"));
        },
      ),
    );
  }
}
