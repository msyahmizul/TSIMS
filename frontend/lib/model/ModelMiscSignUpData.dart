import 'dart:io';

class ModelMiscSignUpData {
  final List<File> files;
  const ModelMiscSignUpData({this.files = const []});
  ModelMiscSignUpData copyWith({files}) {
    return ModelMiscSignUpData(files: files ?? this.files);
  }

  @override
  String toString() {
    return 'ModelMiscSignUpData{files: $files}';
  }
}
