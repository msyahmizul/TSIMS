import 'package:flutter_riverpod/flutter_riverpod.dart';

final loadingProvider = StateProvider<bool>((ref) => false);

class FetchProvider {
  bool isLoading = false;
  String errorMessage = "";

  bool get hasError => errorMessage.isNotEmpty;
}
