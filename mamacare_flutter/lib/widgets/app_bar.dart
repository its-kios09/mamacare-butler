import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

AppBar customAppBar() {
  return AppBar(
    leading: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset('assets/images/logo.png'),
    ),
    title: const Text('mamaCare - Kenya'),
    actions: [
      IconButton(
        onPressed: () {

        },
        icon: const Icon(
          FontAwesomeIcons.bell,
          size: 20,
        ),
      ),
      Builder(builder: (context) {
        return IconButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          icon: const Icon(Icons.menu),
        );
      }),
    ],
  );
}
