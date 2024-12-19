# Pigeon Demo - バッテリー残量取得アプリ

## 概要
FlutterでiOSとAndroidのネイティブAPIを使用してバッテリー残量を取得し、アニメーション付きで表示するデモアプリです。

## セットアップ手順

### 1. プロジェクト作成
```bash
flutter create pigeon_demo
cd pigeon_demo
```

### 2. 依存関係の追加
`pubspec.yaml`に以下を追加：
```yaml
dev_dependencies:
  pigeon: ^22.7.0  # 最新バージョンを使用
```

### 3. ディレクトリ構造の作成
```bash
mkdir pigeons
```

### 4. Pigeon API定義
`pigeons/api.dart`を作成：
```dart
import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/api.g.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/app/src/main/kotlin/com/jboycode/pigeon_demo/Api.g.kt',
  kotlinOptions: KotlinOptions(
    package: 'com.jboycode.pigeon_demo'
  ),
  swiftOut: 'ios/Runner/BatteryApi.swift',
))

@HostApi()
abstract class BatteryApi {
  int getBatteryLevel();
}
```

### 5. Android設定

1. `android/app/build.gradle`の設定：
```gradle
android {
    namespace = "com.jboycode.pigeon_demo"
    compileSdk = flutter.compileSdkVersion
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion flutter.targetSdkVersion
    }
}
```

2. `MainActivity.kt`の実装：
```kotlin
package com.jboycode.pigeon_demo

import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity(), BatteryApi {
    override fun getBatteryLevel(): Long {
        val batteryLevel: Int = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
            batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
        } else {
            val intent = ContextWrapper(applicationContext).registerReceiver(
                null,
                IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            )
            intent?.let { batteryIntent ->
                val level = batteryIntent.getIntExtra(BatteryManager.EXTRA_LEVEL, -1)
                val scale = batteryIntent.getIntExtra(BatteryManager.EXTRA_SCALE, -1)
                level * 100 / scale
            } ?: -1
        }
        return batteryLevel.toLong()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        BatteryApi.setUp(flutterEngine.dartExecutor.binaryMessenger, this)
    }
}
```

### 6. iOS設定

1. `ios/Runner/Info.plist`に権限を追加：
```xml
<key>NSBluetoothAlwaysUsageDescription</key>
<string>Need BLE permission for device scanning</string>
<key>NSBluetoothPeripheralUsageDescription</key>
<string>Need BLE permission for device scanning</string>
```

2. `AppDelegate.swift`の実装：
```swift
import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, BatteryApi {
    func getBatteryLevel() -> Int64 {
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = UIDevice.current.batteryLevel
        UIDevice.current.isBatteryMonitoringEnabled = false
        
        if batteryLevel < 0 {
            return -1
        }
        
        return Int64(batteryLevel * 100)
    }
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        BatteryApiSetup.setUp(binaryMessenger: window?.rootViewController as! FlutterBinaryMessenger, api: self)
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
```

### 7. ビルドと実行手順

1. Makefileの作成（オプション）：
```makefile
.PHONY: setup
setup:
	@flutter clean
	@flutter pub get

.PHONY: pigeon
pigeon:
	@dart run pigeon --input pigeons/api.dart
```

2. コマンド実行：
```bash
# プロジェクトのセットアップ
make setup

# Pigeonコードの生成
make pigeon

# アプリの実行
flutter run
```

## 注意点
- iOS実機でのテスト時は、適切な署名が必要です
- Androidの`namespace`とPigeonの`package`名が一致している必要があります
- 生成されたコードは手動で修正しないでください
- 実機テストを推奨します（特にiOS）

## トラブルシューティング
- ビルドエラーが発生した場合は、`flutter clean`を実行してから再度ビルドしてください
- コードが生成されない場合は、pigeonコマンドを再実行してください
- パッケージ名の不一致エラーが出た場合は、すべての設定ファイルで同じパッケージ名を使用しているか確認してください