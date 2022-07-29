import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerAgentConnection =
    StateNotifierProvider<_ServiceAgentConnection, Map<String, String>>(
        (ref) => _ServiceAgentConnection(ref));

class _ServiceAgentConnection extends StateNotifier<Map<String, String>> {
  final Ref ref;

  _ServiceAgentConnection(this.ref) : super({});

  addConnection(String agentType, String connectionID) {
    var t = state;
    t[agentType] = connectionID;
    state = t;
  }

  String? getConnection(String agentType) {
    if (state.containsKey(agentType)) {
      return state[agentType];
    }
    return null;
  }

  deleteConnection(String agentType) {
    var t = state;
    t.remove(agentType);
    state = t;
  }
}
