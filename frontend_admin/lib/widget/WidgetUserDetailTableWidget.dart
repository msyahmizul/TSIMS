import 'package:flutter/material.dart';
import 'package:frontend_admin/model/userDetailModel.dart';

class WidgetUserDetailTable extends StatelessWidget {
  UserDetailModel user;

  WidgetUserDetailTable(this.user, {Key? key}) : super(key: key);
  static const spacerHeight = 10.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 350,
      child: Table(
        children: [
          TableRow(children: [
            TableCell(
              child: Text(
                "IC Card: ",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TableCell(
                child: Text(user.icCard,
                    style: Theme.of(context).textTheme.titleLarge)),
          ]),
          TableRow(children: [
            SizedBox(height: spacerHeight),
            SizedBox(height: spacerHeight),
          ]),
          TableRow(
            children: [
              Text("First Name:",
                  style: Theme.of(context).textTheme.titleLarge),
              Text(user.firstName,
                  style: Theme.of(context).textTheme.titleLarge)
            ],
          ),
          TableRow(children: [
            SizedBox(height: spacerHeight),
            SizedBox(height: spacerHeight),
          ]),
          TableRow(children: [
            Text("Last Name: ", style: Theme.of(context).textTheme.titleLarge),
            Text(user.lastName, style: Theme.of(context).textTheme.titleLarge)
          ]),
          TableRow(children: [
            SizedBox(height: spacerHeight),
            SizedBox(height: spacerHeight),
          ]),
          TableRow(
            children: [
              Text("Gender: ", style: Theme.of(context).textTheme.titleLarge),
              Text(user.gender, style: Theme.of(context).textTheme.titleLarge)
            ],
          ),
          TableRow(children: [
            SizedBox(height: spacerHeight),
            SizedBox(height: spacerHeight),
          ]),
          TableRow(children: [
            Text("Year Of Birth: ",
                style: Theme.of(context).textTheme.titleLarge),
            Text(user.dob, style: Theme.of(context).textTheme.titleLarge)
          ]),
          TableRow(children: [
            SizedBox(height: spacerHeight),
            SizedBox(height: spacerHeight),
          ]),
          TableRow(children: [
            Text("Address: ", style: Theme.of(context).textTheme.titleLarge),
            Text(user.address, style: Theme.of(context).textTheme.titleLarge)
          ]),
          TableRow(children: [
            SizedBox(height: spacerHeight),
            SizedBox(height: spacerHeight),
          ]),
          TableRow(children: [
            Text("City: ", style: Theme.of(context).textTheme.titleLarge),
            Text(user.city, style: Theme.of(context).textTheme.titleLarge)
          ]),
          TableRow(children: [
            SizedBox(height: spacerHeight),
            SizedBox(height: spacerHeight),
          ]),
          TableRow(children: [
            Text("State: ", style: Theme.of(context).textTheme.titleLarge),
            Text(user.state, style: Theme.of(context).textTheme.titleLarge)
          ]),
        ],
      ),
    );
  }
}
