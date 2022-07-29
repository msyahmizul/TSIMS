import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerHoldData =
    StateNotifierProvider<_ServiceProviderHoldData, Map<String, dynamic>>(
        (ref) => _ServiceProviderHoldData(ref: ref));

class _ServiceProviderHoldData extends StateNotifier<Map<String, dynamic>> {
  final Ref ref;

  _ServiceProviderHoldData({required this.ref}) : super({});

  storeKey(String key, String value) {
    var t = state;
    t[key] = value;
    state = t;
  }

  deleteKey(String key) {
    if (state.containsKey(key)) {
      var t = state;
      t.remove(key);
      state = t;
    }
  }
}
