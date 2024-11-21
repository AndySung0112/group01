part of 'exam_bloc.dart';

abstract class ExamState {}

class ExamInitial extends ExamState {}

class ExamLoading extends ExamState {}

class ExamLoadSuccess extends ExamState {
  final List<Test> tests;
  ExamLoadSuccess(this.tests);
}

//創建測驗狀態
class ExamCreateSuccess extends ExamState {}

class ExamResultsLoaded extends ExamState {
  final List<StudentResult> results;
  ExamResultsLoaded(this.results);
}

class ExamError extends ExamState {
  final String message;
  ExamError(this.message);
}

class ExamDeleteSuccess extends ExamState {}

//publish狀態
class ExamPublishStatusUpdated extends ExamState {
  final bool isPublished;

  ExamPublishStatusUpdated(this.isPublished);
}

//更新測驗狀態
class UpdateExamSuccess extends ExamState {
  final List<Test> tests;
  UpdateExamSuccess(this.tests);
}

//透過測驗ID載入問題
class LoadExamByIdSuccess extends ExamState {
  final Test test;
  LoadExamByIdSuccess(this.test);
}

// 紀錄完成與未完成學生
class ExamCompletionLoaded extends ExamState {
  final List<String> completedMembers; // 已完成
  final List<String> incompleteMembers; // 未完成

  ExamCompletionLoaded({
    required this.completedMembers,
    required this.incompleteMembers,
  });
}

//分辨完成未完成
class ExamListLoaded extends ExamState {
  final List<Test> test; // 测验列表
  final Map<String, bool> completionStatus;

  ExamListLoaded({
    required this.test,
    required this.completionStatus,
  });
}

//學生開始測驗
class StudentExamStarted extends ExamState {
  final Test test;
  StudentExamStarted({required this.test});
}

//學生提交測驗
class StudentExamSubmitted extends ExamState {
  final int score;
  Map<int, Answer> studentAnswers;
  StudentExamSubmitted(this.score, this.studentAnswers);
}
