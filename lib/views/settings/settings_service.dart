import 'package:floating_fullscreen_widget/services/windows_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_tray/system_tray.dart';

enum DisplayMode {
  spacious,
  flat,
}

class SettingsService {
  static final SettingsService _settingsService = SettingsService._();

  SettingsService._();

  factory SettingsService() => _settingsService;

  /* ************** */

  // global constants
  static const Size spaciousWidgetViewSize = Size(126, 65);
  static const Size flatWidgetViewSize = Size(200, 30);
  static const Size settingsViewSize = Size(430, 670);

  // default values
  static const Offset _defaultOffset = Offset(500, 500);
  static const int _defaultActiveTime = 5;
  static const int _defaultIdleTime = 10;

  // keys
  static const firstLaunch = "FIRST_LAUNCH";
  static const bool _overrideSettings = false; // for testing
  static const spaciousWidgetPos = "SPACIOUS_WIDGET_POS";
  static const flatWidgetPos = "FLAT_WIDGET_POS";
  static const activeRefreshTime = "ACTIVE_REFRESH_TIME";
  static const idleRefreshTime = "IDLE_REFRESH_TIME";
  static const runAtStartup = "RUN_AT_STARTUP";
  static const active = "ACTIVE";
  static const opacity = "OPACITY";
  static const whitelist = "WHITELIST";
  static const currentMode = "CURR_MODE";

  late final MenuItemCheckbox activeTrayCheckbox;
  late final SharedPreferences _prefs;

  SharedPreferences get prefs => _prefs;

  Future<void> loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final fLaunch = prefs.getBool(firstLaunch);
    if (fLaunch == null || !fLaunch || (_overrideSettings && kDebugMode)) {
      // set default values
      await prefs.clear();
      await prefs.setBool(firstLaunch, true);

      await setActiveTime(_defaultActiveTime);
      await setIdleTime(_defaultIdleTime);
      await setSpaciousWidgetPos(_defaultOffset);
      await setFlatWidgetPos(_defaultOffset);
      await setMode(DisplayMode.spacious);
    }
  }

  /* Active time */
  Future<void> setActiveTime(int timeInSeconds) async {
    await prefs.setInt(activeRefreshTime, timeInSeconds);
  }

  int getActiveTime() {
    return prefs.getInt(activeRefreshTime) ?? _defaultActiveTime;
  }

  /* Idle time */
  Future<void> setIdleTime(int timeInSeconds) async {
    await prefs.setInt(idleRefreshTime, timeInSeconds);
  }

  int getIdleTime() {
    return prefs.getInt(idleRefreshTime) ?? _defaultIdleTime;
  }

  /* Widget pos */
  Future<void> setSpaciousWidgetPos(Offset pos) async {
    await prefs.setString(spaciousWidgetPos, "${pos.dx},${pos.dy}");
  }

  Offset getSpaciousWidgetPos() {
    final pos = prefs.getString(spaciousWidgetPos);
    if (pos == null) return _defaultOffset;
    final factors = pos.split(",");
    return Offset(double.parse(factors[0]), double.parse(factors[1]));
  }

  // flat
  Future<void> setFlatWidgetPos(Offset pos) async {
    await prefs.setString(flatWidgetPos, "${pos.dx},${pos.dy}");
  }

  Offset getFlatWidgetPos() {
    final pos = prefs.getString(flatWidgetPos);
    if (pos == null) return _defaultOffset;
    final factors = pos.split(",");
    return Offset(double.parse(factors[0]), double.parse(factors[1]));
  }

  /* startup */
  Future<void> setRunAtStartup(bool run) async {
    final WindowsService windowsService = WindowsService();

    if (run) {
      final success = await windowsService.createShortcutAt(windowsService.shortcutPath);

      if (success) {
        await prefs.setBool(runAtStartup, run);
      }
    } else {
      windowsService.removeShortcut();
      await prefs.setBool(runAtStartup, run);
    }
  }

  bool getRunAtStartup() {
    return prefs.getBool(runAtStartup) ?? true;
  }

  /* active */
  Future<void> setActive(bool isActive) async {
    await prefs.setBool(active, isActive);
    await activeTrayCheckbox.setCheck(isActive);
  }

  bool getActive() {
    return prefs.getBool(active) ?? true;
  }

  /* opacity */
  Future<void> setOpacity(double opacity) async {
    await prefs.setDouble(SettingsService.opacity, opacity);
  }

  double getOpacity() {
    return prefs.getDouble(opacity) ?? 1.0;
  }

  /* whitelist */
  Future<void> setWhitelist(String list) async {
    await prefs.setString(whitelist, list);
  }

  String getWhitelist() {
    return prefs.getString(whitelist) ?? "";
  }

  /* mode */
  Future<void> setMode(DisplayMode mode) async {
    await prefs.setString(currentMode, mode.name);
  }

  DisplayMode getMode() {
    final String? modeRaw = prefs.getString(currentMode);
    return modeRaw != null
        ? DisplayMode.values.firstWhere((e) => e.name == modeRaw)
        : DisplayMode.spacious;
  }
}
