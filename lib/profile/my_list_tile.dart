import 'package:flutter/material.dart';

class MyListTile extends StatefulWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap;
  const MyListTile(
      {super.key, required this.icon, required this.text, required this.onTap});

  @override
  State<MyListTile> createState() => _MyListTileState();
}

class _MyListTileState extends State<MyListTile> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: ListTile(
        leading: Icon(
          widget.icon,
          color: Colors.white,
        ),
        onTap: widget.onTap,
        title: Text(
          widget.text,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
