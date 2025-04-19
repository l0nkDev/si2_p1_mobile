
import 'package:flutter/material.dart';

class LabeledInput extends StatelessWidget {
    const LabeledInput({
    super.key,
    required this.label,
    required this.controller
    });

    final String label;
    final TextEditingController controller;

  @override
  Widget build(BuildContext context) {

    return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  decoration: 
                  InputDecoration(
                    label: Text(label),
                    border: OutlineInputBorder()
                    ),
                )
              ],
            ),
          );
  }
}