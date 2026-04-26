import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/api.g.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/app/src/main/kotlin/com/jboycode/pigeon_demo/Api.g.kt',
  kotlinOptions: KotlinOptions(
    package: 'com.jboycode.pigeon_demo',
  ),
  swiftOut: 'ios/Runner/BatteryApi.swift',
))
@HostApi()
abstract class BatteryApi {
  int getBatteryLevel();
}
