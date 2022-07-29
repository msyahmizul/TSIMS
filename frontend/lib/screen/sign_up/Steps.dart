import 'package:flutter/material.dart';

class Steps extends StatelessWidget {
  final int step;
  final int stepLength;

  const Steps({
    Key? key,
    required this.step,
    required this.stepLength,
  }) : super(key: key);

  List<Widget> _dots() {
    final List<Widget> dots = [];

    for (int index = 0; index < stepLength; index++) {
      dots.add(_Dot(isSelected: (step - 1) == index));

      if (index < stepLength) {
        dots.add(const SizedBox(width: 5));
      }
    }

    return dots;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Center(child: Text('$step of $stepLength Steps')),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _dots(),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isSelected;

  const _Dot({Key? key, this.isSelected = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }
}
