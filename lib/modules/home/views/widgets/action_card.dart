import 'package:flutter/material.dart';

class ActionCardWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const ActionCardWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}
