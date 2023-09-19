import 'package:floating_fullscreen_widget/views/settings/settings_service.dart';
import 'package:floating_fullscreen_widget/views/views_bloc/views_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:window_manager/window_manager.dart';

import '../activation_bloc/activation_bloc.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  final SettingsService settingsService = SettingsService();
  final EdgeInsets titlePad = const EdgeInsets.only(top: 16, left: 15);

  late bool isActive;
  late double opacity;
  late int activeTime;
  late int idleTime;
  late final TextEditingController whitelistController;
  final FocusNode whitelistTextFieldFocus = FocusNode();

  Future<void> updateWhitelist() async {
    if (settingsService.getWhitelist() != whitelistController.text) {
      await settingsService.setWhitelist(whitelistController.text);
    }
  }

  @override
  void initState() {
    super.initState();

    opacity = settingsService.getOpacity();
    activeTime = settingsService.getActiveTime();
    idleTime = settingsService.getIdleTime();
    whitelistController = TextEditingController(text: settingsService.getWhitelist());
  }

  @override
  Widget build(BuildContext context) {
    isActive = settingsService.getActive();
    return BlocListener<ActivationBloc, ActivationState>(
      listener: (context, state) {
        if (state is ActiveState || state is InactiveState) {
          setState(() {});
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: kToolbarHeight - 5,
          flexibleSpace: const DragToMoveArea(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
          )),
          title: const DragToMoveArea(child: Text("Settings")),
          leading: IconButton(
            onPressed: () async {
              await updateWhitelist();
              context.read<ViewsBloc>().add(SwitchToPreviousViewEvent());
            },
            icon: const Icon(Icons.arrow_back),
          ),
          actions: [
            IconButton(
              onPressed: () => windowManager.close(),
              color: Colors.red,
              icon: const Icon(Icons.exit_to_app),
              tooltip: "Exit",
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: SfSliderTheme(
          data: SfSliderThemeData(
            activeTrackHeight: 20,
            inactiveTrackHeight: 20,
            thumbColor: Colors.white,
          ),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SwitchListTile(
                  value: settingsService.getActive(),
                  onChanged: (value) async {
                    await settingsService.setActive(value);
                    setState(() {});
                  },
                  activeTrackColor: isActive
                      ? Colors.greenAccent.withOpacity(.5)
                      : Colors.redAccent.withOpacity(.2),
                  tileColor: isActive
                      ? Colors.greenAccent.withOpacity(.2)
                      : Colors.redAccent.withOpacity(.2),
                  thumbColor: MaterialStateProperty.all(Colors.white),
                  title: Text(
                    "Active",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SwitchListTile(
                  value: settingsService.getRunAtStartup(),
                  onChanged: (value) async {
                    await settingsService.setRunAtStartup(value);
                    setState(() {});
                  },
                  title: Text(
                    "Run at startup",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white),
                  ),
                  thumbColor: MaterialStateProperty.all(Colors.white),
                ),
              ),

              // opacity
              Padding(
                padding: titlePad,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Opacity (%)",
                      style:
                          Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white)),
                ),
              ),
              SfSlider(
                value: opacity,
                min: .3,
                max: 1.0,
                stepSize: .05,
                thumbIcon: Center(
                    child: Text(
                  "${(opacity * 100).round()}",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontSize: 11),
                )),
                onChanged: (val) async {
                  await windowManager.setOpacity(val);
                  setState(() => opacity = val as double);
                },
                onChangeEnd: (value) async {
                  await settingsService.setOpacity(value);
                  await windowManager.setOpacity(1);
                },
              ),

              const Divider(),
              Padding(
                padding: titlePad,
                child: Text("Advanced",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ),

              // active
              Padding(
                padding: titlePad,
                child: Text("Active refresh time (seconds)",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white)),
              ),
              SfSlider(
                value: activeTime,
                min: 1,
                max: 30,
                stepSize: 1,
                thumbIcon: Center(child: Text(activeTime.toString())),
                onChanged: (val) => setState(() => activeTime = (val as double).toInt()),
                onChangeEnd: (value) {
                  settingsService.setActiveTime((value as double).toInt());
                },
              ),

              // idle
              Padding(
                padding: titlePad,
                child: Text("Idle refresh time (seconds)",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white)),
              ),
              SfSlider(
                value: idleTime,
                min: 5,
                max: 60,
                stepSize: 1,
                thumbIcon: Center(child: Text(idleTime.toString())),
                onChanged: (val) => setState(() => idleTime = (val as double).toInt()),
                onChangeEnd: (value) {
                  settingsService.setIdleTime((value as double).toInt());
                },
              ),

              // whitelist
              Padding(
                padding: titlePad,
                child: Text("Whitelist windows",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Colors.white)),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15, top: 2),
                child: Text(
                    "Recognize only windows with these names. Each window name in a line. Not case-sensitive.",
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: Colors.white, fontStyle: FontStyle.italic)),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: whitelistController,
                  focusNode: whitelistTextFieldFocus,
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    hintText: "Example: Google Chrome",
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white),
                  onTapOutside: (_) {
                    updateWhitelist();
                    whitelistTextFieldFocus.unfocus();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
