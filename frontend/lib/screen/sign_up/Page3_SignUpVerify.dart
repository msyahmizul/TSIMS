import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/Widget/WidgetTextInput.dart';
import 'package:mobile/const.dart';
import 'package:mobile/screen/sign_up/Page5_Finalise.dart';

import './ButtonNext.dart';
import './Steps.dart';
import '../../provider/ProviderSignUpForm.dart';

class Page3_SignUpVerify extends ConsumerWidget {
  Page3_SignUpVerify({Key? key}) : super(key: key);
  static const path = "/signup/3";

  static page() {
    return BeamPage(
        child: Page3_SignUpVerify(), key: const ValueKey("signup-3"));
  }

  final formKey = GlobalKey<FormState>();
  final formData = ["", "", "", ""];
  final List<File> files = [];
  bool declareSelect = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(providerUserSignUp).userData;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30, bottom: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.beamBack();
                  },
                  label: const Text("Back"),
                ),
                StatefulBuilder(
                  builder: (ctx, setState) {
                    return Form(
                        key: formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              "Verify your Profile",
                              style: Theme.of(context).textTheme.headline5,
                            ),
                            const SizedBox(height: 20),
                            const Text("Identity ID"),
                            Text(
                              userData.icCard,
                              style: Theme.of(context).textTheme.subtitle2,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Hi ${userData.firstName}, we will now asking for your personal information that proves it is you!",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "All information must match what's on your Identity Card",
                              style: TextStyle(color: Color(0xffFF3D22)),
                            ),
                            const SizedBox(height: 20),
                            WidgetTextInput(
                              labelText: 'Address',
                              hintText: 'No 00. Jalan Zero',
                              onSaved: (String? value) {
                                formData[0] = value!;
                              },
                              validate: Validator.notEmpty,
                            ),
                            WidgetTextInput(
                              labelText: 'City',
                              hintText: 'Johor Bahru',
                              validate: Validator.notEmpty,
                              onSaved: (String? value) {
                                formData[1] = value!;
                              },
                            ),
                            WidgetTextInput(
                              labelText: 'State',
                              hintText: 'Johor',
                              validate: Validator.notEmpty,
                              onSaved: (String? value) {
                                formData[2] = value!;
                              },
                            ),
                            WidgetTextInput(
                              labelText: 'Postcode',
                              hintText: '81300',
                              validate: Validator.notEmpty,
                              formatter: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onSaved: (String? value) {
                                formData[3] = value!;
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Documents",
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                                type: FileType.image,
                                                allowMultiple: true);
                                        if (result != null) {
                                          var f = result.paths
                                              .map((path) => File(path!));
                                          for (final e in f) {
                                            if (files.any((File file) =>
                                                file.uri.pathSegments.last ==
                                                e.uri.pathSegments.last)) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(const SnackBar(
                                                      content: Text(
                                                          "Duplicate Image")));
                                              return;
                                            }
                                          }

                                          setState(() {
                                            files.addAll(f);
                                          });
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    "Failed open the picker")));
                                      }
                                    },
                                    child: const Text("Select Image"))
                              ],
                            ),
                            Column(
                              children: files
                                  .mapIndexed((int index, File file) => Card(
                                        child: ListTile(
                                          title:
                                              Text(file.uri.pathSegments.last),
                                          trailing: IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                files.removeAt(index);
                                              });
                                            },
                                          ),
                                        ),
                                      ))
                                  .toList(),
                            ),
                            Text(
                              "Upload your copy of IC, front and back",
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 30),
                            const Text("Information Declaration"),
                            Row(children: [
                              Checkbox(
                                checkColor: Colors.white,
                                value: declareSelect,
                                onChanged: (bool? value) {
                                  setState(() => declareSelect = value!);
                                },
                              ),
                              const Flexible(
                                child: Text(
                                  "I Hereby Declare that the information Provided is True And Correct",
                                ),
                              ),
                            ]),
                          ],
                        ));
                  },
                ),
                const SizedBox(height: 50),
                const Steps(step: 3, stepLength: 3),
                const SizedBox(height: 10),
                ButtonNext(onPressed: () {
                  final curState = formKey.currentState;
                  if (curState == null) {
                    return;
                  }
                  if (!curState.validate()) {
                    return;
                  }
                  curState.save();
                  if (files.isEmpty || files.length != 2) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Please select image at least 2")));
                    return;
                  }
                  if (!declareSelect) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "Please agree with the information declaration")));
                    return;
                  }
                  ref.read(providerUserSignUp.notifier).update((state) =>
                      state.copyWith(
                          userData: state.userData.copyWith(
                              address: formData[0],
                              city: formData[1],
                              state: formData[2],
                              postcode: formData[3]),
                          userFile: files));
                  context.beamToNamed(Page5_Finalise.path);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
