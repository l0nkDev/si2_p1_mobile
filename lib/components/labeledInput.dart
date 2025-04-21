
import 'package:flutter/material.dart';

class LabeledInput extends StatelessWidget {
   LabeledInput({
    super.key,
    required this.label,
    required this.controller,
    this.enabled = true
    });

    final String label;
    final TextEditingController controller;
    bool enabled;

  @override
  Widget build(BuildContext context) {

    return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  enabled: enabled,
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