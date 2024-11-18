part of 'exam_bloc.dart';

abstract class ExamEvent {}

class CreateExamEvent extends ExamEvent {
  final Test test;
  final String groupId;
  CreateExamEvent(this.test, this.groupId);
}

class LoadExamEvent extends ExamEvent {
  final String groupId;
  LoadExamEvent(this.groupId);
}

class SubmitExamEvent extends ExamEvent {
  final Test test;
  final List<Answer> answers;
  SubmitExamEvent(this.test, this.answers);
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

class AddQuestionEvent extends ExamEvent {}

// //是否讓學生看到 增加切換鍵
// class UpdateExamPublishStatus extends ExamEvent {
//   final String examId;
//   final bool isPublished;

//   UpdateExamPublishStatus({required this.examId, required this.isPublished});
// }

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
