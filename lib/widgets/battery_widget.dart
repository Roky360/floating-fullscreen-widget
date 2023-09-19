import 'package:flutter/material.dart';
import 'package:battery_plus/battery_plus.dart';

class BatteryResult {
  final Color displayColor;
  final int percentage;
  final bool isCharging;
  final bool isInSaveMode;
  final bool isFull;

  BatteryResult({
    required this.displayColor,
    required this.percentage,
    required this.isCharging,
    required this.isInSaveMode,
    required this.isFull,
  });
}

class BatteryWidget extends StatelessWidget {
  BatteryWidget({super.key});

  final Battery battery = Battery();
  final Color superLowColor = Colors.red;
  final Color lowColor = Colors.orange;
  final Color chargingColor = Colors.green;
  final Color defaultColor = Colors.white;
  final Color fullColor = Colors.tealAccent;
  final Color batterySaverColor = Colors.orangeAccent;

  Future<BatteryResult> getBatteryPercentage() async {
    final perc = await battery.batteryLevel;
    final state = await battery.batteryState;
    final saveMode = await battery.isInBatterySaveMode;
    bool isFull = false;
    bool isCharging = false;

    late final Color color;
    if (saveMode) {
      color = batterySaverColor;
    } else {
      switch (state) {
        case BatteryState.charging:
          isCharging = true;
          color = chargingColor;
          break;
        case BatteryState.discharging:
          if (perc <= 10) {
            color = superLowColor;
          } else if (perc <= 20) {
            color = lowColor;
          } else {
            color = defaultColor;
          }
          break;
        case BatteryState.full:
          isFull = true;
          color = fullColor;
          break;
        default:
          color = defaultColor;
          break;
      }
    }

    return BatteryResult(
      displayColor: color,
      percentage: perc,
      isCharging: isCharging,
      isInSaveMode: saveMode,
      isFull: isFull,
    );
  }

  Widget getIcon(BatteryResult res) {
    const double size = 16;

    if (res.isCharging) {
      return Icon(Icons.bolt, color: chargingColor, size: size);
    } else if (res.isFull) {
      return Icon(Icons.battery_charging_full, color: fullColor, size: size);
    } else if (res.isInSaveMode) {
      return Icon(Icons.energy_savings_leaf, color: batterySaverColor, size: size);
    } else {
      return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getBatteryPercentage(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final BatteryResult data = snapshot.data!;
          final icon = getIcon(data);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(right: icon is SizedBox ? 0 : 2),
                child: icon,
              ),
              Text(
                "${data.percentage}%",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: data.displayColor, fontSize: 14),
              ),
            ],
          );
        } else {
          return const Text("");
        }
      },
    );
  }
}
