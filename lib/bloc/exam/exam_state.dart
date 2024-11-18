part of 'exam_bloc.dart';

abstract class ExamState {}

class ExamInitial extends ExamState {}

class ExamLoading extends ExamState {}

class ExamLoadSuccess extends ExamState {
  final List<Test> tests;
  ExamLoadSuccess(this.tests);
}

class ExamLoaded extends ExamState {
  final List<Test> tests;
  ExamLoaded(this.tests);
}

//創建測驗狀態
class ExamCreateSuccess extends ExamState {}

class ExamSubmissionSuccess extends ExamState {
  final int score;
  final List<Question> incorrectQuestions;
  ExamSubmissionSuccess(this.score, this.incorrectQuestions);
}

class ExamResultsLoaded extends ExamState {
  final List<StudentResult> results;
  ExamResultsLoaded(this.results);
}

class ExamError extends ExamState {
  final String message;
  ExamError(this.message);
}

class ExamDeleteSuccess extends ExamState {}

class ExamQuestionsUpdated extends ExamState {
  final List<Question> questions;

  ExamQuestionsUpdated(this.questions);
}

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

//
class LoadExamByIdSuccess extends ExamState {
  final Test test;
  LoadExamByIdSuccess(this.test);
}
