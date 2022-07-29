import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/const.dart';
import 'package:mobile/model/ModelInitConnection.dart';
import 'package:mobile/service/ServiceAgent.dart';
import 'package:mobile/util.dart';

import '../provider/providerNotificationList.dart';
import '../provider/providerReloadData.dart';

class WidgetApproveNewConnection extends ConsumerStatefulWidget {
  final String keyNotification;
  final ModelInitConnection conData;

  const WidgetApproveNewConnection(
      {Key? key, required this.keyNotification, required this.conData})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _WidgetApproveNewConnectionState();
  }
}

class _WidgetApproveNewConnectionState
    extends ConsumerState<WidgetApproveNewConnection> {
  Future<void> approveConnection() async {
    String token = await ServiceAgentUtil.getMultiTenantAuthToken();
    await ServiceAgentConnection.receiveConnectionRequest(
        AgentURL.multiTenant,
        jsonDecode(widget.conData.invitation),
        Util.getHeader(AgentType.multi, token));
  }

  bool isLoading = false;

  Timer? timeToDelete;
  int countdown = 10;

  updateRef() {
    ref
        .read(providerNotificationList.notifier)
        .deleteKey(widget.keyNotification);
    ref
        .read(providerReloadData.notifier)
        .update((state) => {"reloadNotification": "true"});
  }

  @override
  void initState() {
    Future.delayed(const Duration(seconds: 3)).then((_) {
      timeToDelete = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (countdown != 0) {
          if (mounted) {
            setState(() {
              countdown -= 1;
            });
          }
          return;
        }
        updateRef();
        timer.cancel();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    if (timeToDelete != null) {
      timeToDelete!.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("New Connection Request"),
      leading: Text("${countdown}s"),
      trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(primary: Colors.green),
          onPressed: () {
            if (timeToDelete != null) {
              timeToDelete!.cancel();
            }
            setState(() {
              isLoading = true;
            });
            approveConnection().then((value) {
              updateRef();
              setState(() {
                isLoading = false;
              });
            }).catchError((e) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(e.toString())));
              Future.delayed(const Duration(seconds: 5)).then((_) {
                updateRef();
              });
              setState(() {
                isLoading = false;
              });
            });
          },
          child: isLoading
              ? const CircularProgressIndicator()
              : const Text("Approve")),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Origin: ${widget.conData.agentName}"),
        ],
      ),
    );
  }
}
