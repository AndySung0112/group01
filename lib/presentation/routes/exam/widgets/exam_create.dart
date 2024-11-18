import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:group_01/bloc/exam/exam_bloc.dart';
import 'package:group_01/model/exam/exam_model.dart';

class CreateTestPage extends StatefulWidget {
  final String groupId;
  CreateTestPage({required this.groupId});
  @override
  _CreateTestPageState createState() => _CreateTestPageState();
}

class _CreateTestPageState extends State<CreateTestPage> {
  final _titleController = TextEditingController();
  final _timeLimitController = TextEditingController();
  bool isPublished = false;
  List<Question> _questions = [];
  List<TextEditingController> _questionTextControllers = [];
  List<TextEditingController> _correctAnswerControllers = [];
  List<TextEditingController> _optionsControllers = [];
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

  // 提交測驗
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
    // 保存每個問題到陣列裡
    for (int i = 0; i < _questions.length; i++) {
      final question = _questions[i];
      // final questionText = _questionTextControllers[i].text.trim();
      // final correctAnswer = _correctAnswerControllers[i].text.trim();
      // final options =
      //     _optionsControllers[i].text.split(',').map((e) => e.trim()).toList();
      // final options = _optionsControllers[i]
      //     .text
      //     .split(',')
      //     .map((e) => e.trim())
      //     .where((option) => option.isNotEmpty)
      //     .toList();

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
        questionText: question.questionText.trim(),
        correctAnswer: question.correctAnswer.trim(),
        options: question.options,
      );
    }
    final test = Test(
      title: title,
      creatorId: 'teacher123',
      isPublished: isPublished,
      questions: _questions,
      createdAt: DateTime.now(),
      timeLimit: int.parse(timeLimit),
    );
    context.read<ExamBloc>().add(CreateExamEvent(test, widget.groupId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('創建測驗')),
      body: BlocListener<ExamBloc, ExamState>(
        listener: (context, state) {
          if (state is ExamCreateSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('測驗創建成功')));
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
                  }),
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
                      })),
              ElevatedButton(
                onPressed: _addQuestion,
                child: Text('添加問題'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _submitTest(context),
                child: Text('上傳測驗'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 問題輸入框
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
      child: Column(
        children: [
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
                icon: Icon(Icons.delete, color: Colors.red),
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
            decoration: InputDecoration(
                labelText: '選項(逗號分隔)', errorText: optionsErrorText),
            onChanged: (value) {
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
        ],
      ),
    );
  }
}
