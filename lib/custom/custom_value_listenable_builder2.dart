import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CustomValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> a;
  final ValueListenable<B> b;
  final Widget? child;
  final Widget Function(BuildContext context, A a, B b, Widget? child) builder;

  const CustomValueListenableBuilder2({
    required this.a,
    required this.b,
    Key? key,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<A>(
        valueListenable: a,
        builder: (_, b1, __) {
          return ValueListenableBuilder<B>(
            valueListenable: b,
            builder: (context, b2, __) {
              return builder(context, b1, b2, child);
            },
          );
        },
      );
}
