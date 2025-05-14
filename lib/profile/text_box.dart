import 'package:flutter/material.dart';

class Mytextbox extends StatefulWidget {
  final String text;
  final String sectionName;
  const Mytextbox({super.key, required this.text, required this.sectionName});

  @override
  State<Mytextbox> createState() => _MytextboxState();
}

class _MytextboxState extends State<Mytextbox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      margin: const EdgeInsets.only(left: 25, right: 25, bottom: 20),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      child: Column(
        children: [
          //section name
          Text(widget.sectionName),

          //text box
          Text(widget.text),
        ],
      ),
    );
  }
}
