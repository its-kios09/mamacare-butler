import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/constant.dart';

AppBar customAppBar({int notificationCount = 5}) {
  return AppBar(
    leading: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: kPrimaryColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(0.0),
          child: Image.asset('assets/images/logo.png', height: 10, width: 20,),
        ),
      ),
    ),
    title: const Text('mamaCare - Kenya'),
    actions: [
      // Stack(
      //   children: [
      //     IconButton(
      //       onPressed: () {},
      //       icon: const Icon(
      //         FontAwesomeIcons.bell,
      //         size: 20,
      //       ),
      //     ),
      //     if (notificationCount > 0)
      //       Positioned(
      //         right: 8,
      //         top: 8,
      //         child: Container(
      //           padding: const EdgeInsets.all(4),
      //           decoration: BoxDecoration(
      //             color: kPrimaryColor,
      //             shape: BoxShape.circle,
      //             border: Border.all(
      //               color: Colors.white,
      //               width: 2,
      //             ),
      //           ),
      //           constraints: const BoxConstraints(
      //             minWidth: 18,
      //             minHeight: 18,
      //           ),
      //           child: Center(
      //             child: Text(
      //               notificationCount > 99 ? '99+' : '$notificationCount',
      //               style: const TextStyle(
      //                 color: Colors.white,
      //                 fontSize: 10,
      //                 fontWeight: FontWeight.bold,
      //               ),
      //               textAlign: TextAlign.center,
      //             ),
      //           ),
      //         ),
      //       ),
      //   ],
      // ),
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