import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:group_01/model/exam/exam_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'exam_event.dart';
part 'exam_state.dart';

class ExamBloc extends Bloc<ExamEvent, ExamState> {
  final FirebaseFirestore firestore;
  ExamBloc({required this.firestore}) : super(ExamInitial()) {
    on<CreateExamEvent>(_onCreateTest);
    // on<LoadExamEvent>(_onLoadTests);
    on<SubmitExamEvent>(_onSubmitExam);
    on<ViewResultsEvent>(_onViewResults);
    on<DeleteExamEvent>(_onDeleteExam);
    on<LoadAllExams>(_onLoadAll);
    on<LoadPublishedExams>(_onLoadPublished);
    on<LoadTestByIdEvent>(_onLoadById);
    on<UpdateExamEvent>(_onUpdateExam);
  }

  // 創建測驗(老師)
  Future<void> _onCreateTest(
      CreateExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      await firestore.collection('groups/${event.groupId}/tests').add({
        'title': event.test.title,
        'creatorId': event.test.creatorId,
        'isPublished': event.test.isPublished,
        'questions': event.test.questions.map((q) => q.toMap()).toList(),
        'createdAt': event.test.createdAt,
        'timeLimit': event.test.timeLimit,
      });
      emit(ExamCreateSuccess());
      add(LoadAllExams(event.groupId)); // 刷新
    } catch (e) {
      emit(ExamError('老師創建測驗失敗'));
    }
  }

  // Future<void> _onLoadTests(
  //     LoadExamEvent event, Emitter<ExamState> emit) async {
  //   emit(ExamLoading());
  //   try {
  //     final snapshot =
  //         await firestore.collection('groups/${event.groupId}/tests').get();
  //     final tests = snapshot.docs.map((doc) => Test.fromDocument(doc)).toList();
  //     emit(ExamLoadSuccess(tests));
  //   } catch (e) {
  //     emit(ExamError('加載測驗列表失敗'));
  //   }
  // }

  //老師加載測驗列表
  Future<void> _onLoadAll(LoadAllExams event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final snapshot =
          await firestore.collection('groups/${event.groupId}/tests').get();
      final tests = snapshot.docs.map((doc) => Test.fromDocument(doc)).toList();
      emit(ExamLoadSuccess(tests));
    } catch (e) {
      emit(ExamError('加載測驗列表失敗'));
    }
  }

  //學生加載測驗列表
  Future<void> _onLoadPublished(
      LoadPublishedExams event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final snapshot = await firestore
          .collection('groups/${event.groupId}/tests')
          .where('isPublished', isEqualTo: true)
          .get();
      final tests = snapshot.docs.map((doc) => Test.fromDocument(doc)).toList();
      emit(ExamLoadSuccess(tests));
    } catch (e) {
      emit(ExamError('加載測驗列表失敗'));
    }
  }

  //載入測驗內容
  Future<void> _onLoadById(
      LoadTestByIdEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final snapshot = await firestore
          .collection('groups/${event.groupId}/tests')
          .doc(event.examId)
          .get();
      if (snapshot.exists) {
        final test = Test.fromDocument(snapshot);
        emit(LoadExamByIdSuccess(test));
      }
    } catch (e) {
      emit(ExamError('載入失敗: $e'));
    }
  }

  //刪除
  Future<void> _onDeleteExam(
      DeleteExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      await firestore
          .collection('groups/${event.groupId}/tests')
          .doc(event.testId)
          .delete();
      emit(ExamDeleteSuccess());
      add(LoadAllExams(event.groupId)); //重新加載測驗列表
    } catch (e) {
      emit(ExamError('刪除失敗'));
    }
  }

  // 提交測驗(學生)
  Future<void> _onSubmitExam(
      SubmitExamEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      // 計算分數
      int score = 0;
      List<Question> incorrectQuestions = [];

      for (var i = 0; i < event.answers.length; i++) {
        if (event.answers[i].isCorrect) {
          score += event.test.questions[i].points;
        } else {
          incorrectQuestions.add(event.test.questions[i]);
        }
      }

      // 儲存分數
      await firestore.collection('test_results').add({
        'testId': event.test.title,
        'userId': 'student123', // 當前學生ID
        'score': score,
        'submittedAt': DateTime.now(),
      });

      emit(ExamSubmissionSuccess(score, incorrectQuestions));
    } catch (e) {
      emit(ExamError('提交測驗失敗'));
    }
  }

  // 查看成績
  Future<void> _onViewResults(
      ViewResultsEvent event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final snapshot = await firestore
          .collection('test_results')
          .where('testId', isEqualTo: event.testId)
          .get();

      final results =
          snapshot.docs.map((doc) => StudentResult.fromDocument(doc)).toList();
      emit(ExamResultsLoaded(results));
    } catch (e) {
      emit(ExamError('加載成績失敗'));
    }
  }

  //更新測驗
  Future<void> _onUpdateExam(
      UpdateExamEvent event, Emitter<ExamState> emit) async {
    try {
      await FirebaseFirestore.instance
          .collection('groups/${event.groupId}/tests')
          .doc(event.updatedTest.id)
          .update({
        'title': event.updatedTest.title,
        'creatorId': event.updatedTest.creatorId,
        'isPublished': event.updatedTest.isPublished,
        'questions': event.updatedTest.questions.map((q) => q.toMap()).toList(),
        'createdAt': event.updatedTest.createdAt,
        'timeLimit': event.updatedTest.timeLimit,
      });
      final snapshot =
          await firestore.collection('groups/${event.groupId}/tests').get();
      final tests = snapshot.docs.map((doc) => Test.fromDocument(doc)).toList();
      emit(UpdateExamSuccess(tests));
      add(LoadAllExams(event.groupId));
    } catch (e) {
      emit(ExamError('更新失敗: $e'));
    }
  }
}
