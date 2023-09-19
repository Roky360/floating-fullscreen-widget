import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import '../../widgets/battery_widget.dart';
import '../../widgets/time_widget.dart';
import '../views_bloc/views_bloc.dart';

class SpaciousWidgetView extends StatelessWidget {
  final double controlsOpacity;
  final Duration controlsOpacityAnimationDuration;
  final VoidCallback onCloseButtonPress;
  final VoidCallback onSettingsButtonPress;

  const SpaciousWidgetView(
      {super.key,
      required this.onCloseButtonPress,
      required this.onSettingsButtonPress,
      required this.controlsOpacity,
      required this.controlsOpacityAnimationDuration});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // elevation: 0,
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
      body: DragToMoveArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Expanded
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AnimatedOpacity(
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
                  // child: const Icon(
                  //   Icons.drag_handle,
                  //   size: 20,
                  // ),
                ),
              ),
            ),
            const Spacer(flex: 1),

            // widgets
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // time widget
                TimeWidget(time: DateTime.now()),

                const SizedBox(height: 4),

                // battery widget
                BatteryWidget(),
              ],
            ),
            const Spacer(flex: 1),

            // right buttons
            AnimatedOpacity(
              opacity: controlsOpacity,
              duration: controlsOpacityAnimationDuration,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
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
                  // swap view
                  IconButton(
                    onPressed: () => context.read<ViewsBloc>().add(SwitchToFlatViewEvent()),
                    padding: const EdgeInsets.all(4),
                    iconSize: 14,
                    constraints: const BoxConstraints(
                      maxWidth: 30,
                      maxHeight: 30,
                    ),
                    icon: const Icon(Icons.switch_access_shortcut),
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
