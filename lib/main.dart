import 'package:floating_fullscreen_widget/config/style.dart';
import 'package:floating_fullscreen_widget/launcher.dart';
import 'package:floating_fullscreen_widget/views/activation_bloc/activation_bloc.dart';
import 'package:floating_fullscreen_widget/views/settings/settings_service.dart';
import 'package:floating_fullscreen_widget/views/views_bloc/views_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizer/sizer.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  const initialSize = SettingsService.spaciousWidgetViewSize;
  WindowOptions windowOptions = const WindowOptions(
    size: initialSize,
    title: "Floating Fullscreen Widget",
    // center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
    alwaysOnTop: true,
    minimumSize: initialSize,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.setHasShadow(false);
    // await windowManager.setAsFrameless();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => ViewsBloc()),
          BlocProvider(create: (context) => ActivationBloc()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          home: const Launcher(),
          theme: AppStyle.darkTheme,
        ),
      ),
    );
  }
}
