import 'package:floating_fullscreen_widget/services/windows_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:system_tray/system_tray.dart';

class SettingsService {
  static final SettingsService _settingsService = SettingsService._();

  SettingsService._();

  factory SettingsService() => _settingsService;

  /* ************** */

  // global constants
  static const Size widgetViewSize = Size(160, 75);
  static const Size settingsViewSize = Size(430, 670);

  // default value
  static const Offset _defaultOffset = Offset(500, 500);
  static const int _defaultActiveTime = 5;
  static const int _defaultIdleTime = 10;

  // keys
  static const firstLaunch = "FIRST_LAUNCH";
  static const bool _overrideSettings = false; // for testing
  static const widgetPos = "WIDGET_POS";
  static const activeRefreshTime = "ACTIVE_REFRESH_TIME";
  static const idleRefreshTime = "IDLE_REFRESH_TIME";
  static const runAtStartup = "RUN_AT_STARTUP";
  static const active = "ACTIVE";
  static const opacity = "OPACITY";
  static const whitelist = "WHITELIST";

  late final MenuItemCheckbox activeTrayCheckbox;
  late final SharedPreferences _prefs;

  SharedPreferences get prefs => _prefs;

  Future<void> loadSettings() async {
    SharedPreferences.setPrefix("flutter.floating_fs_widget:");
    _prefs = await SharedPreferences.getInstance();
    final fLaunch = prefs.getBool(firstLaunch);
    if (fLaunch == null || !fLaunch || (_overrideSettings && kDebugMode)) {
      await prefs.setBool(firstLaunch, true);

      await setActiveTime(_defaultActiveTime);
      await setIdleTime(_defaultIdleTime);
      await setWidgetPos(_defaultOffset);
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
  Future<void> setWidgetPos(Offset pos) async {
    await prefs.setString(widgetPos, "${pos.dx},${pos.dy}");
  }

  Offset getWidgetPos() {
    final pos = prefs.getString(widgetPos);
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
}
