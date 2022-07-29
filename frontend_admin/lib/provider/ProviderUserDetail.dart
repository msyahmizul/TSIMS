import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_admin/model/userDetailModel.dart';
import 'package:frontend_admin/service/ServiceAdminBackend.dart';

final userDataDetailProvider =
    StateNotifierProvider<UserDataDetailService, UserDetailModel>((ref) {
  return UserDataDetailService(ref);
});

class UserDataDetailService extends StateNotifier<UserDetailModel> {
  final Ref ref;

  UserDataDetailService(this.ref) : super(UserDetailModel());

  reset() {
    state = UserDetailModel();
  }

  Future<void> fetchData(String username, String token) async {
    var data =
        await ServiceAdminBackend.getUserDataDetailByUsername(token, username);

    state = UserDetailModel.loadData(data, username);
  }
}
