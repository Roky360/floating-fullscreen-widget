import 'dart:async';
import 'package:floating_fullscreen_widget/services/windows_service.dart';
import 'package:floating_fullscreen_widget/views/settings/settings_service.dart';
import 'package:floating_fullscreen_widget/views/views_bloc/views_bloc.dart';

import 'package:floating_fullscreen_widget/widgets/battery_widget.dart';
import 'package:floating_fullscreen_widget/widgets/time_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import 'activation_bloc/activation_bloc.dart';

class WidgetView extends StatefulWidget {
  const WidgetView({super.key});

  @override
  State<WidgetView> createState() => _WidgetViewState();
}

class _WidgetViewState extends State<WidgetView> with WindowListener {
  final WindowsService ws = WindowsService();
  final SettingsService settingsService = SettingsService();
  final double borderRadius = 10;

  late Timer refreshTimer;
  late DateTime time;

  bool disabledUntilNextTime = false;
  bool inInteraction = false;
  late Timer blurTimer;

  String t = "";

  void refresh() async {
    // check for full-screened window
    final isFullscreen = await ws.runFullscreenCheckingScript();
    if ((isFullscreen.$1 || inInteraction) && !disabledUntilNextTime) {
      // show / keep shown
      if (!await windowManager.isVisible()) {
        await windowManager.show();
        await restoreFocusToFullScreenedWindow();
      }

      // update the window
      if (!mounted) return;
      time = DateTime.now();
      // t = "";

      refreshTimer = Timer(Duration(seconds: settingsService.getActiveTime()), refresh);
    } else {
      disabledUntilNextTime = false;
      // hide / keep hidden
      if (await windowManager.isVisible()) await windowManager.hide();
      if (isFullscreen.$2 != "no window is fullscreen") {
        t = isFullscreen.$2!;
        await windowManager.show();
      }
      refreshTimer = Timer(Duration(seconds: settingsService.getIdleTime()), refresh);
    }
    setState(() {});
  }

  Future<void> restoreFocusToFullScreenedWindow() async {
    inInteraction = false;
    await windowManager.blur();
    if (ws.fsHwnd != null) {
      ws.giveFocus(ws.fsHwnd!);
    }
  }

  void active() {
    refreshTimer = Timer(Duration(seconds: settingsService.getIdleTime()), refresh);
  }

  void inactive() async {
    refreshTimer.cancel();
    blurTimer.cancel();
    await windowManager.hide();
  }

  @override
  void onWindowEvent(String eventName) async {
    if (eventName == "moved") {
      blurTimer.cancel();
      // save position
      await settingsService.setWidgetPos(await windowManager.getPosition());
      await restoreFocusToFullScreenedWindow();
    } else if (eventName != "blur") {
      blurTimer.cancel();
      inInteraction = true;
      blurTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) async {
        timer.cancel();
        await restoreFocusToFullScreenedWindow();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    time = DateTime.now();

    blurTimer = Timer(Duration.zero, () {});
    if (settingsService.getActive()) {
      refreshTimer = Timer(Duration(seconds: settingsService.getActiveTime()), refresh);
    } else {
      refreshTimer = Timer(Duration.zero, () {});
      windowManager.hide();
    }
    WidgetsBinding.instance
        .addPostFrameCallback((_) async => await restoreFocusToFullScreenedWindow());
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    refreshTimer.cancel();
    blurTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ActivationBloc, ActivationState>(
      listener: (context, state) {
        if (state is ActiveState) {
          active();
        } else if (state is InactiveState) {
          inactive();
        }
      },
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(t, style: const TextStyle(color: Colors.white)),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.blueGrey[700],
                        borderRadius: BorderRadius.circular(borderRadius)),
                    child: const DragToMoveArea(
                        child: RotatedBox(
                      quarterTurns: 1,
                      child: Icon(
                        Icons.drag_handle,
                        size: 20,
                      ),
                    )),
                  ),
                ],
              ),
            ),
            const Spacer(),

            // widgets
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // time widget
                TimeWidget(time),

                const SizedBox(height: 4),

                // battery widget
                BatteryWidget(),
              ],
            ),
            const Spacer(),

            // right buttons
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // hide
                IconButton(
                  onPressed: () async {
                    disabledUntilNextTime = true;
                    await windowManager.hide();
                  },
                  padding: const EdgeInsets.all(4),
                  iconSize: 14,
                  constraints: const BoxConstraints(
                    maxWidth: 30,
                    maxHeight: 30,
                  ),
                  icon: const Icon(Icons.close),
                ),
                // const Spacer(),

                // disable
                IconButton(
                  onPressed: () => context.read<ViewsBloc>().add(SwitchToSettingsEvent()),
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
          ],
        ),
      ),
    );
  }
}
