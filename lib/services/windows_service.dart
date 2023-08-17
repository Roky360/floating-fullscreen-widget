import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:floating_fullscreen_widget/services/script_runner.dart';
import 'package:floating_fullscreen_widget/views/settings/settings_service.dart';
import 'package:win32/win32.dart';
import 'package:window_manager/window_manager.dart';

class WindowsService {
  static final WindowsService _windowsService = WindowsService._();

  WindowsService._();

  factory WindowsService() => _windowsService;

  /* **************** */

  String get shortcutPath =>
      "C:\\Users\\${getUsername()}\\AppData\\Roaming\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\Floating Fullscreen Widget.lnk";

  /// handle of the full-screened window, if any
  int? fsHwnd;

  Future<(bool, String?)> runFullscreenCheckingScript() async {
    const scriptPath = "scripts/check_fullscreen.py";
    final whitelistRaw = SettingsService().getWhitelist().trim();
    final List<String> whitelist = whitelistRaw.isEmpty
        ? []
        : whitelistRaw.split("\n").map((e) => e.trim().replaceAll(" ", "_")).toList();
    late final ProcessResult res;

    try {
      res = await ScriptRunner.runPythonScript(scriptPath, args: whitelist);
    } catch (e) {
      return (false, "err: $e");
    }

    if (res.exitCode == 0) {
      final out = (res.stdout as String).trim();
      if (out != "false") {
        fsHwnd = int.tryParse(out);
        return (true, null);
      }
      fsHwnd = null;
      return (false, "no window is fullscreen");
    } else {
      return (false, "code ${res.exitCode}, ${res.stderr as String}");
    }
  }

  String getUsername() {
    Pointer<Uint32> len = calloc<Uint32>();
    len.value = 32;
    Pointer<Utf16> name = (" " * len.value).toNativeUtf16();

    GetUserName(name, len);

    free(len);
    free(name);
    return name.toDartString();
  }

  Future<bool> createShortcutAt(String destinationPath) async {
    final executablePath = Platform.resolvedExecutable;
    const scriptPath = "scripts/create_app_shortcut.py";
    late final ProcessResult? res;

    try {
      res = await ScriptRunner.runPythonScript(scriptPath,
          args: [executablePath, shortcutPath, "Floating Fullscreen Widget auto-run."]);

      if (res.exitCode == 0) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  void removeShortcut() async {
    try {
      await File(shortcutPath).delete();
    } on PathNotFoundException catch (_) {
      return;
    }
  }

  WinSize getMonitorSize() {
    return WinSize(GetSystemMetrics(0), GetSystemMetrics(1));
  }

  WinSize getWinSize(int hwnd) {
    Pointer<RECT> r = calloc<RECT>();
    GetWindowRect(hwnd, r);
    final rect = r.ref;

    final size = WinSize(
      rect.right - rect.left,
      r.ref.bottom - rect.top,
    );
    free(r);

    return size;
  }

  String getWinTitle(int hwnd) {
    final nameP = (" " * (GetWindowTextLength(hwnd) + 1)).toNativeUtf16();
    GetWindowText(hwnd, nameP, nameP.length);

    final name = nameP.toDartString();
    free(nameP);
    return name;
  }

  int giveFocus(int hwnd) => SetForegroundWindow(hwnd);

  Future<int> getTopWindow() async {
    bool wasFocused = false;
    if (await windowManager.isFocused()) {
      wasFocused = true;
      await windowManager.blur();
    }

    final hwnd = GetForegroundWindow();

    if (wasFocused) await windowManager.focus();

    return hwnd;
  }

  bool isWindowFullscreen(int hwnd) => getMonitorSize() == getWinSize(hwnd);
}

class WinSize {
  final int width;
  final int height;

  WinSize(this.width, this.height);

  @override
  String toString() {
    return '($width, $height)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WinSize &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => width.hashCode ^ height.hashCode;
}
