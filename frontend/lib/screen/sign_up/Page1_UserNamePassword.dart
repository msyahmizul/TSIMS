import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mobile/provider/ProviderSignUpForm.dart';
import 'package:mobile/screen/sign_up/Page2_SignUpProfile.dart';
import 'package:mobile/service/ServiceUserSignUp.dart';

import '../../Widget/WidgetTextInput.dart';
import '../../const.dart';
import 'ButtonNext.dart';
import 'Steps.dart';

class Page1_UserNamePassword extends ConsumerWidget {
  Page1_UserNamePassword({Key? key}) : super(key: key);
  static const path = "/signup/1";

  static page() {
    return BeamPage(
        child: Page1_UserNamePassword(), key: const ValueKey("signup-1"));
  }

  final formKey = GlobalKey<FormState>();

  final int passwordMinCount = 8 - 1;
  bool isLoading = false;
  String username = "";
  String password = "";

  String? validatePasswordSame(String? value) {
    if (value != null) {
      if (value.length <= passwordMinCount) {
        return "Password minimum of 8 Char";
      }
      if (password.isEmpty) {
        return "Value is required";
      }
      if (password != value) {
        return "Password must be same";
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
            child: StatefulBuilder(
              builder: (ctx, setState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    Text(
                      "Now Let's Create an Account",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    const SizedBox(height: 20),
                    Form(
                        key: formKey,
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            const SizedBox(height: 20),
                            WidgetTextInput(
                              onSaved: (String? value) {
                                username = value!.trim();
                              },
                              initialValue: username,
                              labelText: 'Username',
                              validate: Validator.username,
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              onChanged: (String? value) {
                                if (value != null) {
                                  password = value.trim();
                                }
                              },
                              onSaved: (String? value) {},
                              initialValue: password,
                              validator: (String? value) {
                                if (value != null) {
                                  if (value.isEmpty) {
                                    return "Password Not Empty";
                                  }
                                  if (value.length <= passwordMinCount) {
                                    return "Password minimum of 8 Char";
                                  }
                                }
                                return null;
                              },
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Password",
                                border: UnderlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              onSaved: (String? value) {},
                              initialValue: password,
                              validator: validatePasswordSame,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: "Reconfirm Password",
                                border: UnderlineInputBorder(),
                              ),
                            )
                          ],
                        )),
                    const SizedBox(height: 20),
                    ButtonNext(
                        textButton: "SignUp",
                        onPressed: () {
                          final curState = formKey.currentState;
                          if (curState == null) {
                            return;
                          }
                          if (!curState.validate()) {
                            return;
                          }
                          setState(() {
                            isLoading = true;
                          });
                          curState.save();

                          ServiceUserSignUp.signUpUser(username, password)
                              .catchError((e) {
                            setState(() {
                              isLoading = false;
                            });
                            ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(e.toString())));
                            return "";
                          }).then((String value) {
                            if (value.isEmpty) {
                              return "";
                            }
                            setState(() {
                              isLoading = false;
                            });
                            var box = Hive.box(BoxName.name);
                            box.put(BoxName.jwtKey, value);
                            ref.read(providerUserSignUp.notifier).update(
                                (state) => state.copyWith(
                                    userData: state.userData
                                        .copyWith(username: username)));
                            ctx.beamToReplacementNamed(
                                Page2_SignUpProfile.path);
                            return value;
                          });
                        }),
                    const SizedBox(height: 20),
                    isLoading
                        ? const Align(
                            alignment: Alignment.center,
                            child: CircularProgressIndicator())
                        : const SizedBox(),
                    const SizedBox(height: 50),
                    const Steps(step: 1, stepLength: 3),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
    ;
  }
}
