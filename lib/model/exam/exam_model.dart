import 'package:cloud_firestore/cloud_firestore.dart';

class Question {
  final String questionText; // 問題內容
  final List<String> options; // 選項
  final String correctAnswer; // 正確答案
  final bool isMultipleChoice; // 是否為選擇題
  final int points;

  Question({
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.isMultipleChoice = true,
    this.points = 1,
  });
  //轉換成MAP上傳到firebase
  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'options': options,
      'correctAnswer': correctAnswer,
      'isMultipleChoice': isMultipleChoice,
      'points': points,
    };
  }

  Question copyWith({
    String? questionText,
    List<String>? options,
    String? correctAnswer,
    bool? isMultipleChoice,
    int? points,
  }) {
    return Question(
      questionText: questionText ?? this.questionText,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      isMultipleChoice: isMultipleChoice ?? this.isMultipleChoice,
      points: points ?? this.points,
    );
  }

  //從firebase文檔創建Test實例
  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      questionText: map['questionText'],
      options: List<String>.from(map['options']),
      correctAnswer: map['correctAnswer'],
      isMultipleChoice: map['isMultipleChoice'] ?? true,
      points: map['points'] ?? 1,
    );
  }
}

class StudentResult {
  final String userId;
  final int score;

  StudentResult({required this.userId, required this.score});

  factory StudentResult.fromDocument(DocumentSnapshot doc) {
    return StudentResult(
      userId: doc['userId'],
      score: doc['score'],
    );
  }
}

class Answer {
  String answerText;
  bool isCorrect;
  final DateTime answeredAt;

  Answer(
      {required this.answerText, this.isCorrect = true, DateTime? answeredAt})
      : answeredAt = answeredAt ?? DateTime.now();
}

class Test {
  final String id;
  final String title; // 測驗標題
  final String creatorId; // 創建者ID
  final List<Question> questions; // 問題列表
  final DateTime createdAt; // 創建時間
  final int timeLimit; // 時間限制
  final bool isPublished;

  Test({
    this.id = '',
    required this.title,
    required this.creatorId,
    required this.questions,
    required this.createdAt,
    this.timeLimit = 0,
    required this.isPublished,
  });

  //轉換成Map上傳到firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'creatorId': creatorId,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'timeLimit': timeLimit,
      'isPublished': isPublished,
    };
  }

  //從firebase文檔創建Test實例
  factory Test.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Test(
      id: doc.id,
      title: data['title'],
      creatorId: data['creatorId'],
      questions:
          (data['questions'] as List).map((q) => Question.fromMap(q)).toList(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      timeLimit: data['timeLimit'],
      isPublished: data['isPublished'] ?? false,
    );
  }
}

class TestResult {
  final String testId; //測驗id
  final String studentId; //學生ID
  final List<Answer> answers; //學生的答案
  final int score; //分數
  final bool isCompleted; //是否完成測驗
  final DateTime? submissionTime;

  TestResult({
    required this.testId,
    required this.studentId,
    required this.answers,
    this.score = 0,
    this.isCompleted = false,
    this.submissionTime,
  });
  //轉換成map上傳firebase
  Map<String, dynamic> toMap() {
    return {
      'testId': testId,
      'studentId': studentId,
      // 'answers': answers
      //     .map((answer) =>
      //         {'answerText': answer.answerText, 'isCorrect': answer.isCorrect})
      //     .toList(),
      'answers': answers
          .asMap()
          .entries
          .map((entry) => {
                'questionIndex': entry.key,
                'answerText': entry.value.answerText,
                'isCorrect': entry.value.isCorrect,
              })
          .toList(),
      'score': score,
      'isCompleted': isCompleted,
      'submissionTime': submissionTime?.toIso8601String(),
    };
  }

  //從Firebase創建testresult
  factory TestResult.fromMap(Map<String, dynamic> map) {
    return TestResult(
      testId: map['testId'],
      studentId: map['studentId'],
      answers: (map['answers'] as List)
          .map((a) =>
              Answer(answerText: a['answerText'], isCorrect: a['isCorrect']))
          .toList(),
      score: map['score'] ?? 0,
      isCompleted: map['isCompleted'] ?? false,
      submissionTime: map['submissionTime'] != null
          ? DateTime.parse(map['submissionTime'])
          : null,
    );
  }
}
