part of 'fileupload_bloc.dart';

abstract class FileUploadState {}

class FileUploadInitial extends FileUploadState {}

class FileUploadSelected extends FileUploadState {
  final XFile file;
  FileUploadSelected({required this.file});
}

class FileUploading extends FileUploadState {}

class FileUploadSuccess extends FileUploadState {}

class FileUploadError extends FileUploadState {
  final String message;
  FileUploadError({required this.message});
}
