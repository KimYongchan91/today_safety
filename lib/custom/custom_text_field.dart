import 'package:flutter/material.dart';

class CustomTextField extends TextField {
  const CustomTextField({
    Key? key,
    void Function(String)? onChanged,
  }) : super(
          key: key,
          maxLines: 1,
          decoration: const InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blueAccent)
              ),
              enabledBorder: OutlineInputBorder(),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
          onChanged: onChanged,
        );
}
