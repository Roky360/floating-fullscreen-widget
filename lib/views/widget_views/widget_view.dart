import 'dart:async';
import 'package:floating_fullscreen_widget/services/windows_service.dart';
import 'package:floating_fullscreen_widget/views/settings/settings_service.dart';
import 'package:floating_fullscreen_widget/views/views_bloc/views_bloc.dart';
import 'package:floating_fullscreen_widget/views/widget_views/flat_view.dart';
import 'package:floating_fullscreen_widget/views/widget_views/spacious_view.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';

import '../activation_bloc/activation_bloc.dart';

class WidgetView extends StatefulWidget {
  const WidgetView({super.key});

  @override
  State<WidgetView> createState() => _WidgetViewState();
}

class _WidgetViewState extends State<WidgetView> with WindowListener {
  final WindowsService ws = WindowsService();
  final SettingsService settingsService = SettingsService();
  final double borderRadius = 7;

  // controls opacity
  late double controlsOpacity;
  final Duration controlsOpacityAnimationDuration = const Duration(milliseconds: 300);
  final double focusedControlsOpacity = .9;
  final double unfocusedControlsOpacity = .5;

  late Timer refreshTimer;

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

  void onCloseButtonPress() async {
    disabledUntilNextTime = true;
    await windowManager.hide();
  }

  void onSettingsButtonPress() => context.read<ViewsBloc>().add(SwitchToSettingsEvent());

  @override
  void onWindowEvent(String eventName) async {
    if (eventName == "moved") {
      blurTimer.cancel();
      // save position
      final state = context.read<ViewsBloc>().state;
      final winPos = await windowManager.getPosition();
      if (state is SpaciousViewState) {
        await settingsService.setSpaciousWidgetPos(winPos);
      } else {
        await settingsService.setFlatWidgetPos(winPos);
      }
      await restoreFocusToFullScreenedWindow();
    } else if (eventName != "blur") {
      blurTimer.cancel();
      inInteraction = true;
      blurTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) async {
        timer.cancel();
        await restoreFocusToFullScreenedWindow();
      });
    }
    // control control buttons opacity
    if (eventName == "focus") {
      setState(() => controlsOpacity = focusedControlsOpacity);
    } else if (eventName == "blur") {
      setState(() => controlsOpacity = unfocusedControlsOpacity);
    }
  }

  // for debugging
  final disableFullscreenCheck = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);

    controlsOpacity = unfocusedControlsOpacity;
    blurTimer = Timer(Duration.zero, () {});
    refreshTimer = Timer(Duration.zero, () {});

    if (!disableFullscreenCheck || !kDebugMode) {
      if (settingsService.getActive()) {
        refreshTimer = Timer(Duration(seconds: settingsService.getActiveTime()), refresh);
      } else {
        refreshTimer = Timer(Duration.zero, () {});
        windowManager.hide();
      }
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
      child: BlocBuilder<ViewsBloc, ViewsState>(
        builder: (context, state) {
          if (state is SpaciousViewState) {
            return SpaciousWidgetView(
              onCloseButtonPress: onCloseButtonPress,
              onSettingsButtonPress: onSettingsButtonPress,
              controlsOpacity: controlsOpacity,
              controlsOpacityAnimationDuration: controlsOpacityAnimationDuration,
            );
          } else {
            return FlatWidgetView(
              controlsOpacity: controlsOpacity,
              controlsOpacityAnimationDuration: controlsOpacityAnimationDuration,
              onCloseButtonPress: onCloseButtonPress,
              onSettingsButtonPress: onSettingsButtonPress,
            );
          }
        },
      ),
    );
  }
}
