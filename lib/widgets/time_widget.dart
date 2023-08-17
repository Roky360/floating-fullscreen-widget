import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeWidget extends StatelessWidget {
  final DateTime time;

  const TimeWidget(this.time, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat.Hm().format(time),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white, fontSize: 15),
    );
  }
}
