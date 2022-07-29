import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/Widget/WidgetTextInput.dart';
import 'package:mobile/const.dart';
import 'package:mobile/provider/ProviderSignUpForm.dart';
import 'package:mobile/util.dart';

import './ButtonNext.dart';
import 'Page3_SignUpVerify.dart';
import 'Steps.dart';

class Page2_SignUpProfile extends ConsumerStatefulWidget {
  static const path = "/signup/2";

  static page() {
    return const BeamPage(
        child: Page2_SignUpProfile(), key: ValueKey("signup-2"));
  }

  const Page2_SignUpProfile({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _Page2_SignUpProfileState();
}

class _Page2_SignUpProfileState extends ConsumerState<Page2_SignUpProfile> {
  static List<_Gender> gender = [
    _Genders.nothing,
    _Genders.male,
    _Genders.female,
  ];
  _Gender currentGender = gender.first;

  final formData = ["", "", "", "", ""];

  final DateTime _selectedDate = DateTime.now();

  final formKey = GlobalKey<FormState>();

  selectDate() async {
    String? value = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Year"),
          content: SizedBox(
            // Need to use container to add size constraint.
            width: 300,
            height: 300,
            child: YearPicker(
              firstDate: DateTime(DateTime.now().year - 150, 1),
              lastDate: DateTime(DateTime.now().year - 10, 1),
              selectedDate: _selectedDate,
              onChanged: (DateTime selectedDateTime) {
                Navigator.of(context).pop(selectedDateTime.year.toString());
              },
            ),
          ),
        );
      },
    );
    if (value != null) {
      setState(() {
        formData[4] = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(providerUserSignUp).userData;

    switch (userData.gender) {
      case "Male":
        currentGender = _Genders.male;
        break;
      case "Female":
        currentGender = _Genders.female;
        break;
      default:
        break;
    }
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                Text(
                  "Now Let's Get You A Profile",
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
                            formData[0] = value!;
                          },
                          initialValue: userData.icCard,
                          labelText: 'Identity Card',
                          hintText: '900603001234',
                          validate: Validator.ic,
                          formatter: [FilteringTextInputFormatter.digitsOnly],
                        ),
                        const SizedBox(height: 20),
                        WidgetTextInput(
                          onSaved: (String? value) {
                            formData[1] = value!;
                          },
                          initialValue: userData.firstName,
                          validate: Validator.notEmpty,
                          labelText: 'First Name',
                          hintText: 'example: Syahmi',
                        ),
                        const SizedBox(height: 20),
                        WidgetTextInput(
                          onSaved: (String? value) {
                            formData[2] = value!;
                          },
                          initialValue: userData.lastName,
                          validate: Validator.notEmpty,
                          labelText: 'Last Name',
                          hintText: 'example: Zulkifli',
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Text("Year of Born: ${formData[4]}",
                                style: Theme.of(context).textTheme.titleMedium),
                            TextButton(
                                onPressed: () {
                                  selectDate();
                                },
                                child: const Text("Pick Year of Born"))
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text("Gender",
                            style: Theme.of(context).textTheme.titleMedium),
                        DropdownButtonFormField(
                          value: currentGender,
                          onChanged: (_Gender? newGender) {
                            currentGender = newGender ?? _Genders.nothing;
                          },
                          onSaved: (_Gender? gender) {
                            formData[3] = gender!.title;
                          },
                          validator: (_Gender? gender) {
                            if (gender != null) {
                              if (gender.title == _Genders.nothing.title) {
                                return "Please select the gender";
                              }
                            }
                            return null;
                          },
                          items: gender.map((_Gender gender) {
                            return DropdownMenuItem(
                              value: gender,
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: gender.color == 0
                                          ? Colors.transparent
                                          : Color(gender.color),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(gender.title),
                                ],
                              ),
                              onTap: () => currentGender = gender,
                            );
                          }).toList(),
                        ),
                      ],
                    )),
                ButtonNext(onPressed: () {
                  final curState = formKey.currentState;
                  if (curState != null) {
                    if (curState.validate()) {
                      curState.save();

                      if (formData[3] == _Genders.nothing.title) {
                        Util.runSnackBarMessage(
                            context, "Please Select Gender");
                        return;
                      }
                      if (formData[4].isEmpty) {
                        Util.runSnackBarMessage(
                            context, "Please select Year of born");
                        return;
                      }
                      ref.read(providerUserSignUp.notifier).update((state) =>
                          state.copyWith(
                              userData: state.userData.copyWith(
                                  icCard: formData[0],
                                  firstName: formData[1],
                                  lastName: formData[2],
                                  gender: formData[3],
                                  age: formData[4])));

                      context.beamToReplacementNamed(Page3_SignUpVerify.path);
                    }
                  }
                }),
                const SizedBox(height: 50),
                const Steps(step: 2, stepLength: 3),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Genders {
  _Genders._();

  static final _Gender nothing = _Gender(title: 'Nothing Selected', color: 0);
  static final _Gender male = _Gender(title: 'MALE', color: 0xFF2D9FDF);
  static final _Gender female = _Gender(title: 'FEMALE', color: 0xFFDF2D6D);
}

class _Gender {
  final String title;
  final int color;

  _Gender({required this.title, required this.color});
}
