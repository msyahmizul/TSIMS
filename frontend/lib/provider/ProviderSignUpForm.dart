import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/model/ModelUserData.dart';

final providerUserSignUp =
    StateProvider<ModelUserSignUp>((ref) => ModelUserSignUp());

class ModelUserSignUp {
  final ModelUserData userData;
  final List<File> userFile;

  ModelUserSignUp(
      {this.userData = const ModelUserData(), this.userFile = const []});

  ModelUserSignUp copyWith({ModelUserData? userData, List<File>? userFile}) {
    return ModelUserSignUp(
        userData: userData ?? this.userData,
        userFile: userFile ?? this.userFile);
  }
}
