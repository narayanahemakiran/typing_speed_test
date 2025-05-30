import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const TypingTestApp());
}

class TypingTestApp extends StatelessWidget {
  const TypingTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Typing Speed Test',
      home: TypingHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TypingHomePage extends StatefulWidget {
  @override
  _TypingHomePageState createState() => _TypingHomePageState();
}

class _TypingHomePageState extends State<TypingHomePage> {
  final List<Level> levels = [
    Level(
        'Easy',
        ["cat dog pen sun map tree lamp milk note fish"],
        70,
        'https://youtu.be/8Ic2L7ZyFC8?si=KeSmGw7KLTxosPtT'),
    Level(
        'Medium',
        [
          "How are you doing today? I hope you're having a nice day.",
          "It's always a pleasure to meet new people in the community."
        ],
        75,
        'https://youtu.be/tuWFNrfjy-c?si=U9wq2M6lzrjdG7uU'),
    Level(
        'Hard',
        [
          "I bought 3 apples and 5 oranges for \$10.50 at the market.",
          "The temperature today is 25.6°C, perfect for a walk outside."
        ],
        80,
        'https://youtu.be/QAb3ATOpBpE?si=mNavarvEkUG72354'),
    Level(
        'Advanced',
        [
          "Meet me at 5:30 p.m.! Don't forget the \$15.00 payment @ counter #4.",
          "Access granted: use key *9A#6D! and enter the secure vault."
        ],
        85,
        'https://youtu.be/tU_AXrvQjpo?si=QwsGz56VQmcBxbY1'),
  ];

  int currentLevel = 0;
  String currentText = "";
  String userInput = "";
  Stopwatch stopwatch = Stopwatch();
  Timer? timer;
  int elapsedSeconds = 0;
  List<int> accuracyProgress = [];

  @override
  void initState() {
    super.initState();
    _startLevel();
  }

  @override
  void dispose() {
    timer?.cancel(); // Dispose of the timer to avoid memory leaks
    super.dispose();
  }

  void _startLevel() {
    setState(() {
      currentText = levels[currentLevel].getRandomText();
      userInput = "";
      elapsedSeconds = 0;
      accuracyProgress.clear();
      stopwatch.reset();
      stopwatch.start();
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 1), (_) {
        setState(() {
          elapsedSeconds++;
          accuracyProgress.add(_calculateAccuracy());
        });
      });
    });
  }

  int _calculateAccuracy() {
  int correct = 0;
  int len = min(currentText.length, userInput.length);
  for (int i = 0; i < len; i++) {
    if (currentText[i] == userInput[i]) correct++;
  }
  return ((correct / currentText.length) * 100).round();
}

  double _calculateWPM() {
    if (elapsedSeconds == 0) return 0;
    return (userInput.length / 5) / (elapsedSeconds / 60);
  }

  void _submit() {
    stopwatch.stop();
    timer?.cancel();
    final accuracy = _calculateAccuracy();
    if (accuracy >= levels[currentLevel].minAccuracy) {
      if (currentLevel < levels.length - 1) {
        setState(() => currentLevel++);
        _startLevel();
      } else {
        _showResultDialog("🎉 All levels completed!");
      }
    } else {
      _showResultDialog("❌ Failed! Try again.");
    }
  }

  void _showResultDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Result"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() => currentLevel = 0);
              _startLevel();
            },
            child: const Text("Restart"),
          ),
        ],
      ),
    );
  }

  Future<void> _launchVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch video')),
      );
    }
  }

  Widget _buildChart() {
    return accuracyProgress.length < 2
        ? const Text("Graph will appear after a few seconds of typing.")
        : SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                ),
                gridData: FlGridData(show: true),
                borderData: FlBorderData(show: true),
                lineBarsData: [
                  LineChartBarData(
                    spots: accuracyProgress
                        .asMap()
                        .entries
                        .map((entry) =>
                            FlSpot(entry.key.toDouble(), entry.value.toDouble()))
                        .toList(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    belowBarData: BarAreaData(show: false),
                    dotData: FlDotData(show: true),
                  )
                ],
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    final level = levels[currentLevel];

    return Scaffold(
      appBar: AppBar(title: Text("Level: ${level.name}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.play_circle_fill),
                label: Text("Watch Guide for ${level.name}"),
                onPressed: () => _launchVideo(level.videoUrl),
              ),
              const SizedBox(height: 20),
              const Text("Type this:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Text(currentText,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                maxLines: null,
                onChanged: (val) => setState(() => userInput = val),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Start typing here...',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text("Submit")),
              const SizedBox(height: 20),
              Text("Time: $elapsedSeconds sec"),
              Text("Accuracy: ${_calculateAccuracy()}%"),
              Text("WPM: ${_calculateWPM().round()}"),
              const Divider(),
              const Text("Accuracy Graph",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              _buildChart(),
            ],
          ),
        ),
      ),
    );
  }
}

class Level {
  final String name;
  final List<String> texts;
  final int minAccuracy;
  final String videoUrl;

  Level(this.name, this.texts, this.minAccuracy, this.videoUrl);

  String getRandomText() => (texts..shuffle()).first;
}