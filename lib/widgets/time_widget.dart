import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeWidget extends StatelessWidget {
  final DateTime? time;

  const TimeWidget({super.key, this.time});

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat.Hm().format(time ?? DateTime.now()),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontSize: 16,
          ),
    );
  }
}
