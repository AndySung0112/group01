import 'dart:async';
// import 'dart:math';

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
    on<ViewResultsEvent>(_onViewResults);
    on<DeleteExamEvent>(_onDeleteExam);
    on<LoadAllExams>(_onLoadAll);
    on<LoadPublishedExams>(_onLoadPublished);
    on<LoadTestByIdEvent>(_onLoadById);
    on<UpdateExamEvent>(_onUpdateExam);

    on<StudentStartExam>(_onStudentStartExam);
    on<StudentSubmitExam>(_onStudentSubmitExam);
    on<StudentExitExam>(_onStudentExitExam);
    on<LoadCompletedExams>(_onLoadCompletedExams);
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
      print("LoadPubExamSuccess");
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

  //學生開始做達
  Future<void> _onStudentStartExam(
      StudentStartExam event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      final snapshot = await firestore
          .collection('groups/${event.groupId}/tests')
          .doc(event.examId)
          .get();
      if (snapshot.exists) {
        final test = Test.fromDocument(snapshot);
        emit(StudentExamStarted(test: test));
      } else if (!snapshot.exists) {
        throw Exception("測試文檔不存在");
      }
    } catch (e) {
      emit(ExamError('開始測驗失敗: $e'));
    }
  }

  //學生提交測驗
  Future<void> _onStudentSubmitExam(
      StudentSubmitExam event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      int score = 0;
      final snapshot = await firestore
          .collection('groups/${event.groupId}/tests')
          .doc(event.examId)
          .get();
      final test = Test.fromDocument(snapshot);
      if (snapshot.exists) {
        //計算分數
        for (var i = 0; i < test.questions.length; i++) {
          final question = test.questions[i];
          final studentAnswer = event.studentAnswers[i];
          if (studentAnswer != null) {
            if (question.correctAnswer == studentAnswer.answerText) {
              score += question.points;
              studentAnswer.isCorrect = true;
            } else {
              studentAnswer.isCorrect = false;
            }
          }
        }
      }
      //保存結果
      await firestore
          .collection(
              'groups/${event.groupId}/tests/${event.examId}/test_results')
          .doc('${event.userId}_${event.examId}') // 設置唯一ID
          .set({
        'testId': event.examId,
        'userId': event.userId,
        'score': score,
        'answers': event.studentAnswers.map((index, answer) => MapEntry(
              index.toString(),
              {
                'answerText': answer.answerText,
                'isCorrect': answer.isCorrect,
                'answeredAt': answer.answeredAt.toIso8601String(),
              },
            )),
        'submittedAt': DateTime.now().toIso8601String(),
      });
      emit(StudentExamSubmitted(score, event.studentAnswers));
      print("提交測驗成功");
    } catch (e) {
      emit(ExamError('提交測驗失敗:$e'));
    }
  }

//載入已完成測驗
  Future<void> _onLoadCompletedExams(
      LoadCompletedExams event, Emitter<ExamState> emit) async {
    emit(ExamLoading());
    try {
      //獲取所有測驗
      final snapshot =
          await firestore.collection('groups/${event.groupId}/tests').get();
      final exams = snapshot.docs.map((doc) => Test.fromDocument(doc)).toList();
      //學生是否完成各個測驗
      final completed = <String, bool>{};
      for (var exam in exams) {
        final docId = "${event.userId}_${exam.id}";
        final doc = await firestore
            .collection('groups/${event.groupId}/tests/${exam.id}/test_results')
            .doc(docId)
            .get();
        completed[exam.id] = doc.exists;
      }
      emit(ExamListLoaded(test: exams, completionStatus: completed));
    } catch (e) {
      emit(ExamError("無法加載測驗列表"));
    }
  }

  //學生中途離開
  void _onStudentExitExam(StudentExitExam event, Emitter<ExamState> emit) {}
}
