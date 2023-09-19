import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import '../../widgets/battery_widget.dart';
import '../../widgets/time_widget.dart';
import '../views_bloc/views_bloc.dart';

class FlatWidgetView extends StatelessWidget {
  final double controlsOpacity;
  final Duration controlsOpacityAnimationDuration;
  final VoidCallback onCloseButtonPress;
  final VoidCallback onSettingsButtonPress;

  const FlatWidgetView(
      {super.key,
      required this.controlsOpacity,
      required this.controlsOpacityAnimationDuration,
      required this.onCloseButtonPress,
      required this.onSettingsButtonPress});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DragToMoveArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: controlsOpacity,
              duration: controlsOpacityAnimationDuration,
              child: IconButton(
                onPressed: onCloseButtonPress,
                padding: const EdgeInsets.all(4),
                iconSize: 14,
                constraints: const BoxConstraints(
                  maxWidth: 30,
                  maxHeight: 30,
                ),
                icon: const Icon(Icons.close),
              ),
            ),
            const Spacer(),

            // widgets
            // time widget
            TimeWidget(time: DateTime.now()),
            Center(
              child: Text("  •  ",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white)),
            ),
            const SizedBox(height: 14),
            // battery widget
            BatteryWidget(),

            const Spacer(flex: 1),

            // right buttons
            AnimatedOpacity(
              opacity: controlsOpacity,
              duration: controlsOpacityAnimationDuration,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // switch view
                  IconButton(
                    onPressed: () => context.read<ViewsBloc>().add(SwitchToSpaciousViewEvent()),
                    padding: const EdgeInsets.all(4),
                    iconSize: 14,
                    constraints: const BoxConstraints(
                      maxWidth: 30,
                      maxHeight: 30,
                    ),
                    icon: const Icon(Icons.switch_access_shortcut),
                  ),

                  // disable
                  IconButton(
                    onPressed: onSettingsButtonPress,
                    padding: const EdgeInsets.all(4),
                    iconSize: 14,
                    constraints: const BoxConstraints(
                      maxWidth: 30,
                      maxHeight: 30,
                    ),
                    icon: const Icon(Icons.settings),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
