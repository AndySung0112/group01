import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
part 'fileupload_event.dart';
part 'fileupload_state.dart';

class FileUploadBloc extends Bloc<FileUploadEvent, FileUploadState> {
  final ImagePicker _picker = ImagePicker();

  FileUploadBloc() : super(FileUploadInitial()) {
    on<SelectFileEvent>(_onSelectFile);
    on<UploadFileEvent>(_onUploadFile);
  }
  Future<void> _onSelectFile(
      SelectFileEvent event, Emitter<FileUploadState> emit) async {
    try {
      final XFile? file = await _picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        emit(FileUploadSelected(file: file));
      } else {
        emit(FileUploadError(message: '未選擇檔案'));
      }
    } catch (e) {
      emit(FileUploadError(message: e.toString()));
    }
  }

  Future<void> _onUploadFile(
      UploadFileEvent event, Emitter<FileUploadState> emit) async {
    try {
      //上傳邏輯
      emit(FileUploading());
      final file = event.file;
      final storageRef =
          FirebaseStorage.instance.ref().child('uploads/${file.name}');
      await storageRef.putFile(File(file.path));
      //假設上傳完成
      emit(FileUploadSuccess());
    } catch (e) {
      emit(FileUploadError(message: e.toString()));
    }
  }
}
