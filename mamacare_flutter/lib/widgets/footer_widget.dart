import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key, this.hasPartners = true}) : super(key: key);
  final bool hasPartners;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 250,
        ),
        const Divider(),
        const SizedBox(
          height: 10,
        ),
        Text(
          '© 2026. All Rights Reserved. Version: 1.0.0',
          style: TextStyle(                  color: Colors.grey[600],
              fontSize: 12),
        ),
        if (hasPartners)
          const SizedBox(
            height: 10,
          ),
        if (hasPartners)
          Image.asset(
            'assets/images/logo.png',
            height: 50,
          ),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }
}
