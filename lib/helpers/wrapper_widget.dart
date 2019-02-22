import 'package:flutter/material.dart';

// class WrapperWidget extends StatelessWidget {
//   final Widget child;
//   WrapperWidget({this.child});
//   @override
//   Widget build(BuildContext context) {
//     return child;
//   }
// }

class WrapperWidget extends StatefulWidget {
  final Widget child;
  WrapperWidget({this.child});
  @override
  State<StatefulWidget> createState() => WrapperWidgetState();
}

class WrapperWidgetState extends State<WrapperWidget> {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}