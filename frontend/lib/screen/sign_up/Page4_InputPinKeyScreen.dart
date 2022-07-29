import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mobile/screen/sign_up/Page5_Finalise.dart';

import './ButtonNext.dart';
import './Steps.dart';
import '../../const.dart';

class Page4_InputPinKeyScreen extends StatefulWidget {
  const Page4_InputPinKeyScreen({Key? key}) : super(key: key);
  static const path = "/signup/4";

  static page() {
    return BeamPage(
        child: Page4_InputPinKeyScreen(), key: const ValueKey("signup-4"));
  }

  @override
  State<StatefulWidget> createState() {
    return _Page4_InputPinKeyScreenState();
  }
}

class _Page4_InputPinKeyScreenState extends State<Page4_InputPinKeyScreen> {
  final List<String> inputs = [];
  final maxInputCount = 5;
  String steps = "1";
  List<String> finalSteps = [];

  List<String> getInputs() {
    List<String> inputs = [...this.inputs];

    while (inputs.length < maxInputCount) {
      inputs.add('');
    }

    return inputs;
  }

  void addInput(String numberText) {
    if (inputs.length >= maxInputCount) return;

    setState(() {
      inputs.add(numberText);
    });
  }

  void removeLastInput() {
    if (inputs.isEmpty) return;

    setState(() {
      inputs.removeLast();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 30, right: 30),
            child: Column(
              children: [
                // empty box for top space
                const SizedBox(height: 50),

                // title
                Center(
                  child: Text(
                    "Secure Your Profile",
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),

                // empty box between title & subtitle

                const SizedBox(height: 10),

                // subtitle
                Center(
                  child: Text(
                      steps == "1"
                          ? "Enter the pin code"
                          : "Reconfirm your pin number",
                      style: Theme.of(context).textTheme.titleMedium),
                ),

                // empty box between subtitle & pininputwidget
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...getInputs().map((input) {
                      return _PinPlaceholder(numberText: input);
                    })
                  ],
                ),

                const SizedBox(height: 10),

                _PinInputWidget(
                  onNumberPinPressed: (numberText) => addInput(numberText),
                  onBackPinPressed: removeLastInput,
                ),

                // footer
                const SizedBox(height: 50),
                const Steps(step: 4, stepLength: 4),
                const SizedBox(height: 10),
                ButtonNext(onPressed: () {
                  if (inputs.length < 5) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Pin must has 5")));
                    return;
                  }
                  if (steps == "1") {
                    finalSteps = List<String>.from(inputs);
                    setState(() {
                      steps = "2";
                      inputs.clear();
                    });
                  } else if (steps == "2") {
                    if (finalSteps.join() == inputs.join()) {
                      var box = Hive.box(BoxName.name);
                      box.put(BoxName.pinNumber, finalSteps.join());
                      context.beamToNamed(Page5_Finalise.path);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text("Pin does not match, please try again")));
                      setState(() {
                        steps = "1";
                        inputs.clear();
                        finalSteps.clear();
                      });
                    }
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinInputWidget extends StatelessWidget {
  final buttonMatrix = [
    ["1", "2", "3"],
    ["4", "5", "6"],
    ["7", "8", "9"],
  ];
  final Function onNumberPinPressed;
  final Function onBackPinPressed;

  _PinInputWidget(
      {Key? key,
      required this.onNumberPinPressed,
      required this.onBackPinPressed})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...(buttonMatrix.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...row.map((numberText) => _Pin(
                    numberText: numberText,
                    onPressed: () => {onNumberPinPressed(numberText)},
                  ))
            ],
          );
        })),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
            ),
            _Pin(
              numberText: "0",
              onPressed: () => {onNumberPinPressed("0")},
            ),
            Container(
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(10),
                child: IconButton(
                    onPressed: () => onBackPinPressed(),
                    icon: Icon(Icons.backspace_outlined))),
          ],
        ),
      ],
    );
  }
}

class _PinPlaceholder extends StatelessWidget {
  final double size = 18;
  final String numberText;

  const _PinPlaceholder({Key? key, this.numberText = ""}) : super(key: key);

  bool hasValue() {
    return numberText != '';
  }

  Color background() {
    return hasValue() ? Colors.deepOrange : Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: size,
        width: size,
        margin: EdgeInsets.all(size * 0.2),
        decoration: BoxDecoration(
          color: background(),
          borderRadius: const BorderRadius.all(
            Radius.circular(40),
          ),
          border: Border.all(
            width: 3,
            color: Colors.grey,
            style: BorderStyle.solid,
          ),
        ));
  }
}

class _Pin extends StatelessWidget {
  final String numberText;
  final Function onPressed;

  const _Pin({
    Key? key,
    required this.numberText,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 80,
        margin: EdgeInsets.all(10),
        child: ElevatedButton(
          onPressed: () => onPressed(),
          child: Text(numberText),
          style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(30),
            primary: Colors.grey, // <-- Button color
          ),
        ));
  }
}
