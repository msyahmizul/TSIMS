import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:frontend_admin/const.dart';
import 'package:frontend_admin/screen/admin/ScreenUserListBriefScreen.dart';
import 'package:frontend_admin/service/ServiceAdminBackend.dart';
import 'package:jwt_decode/jwt_decode.dart';

import '../../Util.dart';

class ScreenAdminLogin extends StatefulWidget {
  static const path = "/user/login";
  static const page =
      BeamPage(child: ScreenAdminLogin(), key: ValueKey("admin-login"));

  const ScreenAdminLogin({super.key});

  @override
  State<ScreenAdminLogin> createState() => _ScreenAdminLoginState();
}

class _ScreenAdminLoginState extends State<ScreenAdminLogin> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> loginUser() async {
    var resp = await ServiceAdminBackend.loginUser(username, password);
    if (resp.containsKey("error")) {
      setState(() {
        errorMessage = resp["error"]!;
        isLoading = false;
      });
      return;
    }

    Map<String, dynamic> userMetaData = Jwt.parseJwt(resp["data"]!);

    if (userMetaData["UserType"] != "ADMIN") {
      setState(() {
        errorMessage = "User is not admin";
        isLoading = false;
      });
      return;
    }
    setState(() {
      isLoading = false;
    });
    var box = Util.getBox();
    await box.put(HiveBox.jwtAdmin, resp["data"]!);
  }

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;
  String errorMessage = "";

  String username = "";
  String password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TSIMS"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("TSIMS Admin Login",
                style: Theme.of(context).textTheme.headline4),
            SizedBox(height: 10),
            Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 300,
                    child: TextFormField(
                      onSaved: (String? value) {
                        username = value!;
                      },
                      validator: (String? value) {
                        if (value != null) {
                          if (value.isEmpty) {
                            return "Username is Required";
                          }
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Username',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 300,
                    child: TextFormField(
                      obscureText: true,
                      onSaved: (String? value) {
                        password = value!;
                      },
                      validator: (String? value) {
                        if (value != null) {
                          if (value.isEmpty) {
                            return "Password is Required";
                          }
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            isLoading ? CircularProgressIndicator() : const SizedBox(),
            const SizedBox(height: 10),
            errorMessage.isNotEmpty ? Text(errorMessage) : const SizedBox(),
            const SizedBox(height: 10),
            OutlinedButton(
                onPressed: () {
                  final curState = formKey.currentState;
                  if (curState == null || !curState.validate()) {
                    return;
                  }
                  curState.save();
                  setState(() {
                    isLoading = true;
                    errorMessage = "";
                  });
                  loginUser()
                      .then((_) => context
                          .beamToReplacementNamed(ScreenUserListBrief.path))
                      .catchError((e) {
                    Util.runSnackBarMessage(context, e.toString());
                    setState(() {
                      isLoading = false;
                    });
                  });
                },
                child: Text("Login")),
          ],
        ),
      ),
    );
  }
}
