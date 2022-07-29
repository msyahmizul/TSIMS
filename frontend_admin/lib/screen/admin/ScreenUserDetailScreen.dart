import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_admin/model/userDetailModel.dart';
import 'package:frontend_admin/widget/WidgetGridImageView.dart';
import 'package:frontend_admin/widget/WidgetUserDetailTableWidget.dart';

import '../../Util.dart';
import '../../const.dart';
import '../../provider/ProviderListBriefData.dart';
import '../../provider/ProviderUserDetail.dart';
import '../../service/ServiceAdminBackend.dart';
import '../../widget/WidgetCenterScreenLayout.dart';
import 'ScreenAdminLogin.dart';

class ScreenUserDetail extends ConsumerStatefulWidget {
  ScreenUserDetail({Key? key, required this.username}) : super(key: key);
  final String username;
  static const path = "/user/:${ScreenUserDetail.pathArgs}";
  static const pathArgs = "id";

  static page(String userID) {
    return BeamPage(
        child: ScreenUserDetail(username: userID),
        key: ValueKey('user-$userID'));
  }

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ScreenUserDetailState();
}

class _ScreenUserDetailState extends ConsumerState<ScreenUserDetail> {
  _dropDownStatusDialog(UserDetailModel userData) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          String currentValue = userData.status;
          String rejectMessage = "";
          bool isLoading = false;
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: const Text("Change Status"),
              content: SizedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text("Status:"),
                        const SizedBox(width: 5),
                        DropdownButton(
                            value: currentValue,
                            items: choice
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (String? newVal) {
                              setState(() {
                                if (newVal != null) {
                                  currentValue = newVal;
                                }
                              });
                            })
                      ],
                    ),
                    const SizedBox(height: 5),
                    if (userData.status != choice[2] &&
                        currentValue == choice[2])
                      TextField(
                        decoration: const InputDecoration(labelText: "Reason"),
                        onChanged: (String value) {
                          rejectMessage = value;
                        },
                      )
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Cancel")),
                TextButton(
                    onPressed: userData.status == currentValue
                        ? null
                        : () {
                            var box = Util.getBox();
                            String token = box.get(HiveBox.jwtAdmin);
                            setState(() {
                              isLoading = true;
                            });
                            ServiceAdminBackend.updateUserStatus(currentValue,
                                    token, widget.username, rejectMessage)
                                .then((_) {
                              ref
                                  .read(userDataDetailProvider.notifier)
                                  .fetchData(widget.username, token);
                              ref
                                  .read(providerlistBriefData.notifier)
                                  .fetchData(token);
                              Navigator.of(context).pop();
                            }).catchError((e) {
                              Util.runSnackBarMessage(context, e.toString());
                              Navigator.of(context).pop();
                            });
                          },
                    child: isLoading
                        ? const Text("Updating...")
                        : const Text("Update")),
              ],
            );
          });
        });
  }

  final List<String> choice = ["PENDING", "APPROVE", "REJECTED"];

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userDataDetailProvider);
    if (userData.icCard.isEmpty || userData.username != widget.username) {
      var box = Util.getBox();
      String token = box.get(HiveBox.jwtAdmin);
      ref
          .read(userDataDetailProvider.notifier)
          .fetchData(widget.username, token);
    }
    return Scaffold(
      appBar: AppBar(title: const Text("TSIMS - Admin User Detail"), actions: [
        TextButton(
          onPressed: () {
            Future<void>(() async {
              var box = Util.getBox();
              await box.delete(HiveBox.jwtAdmin);
            }).then(
                (_) => context.beamToReplacementNamed(ScreenAdminLogin.path));
          },
          child: const Text(
            "Logout",
            style: TextStyle(color: Colors.white),
          ),
        )
      ]),
      body: WidgetCenterScreenLayout(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          (userData.icCard.isEmpty || userData.username != widget.username)
              ? Row(
                  children: const [
                    CircularProgressIndicator(),
                    SizedBox(width: 10),
                    Text("Fetching Data"),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "User Detail",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    WidgetUserDetailTable(userData),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text("Status: ${userData.status}",
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(width: 20),
                        userData.status != "APPROVE"
                            ? OutlinedButton(
                                onPressed: () {
                                  _dropDownStatusDialog(userData);
                                },
                                child: const Text("Change Status"))
                            : const SizedBox(),
                      ],
                    ),
                    const SizedBox(height: 2),
                    userData.status == "REJECTED"
                        ? Text("Reason: ${userData.rejectMessage}",
                            style: Theme.of(context).textTheme.titleLarge)
                        : const SizedBox(),
                    const SizedBox(height: 20),
                    Text(
                      "User Files",
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    const SizedBox(height: 10),
                    WidgetGridImageView(
                        files: userData.files, userID: widget.username)
                  ],
                ),
          const SizedBox(height: 20),
        ],
      )),
    );
  }
}
