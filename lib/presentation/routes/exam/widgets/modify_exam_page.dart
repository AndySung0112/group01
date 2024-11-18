import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_01/bloc/exam/exam_bloc.dart';
import 'package:group_01/model/exam/exam_model.dart';

class ModifyExamPage extends StatefulWidget {
  final String examId;
  final String groupId;
  ModifyExamPage({required this.examId, required this.groupId});

  @override
  _ModifyExamPageState createState() => _ModifyExamPageState();
}

class _ModifyExamPageState extends State<ModifyExamPage> {
  late TextEditingController _titleController;
  late TextEditingController _timeLimitController;
  bool isPublished = false;
  List<Question> _questions = [];
  List<TextEditingController> _questionTextControllers = [];
  List<TextEditingController> _correctAnswerControllers = [];
  List<TextEditingController> _optionsControllers = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _timeLimitController = TextEditingController();
    _initializeControllers(); // 初始化控制器

    // _loadTest();
  }

  void _initializeControllers() {
    for (var question in _questions) {
      _optionsControllers.add(
        TextEditingController(text: question.options.join(',')),
      );
    }
  }
  // void _loadTest() async {
  //   context
  //       .read<ExamBloc>()
  //       .add(LoadTestByIdEvent(widget.examId, widget.groupId));
  // }

  @override
  void dispose() {
    _titleController.dispose();
    _timeLimitController.dispose();
    for (var controller in _questionTextControllers) {
      controller.dispose();
    }
    for (var controller in _correctAnswerControllers) {
      controller.dispose();
    }
    for (var controller in _optionsControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // 新增問題
  void _addQuestion() {
    setState(() {
      _questions.add(Question(
        questionText: '',
        options: [],
        correctAnswer: '',
        isMultipleChoice: true,
      ));
      _questionTextControllers.add(TextEditingController());
      _correctAnswerControllers.add(TextEditingController());
      _optionsControllers.add(TextEditingController());
    });
  }

  // 提交修改后的测验
  void _submitTest(BuildContext context) {
    final title = _titleController.text.trim();
    final timeLimit = _timeLimitController.text.trim();
    // 檢查空白內容
    // 檢查標題和時間限制
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("測驗標題不能為空")),
      );
      return;
    }

    if (timeLimit.isEmpty || int.tryParse(timeLimit) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("時間限制必須為有效數字")),
      );
      return;
    }

    for (int i = 0; i < _questions.length; i++) {
      // final questionText = _questionTextControllers[i].text.trim();
      // final correctAnswer = _correctAnswerControllers[i].text.trim();
      // final options =
      //     _optionsControllers[i].text.split(',').map((e) => e.trim()).toList();
      final question = _questions[i];
      if (question.questionText.trim().isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("第 ${i + 1} 題的內容不能為空")));
        return;
      }
      if (question.correctAnswer.trim().isEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("第 ${i + 1} 題的正確答案不能為空")));
        return;
      }
      // if (questionText.isEmpty) {
      //   ScaffoldMessenger.of(context)
      //       .showSnackBar(SnackBar(content: Text("第 ${i + 1} 題的內容不能為空")));
      //   return;
      // }
      // if (correctAnswer.isEmpty) {
      //   ScaffoldMessenger.of(context)
      //       .showSnackBar(SnackBar(content: Text("第 ${i + 1} 題的正確答案不能為空")));
      //   return;
      // }
      // if (options.isEmpty || options.length < 2) {
      //   ScaffoldMessenger.of(context)
      //       .showSnackBar(SnackBar(content: Text("第 ${i + 1} 題的選項必須至少有兩個")));
      //   return;
      // }
      if (question.options.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("第 ${i + 1} 題的選項不可為空")),
        );
        return;
      }
      if (question.options.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("第 ${i + 1} 題的選項必須至少有兩個有效項目")),
        );
        return;
      }
      _questions[i] = _questions[i].copyWith(
        // questionText: _questionTextControllers[i].text,
        // correctAnswer: _correctAnswerControllers[i].text,
        questionText: question.questionText.trim(),
        correctAnswer: question.correctAnswer.trim(),
        options: question.options,
      );
    }
    // //過濾空題目
    // final filterQuestions = _questions.where((q) {
    //   return q.questionText.isNotEmpty && q.correctAnswer.isNotEmpty;
    // }).toList();
    // if (filterQuestions.isEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text("請填寫問題內容和正確答案")),
    //   );
    //   return;
    // }
    final test = Test(
      title: title,
      id: widget.examId,
      creatorId: 'teacher123',
      isPublished: isPublished,
      questions: _questions,
      createdAt: DateTime.now(),
      timeLimit: int.parse(timeLimit),
    );
    context.read<ExamBloc>().add(UpdateExamEvent(test, widget.groupId)); // 更新测验
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('修改測驗'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // 返回上一页
            context.read<ExamBloc>().add(LoadAllExams(widget.groupId));
          },
        ),
      ),
      body: BlocListener<ExamBloc, ExamState>(
        listener: (context, state) {
          if (state is LoadExamByIdSuccess) {
            //初始化數據
            final test = state.test;
            setState(() {
              isPublished = test.isPublished;
              _titleController = TextEditingController(text: test.title);
              _timeLimitController =
                  TextEditingController(text: test.timeLimit.toString());
              _questions = test.questions;

              _questionTextControllers = test.questions
                  .map((q) => TextEditingController(text: q.questionText))
                  .toList();
              _correctAnswerControllers = test.questions
                  .map((q) => TextEditingController(text: q.correctAnswer))
                  .toList();
              _optionsControllers = test.questions
                  .map((q) => TextEditingController(text: q.options.join(',')))
                  .toList();
            });
          } else if (state is UpdateExamSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('測驗修改成功')));
            Navigator.pop(context);
          } else if (state is ExamError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text("是否發布"),
                value: isPublished,
                onChanged: (value) {
                  setState(() {
                    isPublished = value;
                  });
                },
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: '測驗標題'),
              ),
              TextField(
                controller: _timeLimitController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: '時間限制(分鐘)'),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _questions.length,
                  itemBuilder: (context, index) {
                    return _buildQuestionField(index);
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _addQuestion();
                },
                child: Text('添加問題'),
              ),
              ElevatedButton(
                onPressed: () {
                  _submitTest(context);
                  // Navigator.pop(context);
                },
                child: Text('更新測驗'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionField(int index) {
    final question = _questions[index];
    final options = question.options;
    final validOptionsCount =
        options.where((option) => option.trim().isNotEmpty).length; // 過濾空白選項
    bool isQuestionEmpty = _questionTextControllers[index].text.trim().isEmpty;
    bool isCorrectAnswerEmpty =
        _correctAnswerControllers[index].text.trim().isEmpty;
    String? optionsErrorText;

    if (validOptionsCount < 2) {
      optionsErrorText = '選項必須至少有兩個';
    }
    return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(children: [
          Text("題目 ${index + 1}",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextField(
                  controller: _questionTextControllers[index],
                  decoration: InputDecoration(
                      labelText: '問題內容',
                      errorText: isQuestionEmpty ? '內容不可為空' : null),
                  onChanged: (value) {
                    setState(() {
                      _questions[index] = _questions[index]
                          .copyWith(questionText: value.trim());
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () {
                  setState(() {
                    _questions.removeAt(index);
                    _questionTextControllers.removeAt(index);
                    _correctAnswerControllers.removeAt(index);
                    _optionsControllers.removeAt(index);
                  });
                },
              ),
            ],
          ),
          TextField(
            controller: _correctAnswerControllers[index],
            decoration: InputDecoration(
                labelText: '正確答案',
                errorText: isCorrectAnswerEmpty ? '答案不可為空' : null),
            onChanged: (value) {
              setState(() {
                _questions[index] =
                    _questions[index].copyWith(correctAnswer: value.trim());
              });
            },
          ),
          TextField(
            controller: _optionsControllers[index],
            decoration: InputDecoration(
                labelText: '選項(逗號分隔)', errorText: optionsErrorText),
            onChanged: (value) {
              // setState(() {
              //   _questions[index] = question.copyWith(
              //     options: value.split(',').map((e) => e.trim()).toList(),
              //   );
              // });
              setState(() {
                _questions[index] = _questions[index].copyWith(
                  options: value
                      .split(',')
                      .map((e) => e.trim())
                      .where((option) => option.isNotEmpty)
                      .toList(),
                );
              });
            },
          ),
          SwitchListTile(
            title: Text('是否為選擇題'),
            value: question.isMultipleChoice,
            onChanged: (value) {
              setState(() {
                _questions[index] = question.copyWith(isMultipleChoice: value);
              });
            },
          ),
          Divider(
            color: Colors.yellow,
          ), // 分隔線
        ]));
  }
}
