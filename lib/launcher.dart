import 'package:floating_fullscreen_widget/views/activation_bloc/activation_bloc.dart';
import 'package:floating_fullscreen_widget/views/main_view.dart';
import 'package:floating_fullscreen_widget/views/settings/settings_service.dart';
import 'package:floating_fullscreen_widget/views/views_bloc/views_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io' show Platform;

class Launcher extends StatefulWidget {
  const Launcher({super.key});

  @override
  State<Launcher> createState() => _LauncherState();
}

class _LauncherState extends State<Launcher> {
  final SettingsService settingsService = SettingsService();
  late final ViewsBloc viewsBloc;
  late final SystemTray systemTray;

  Future<void> initSystemTray() async {
    String path = 'assets/tray_icon.ico';
    systemTray = SystemTray();

    // We first init the systray menu
    await systemTray.initSystemTray(
        title: "Floating Fullscreen Widget", iconPath: path, toolTip: "Floating Fullscreen Widget");

    // create context menu
    final Menu menu = Menu();
    await menu.buildFrom([
      settingsService.activeTrayCheckbox = MenuItemCheckbox(
        label: "Active",
        checked: settingsService.getActive(),
        onClicked: (menuItem) {
          final newVal = !settingsService.getActive();
          menuItem.setCheck(newVal);
          settingsService.setActive(newVal);
          context.read<ActivationBloc>().add(newVal ? ActivateEvent() : DeactivateEvent());
        },
      ),
      MenuSeparator(),
      MenuItemLabel(label: "Settings", onClicked: (_) => viewsBloc.add(SwitchToSettingsEvent())),
      MenuSeparator(),
      MenuItemLabel(label: 'Exit', onClicked: (_) => windowManager.close()),
    ]);

    // set context menu
    await systemTray.setContextMenu(menu);

    // handle system tray event
    systemTray.registerSystemTrayEventHandler((eventName) async {
      if (eventName == kSystemTrayEventClick) {
        Platform.isWindows ? windowManager.show() : systemTray.popUpContextMenu();
      } else if (eventName == kSystemTrayEventRightClick) {
        Platform.isWindows ? systemTray.popUpContextMenu() : windowManager.show();
      }
    });
  }

  Future<void> initApp() async {
    await settingsService.loadSettings();
    await initSystemTray();
    await windowManager.setOpacity(settingsService.getOpacity());
    await windowManager.setPosition(settingsService.getSpaciousWidgetPos());
  }

  @override
  void initState() {
    super.initState();

    viewsBloc = context.read<ViewsBloc>();
  }

  @override
  void dispose() {
    systemTray.destroy();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const MainView();
        } else {
          return const Card(
            elevation: 0,
            child: SizedBox(),
          );
        }
      },
    );
  }
}
