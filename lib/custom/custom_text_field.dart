import 'package:flutter/material.dart';

class CustomTextField extends TextField {
  CustomTextField({
    Key? key,
    void Function(String)? onChanged,
    String? hintText,
    TextEditingController? controller,
  }) : super(
          key: key,
          maxLines: 1,
          controller: controller,
          decoration: InputDecoration(
              border: const OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.blueAccent)),
              enabledBorder: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              hintText: hintText),
          onChanged: onChanged,
        );
}
