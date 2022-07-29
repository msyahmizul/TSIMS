import 'package:flutter_riverpod/flutter_riverpod.dart';

final updateStatusProvider =
    StateNotifierProvider<UpdateStatusService, UpdateState>(
        (ref) => UpdateStatusService(ref));

class UpdateState {
  final String status;
  final String rejectMessage;

  UpdateState({required this.status, required this.rejectMessage});

  UpdateState.initEmpty()
      : status = "",
        rejectMessage = "";

  UpdateState.initStatus({required this.status, this.rejectMessage = ""});
}

class UpdateStatusService extends StateNotifier<UpdateState> {
  final Ref ref;

  UpdateStatusService(this.ref) : super(UpdateState.initEmpty());

  reset() {
    state = UpdateState.initEmpty();
  }

  updateStatus(String status) {}
// updateStatus(String status, String rejectMessage) {
//   state = UpdateState(status: status, rejectMessage: rejectMessage);
// }
}
