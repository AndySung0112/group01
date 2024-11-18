part of 'fileupload_bloc.dart';

abstract class FileUploadEvent {}

class SelectFileEvent extends FileUploadEvent {}

class UploadFileEvent extends FileUploadEvent {
  final XFile file;
  UploadFileEvent(this.file);
}
