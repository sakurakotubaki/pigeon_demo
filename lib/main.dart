import 'package:flutter/material.dart';
import 'package:pigeon_demo/api.g.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Battery Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const BatteryPage(),
    );
  }
}

class BatteryPainter extends CustomPainter {
  final double batteryLevel;
  final Color batteryColor;
  final double animationValue;

  BatteryPainter({
    required this.batteryLevel,
    required this.batteryColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // バッテリー本体の描画
    final RRect batteryBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height * 0.1, size.width * 0.9, size.height * 0.8),
      Radius.circular(10),
    );
    canvas.drawRRect(batteryBody, paint);

    // バッテリー端子の描画
    final terminalPath = Path()
      ..addRect(Rect.fromLTWH(
        size.width * 0.9,
        size.height * 0.35,
        size.width * 0.1,
        size.height * 0.3,
      ));
    canvas.drawPath(terminalPath, paint);

    // バッテリー残量の描画
    final levelPaint = Paint()
      ..color = batteryColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final levelWidth = (size.width * 0.85) * (batteryLevel / 100) * animationValue;
    final levelRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(5, size.height * 0.15, levelWidth, size.height * 0.7),
      Radius.circular(7),
    );
    canvas.drawRRect(levelRect, levelPaint);

    // パーセント表示
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${(batteryLevel * animationValue).toInt()}%',
        style: TextStyle(
          color: Colors.black,
          fontSize: size.height * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(BatteryPainter oldDelegate) {
    return oldDelegate.batteryLevel != batteryLevel ||
        oldDelegate.animationValue != animationValue;
  }
}

class BatteryPage extends StatefulWidget {
  const BatteryPage({super.key});

  @override
  State<BatteryPage> createState() => _BatteryPageState();
}

class _BatteryPageState extends State<BatteryPage>
    with SingleTickerProviderStateMixin {
  final _api = BatteryApi();
  double _batteryLevel = 0.0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _getBatteryLevel();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getBatteryLevel() async {
    try {
      final batteryLevel = await _api.getBatteryLevel();
      setState(() {
        _batteryLevel = batteryLevel.toDouble();
        _controller.forward(from: 0);
      });
    } catch (e) {
      setState(() {
        _batteryLevel = 0;
      });
    }
  }

  Color _getBatteryColor(double level) {
    if (level > 60) return Colors.green;
    if (level > 20) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery Level'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  width: 200,
                  height: 100,
                  child: CustomPaint(
                    painter: BatteryPainter(
                      batteryLevel: _batteryLevel,
                      batteryColor: _getBatteryColor(_batteryLevel),
                      animationValue: _animation.value,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getBatteryLevel,
              child: const Text('更新'),
            ),
          ],
        ),
      ),
    );
  }
}