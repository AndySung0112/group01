part of 'exam_bloc.dart';

abstract class ExamEvent {}

class CreateExamEvent extends ExamEvent {
  final Test test;
  final String groupId;
  CreateExamEvent(this.test, this.groupId);
}

class ViewResultsEvent extends ExamEvent {
  final String testId;
  ViewResultsEvent(this.testId);
}

class DeleteExamEvent extends ExamEvent {
  final String testId;
  final String groupId;
  DeleteExamEvent(this.testId, this.groupId);
}

//老師顯示測驗
class LoadAllExams extends ExamEvent {
  final String groupId;
  LoadAllExams(this.groupId);
}

//學生顯示測驗
class LoadPublishedExams extends ExamEvent {
  final String groupId;
  LoadPublishedExams(this.groupId);
}

//學生顯示測驗
class LoadCompletedExams extends ExamEvent {
  final String groupId;
  final String userId;
  LoadCompletedExams(this.groupId, this.userId);
}

//載入測驗問題
class LoadTestByIdEvent extends ExamEvent {
  final String groupId;
  final String examId;
  LoadTestByIdEvent(this.examId, this.groupId);
}

//更希測驗
class UpdateExamEvent extends ExamEvent {
  final String groupId;
  final Test updatedTest;
  UpdateExamEvent(this.updatedTest, this.groupId);
}

//學生開始做達
class StudentStartExam extends ExamEvent {
  final String groupId;
  final String examId;
  final String userId;
  // final Test test; //包含question和timelimit
  StudentStartExam(this.groupId, this.examId, this.userId);
}

//學生提交測驗
class StudentSubmitExam extends ExamEvent {
  final String groupId;
  final String examId;
  final String userId;
  Map<int, Answer> studentAnswers = {};
  StudentSubmitExam(
      {required this.groupId,
      required this.examId,
      required this.userId,
      required this.studentAnswers});
}

//學生中途離開
class StudentExitExam extends ExamEvent {}
