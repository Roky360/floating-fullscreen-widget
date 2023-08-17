import 'dart:io';

import 'package:flutter/foundation.dart';

class ScriptRunner {
  static const scriptsPathPrefix = kDebugMode ? "" : "data/flutter_assets/";

  static Future<ProcessResult> runPythonScript(String scriptPath, {List<String>? args}) async {
    return await Process.run("python", ["$scriptsPathPrefix$scriptPath", ...?args]);
  }
}
