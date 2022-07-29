import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend_admin/const.dart';
import 'package:frontend_admin/provider/ProviderListBriefData.dart';
import 'package:frontend_admin/screen/admin/ScreenAdminLogin.dart';

import '../../Util.dart';
import '../../model/brief_data_model.dart';
import '../../provider/ProviderUserDetail.dart';
import '../../widget/WidgetCenterScreenLayout.dart';

class ScreenUserListBrief extends ConsumerStatefulWidget {
  static const path = "/user";
  static const page =
      BeamPage(child: ScreenUserListBrief(), key: ValueKey("user-list"));

  const ScreenUserListBrief({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ScreenUserListBriefState();
}

class _ScreenUserListBriefState extends ConsumerState<ScreenUserListBrief> {
  bool isLoading = true;
  List<BriefDataModel> userBriefData = [];

  Future<void> initData() async {
    var box = Util.getBox();
    String token = box.get(HiveBox.jwtAdmin);
    await ref.read(providerlistBriefData.notifier).fetchData(token);
    var data = ref.read(providerlistBriefData);

    setState(() {
      userBriefData = data;
      isLoading = false;
    });
  }

  @override
  void initState() {
    initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final userBriefData = ref.watch(listBriefDataProvider);
    // if (userBriefData.isEmpty) {
    //   var box = Util.getBox();
    //   String token = box.get(HiveBox.jwtAdmin);
    //   setState((){
    //     isLoading = true;
    //   });
    //   ref.read(listBriefDataProvider.notifier).fetchData(token).then((_) {
    //     setState((){
    //       isLoading = false;
    //     });
    //   }).catchError((e) {
    //     Util.runSnackBarMessage(context, e.toString());
    //   });
    // }

    return Scaffold(
      appBar: AppBar(
        title: const Text("TSIMS - Admin User Brief List "),
        actions: [
          TextButton(
            onPressed: () {
              Future<void>(() async {
                var box = Util.getBox();
                await box.delete(HiveBox.jwtAdmin);
              }).then(
                  (_) => context.beamToReplacementNamed(ScreenAdminLogin.path));
            },
            child: Text(
              "Logout",
              style: TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
      body: WidgetCenterScreenLayout(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("User List", style: Theme.of(context).textTheme.headline3),
            SizedBox(
              width: double.infinity,
              child: DataTable(
                  columns: const [
                    DataColumn(label: Text("Name")),
                    DataColumn(label: Text("User ID")),
                    DataColumn(label: Text("Status")),
                    DataColumn(label: Text("Action")),
                  ],
                  rows: userBriefData
                      .map((model) => DataRow(cells: [
                            DataCell(Text(model.name)),
                            DataCell(Text(model.username)),
                            DataCell(Text(model.applicantStatus)),
                            DataCell(IconButton(
                              icon: const Icon(Icons.keyboard_arrow_right),
                              tooltip: "View More",
                              onPressed: () {
                                ref
                                    .read(userDataDetailProvider.notifier)
                                    .reset();
                                Beamer.of(context)
                                    .beamToNamed("/user/${model.username}");
                              },
                            )),
                          ]))
                      .toList()),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const SizedBox()
                : ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      initData();
                    },
                    icon: Icon(Icons.refresh),
                    label: Text("Reload")),
            const SizedBox(height: 20),
            isLoading
                ? const Align(
                    child: CircularProgressIndicator(),
                    alignment: Alignment.center,
                  )
                : const SizedBox(),
          ],
        ),
      )),
    );
  }
}
