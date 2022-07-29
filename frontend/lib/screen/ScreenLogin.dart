import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mobile/screen/sign_up/Page1_UserNamePassword.dart';
import 'package:mobile/service/ServiceUser.dart';
import 'package:mobile/util.dart';

import '../const.dart';
import '../model/ModelWallet.dart';
import 'ScreenHome.dart';

class ScreenLogin extends StatefulWidget {
  static const path = "/login";

  static page() {
    return BeamPage(child: ScreenLogin(), key: const ValueKey("login"));
  }

  ScreenLogin({Key? key}) : super(key: key);

  @override
  State<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {
  bool isLoading = false;
  final formKey = GlobalKey<FormState>();

  Future<void> loginUser(String username, password) async {
    String jwtToken = await ServiceUser.signInUser(username, password);
    var box = Hive.box(BoxName.name);
    await box.put(BoxName.jwtKey, jwtToken);
    var userData = await ServiceUser.getUserData(jwtToken);
    await box.put(BoxName.userData, jsonEncode(userData));

    String wallet = await box.get(BoxName.walletData, defaultValue: "");
    if (wallet.isEmpty) {
      var data = await ServiceUser.getUser(jwtToken);
      if ((data["walletID"] as String).isNotEmpty &&
          (data["walletID"] as String).isNotEmpty) {
        await box.put(
            BoxName.walletData,
            jsonEncode(ModelWallet(wallet: data["walletID"], did: data["did"])
                .toJson()));
      }
    }
  }

  String username = "";
  String password = "";

  WidgetTextInputValidateFunction validateNotEmpty = (String? value) {
    if (value != null) {
      if (value.isEmpty) {
        return "Value is required";
      }
    }
    return null;
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 75),
                const _Header(),
                const SizedBox(height: 20),
                Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'johndoe',
                            border: const UnderlineInputBorder(),
                          ),
                          validator: Validator.username,
                          onSaved: (String? value) {
                            username = value!;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          validator: validateNotEmpty,
                          onSaved: (String? value) {
                            password = value!;
                          },
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: '12345678',
                            border: const UnderlineInputBorder(),
                          ),
                        ),
                      ],
                    )),
                const SizedBox(height: 20),
                _Button(
                  text: 'Login',
                  onPressed: () {
                    final curState = formKey.currentState;
                    if (curState == null || !curState.validate()) {
                      return;
                    }
                    setState(() {
                      isLoading = true;
                    });
                    curState.save();
                    loginUser(username, password).then((_) {
                      setState(() {
                        isLoading = false;
                      });
                      context.beamToReplacementNamed(ScreenHome.path);
                    }).catchError((e) {
                      setState(() {
                        isLoading = false;
                      });
                      Util.runSnackBarMessage(context, e.toString());
                    });
                  },
                ),
                const SizedBox(height: 5),
                isLoading
                    ? Align(
                        child: const CircularProgressIndicator(),
                        alignment: Alignment.center)
                    : const SizedBox(),
                Container(
                  padding: const EdgeInsets.only(top: 24, bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 64, height: 1, color: Color(0xffBFBFBF)),
                      Container(padding: EdgeInsets.all(8), child: Text('or')),
                      Container(width: 64, height: 1, color: Color(0xffBFBFBF)),
                    ],
                  ),
                ),
                _Button(
                  text: 'Sign Up',
                  onPressed: () {
                    context.beamToNamed(Page1_UserNamePassword.path);
                  },
                ),
                const SizedBox(height: 64, width: double.infinity),
                const Text('Powered By Hyperledger Indy Blockchain'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          "Jiro Inc",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        Text(
          "GovID",
          style: TextStyle(
            color: Colors.black,
            fontSize: 56,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _TextInput extends StatelessWidget {
  final String labelText;
  final String hintText;

  const _TextInput({
    Key? key,
    required this.labelText,
    required this.hintText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: const UnderlineInputBorder(),
      ),
    );
  }
}

class _Button extends StatelessWidget {
  final String text;
  final Function onPressed;

  const _Button({
    Key? key,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => onPressed(),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.only(
            top: 18,
            bottom: 18,
            left: 24,
            right: 24,
          ),
        ),
        child: Text(text, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}
