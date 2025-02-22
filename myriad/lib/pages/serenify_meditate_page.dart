import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:myriad/components/my_chips.dart';

class SerenifyMeditatePage extends StatefulWidget {
  const SerenifyMeditatePage({super.key});

  @override
  State<SerenifyMeditatePage> createState() => _SerenifyMeditatePageState();
}

class _SerenifyMeditatePageState extends State<SerenifyMeditatePage>
    with TickerProviderStateMixin {
  bool isMeditating = false;
  DateTime? startTime;
  late Timer timer;
  String elapsedTime = '00:00';
  late List<ShapeData> shapes;
  final int numberOfShapes = 6;
  final random = math.Random();
  final double minDuration = 20.0; // Slowest animation (more seconds = slower)
  final double maxDuration = 30.0; // Fastest animation (more seconds = slower)
  final double slowBlobChance = 0.4; // 40% chance for a blob to be slow

  final List<dynamic> audios = [
    {'Angelic': true},
    {'Rain': false},
    {'Chirping': false},
    {'Bells': false},
    {'Bowls': false},
    {'Kalimba': false},
    {'Vocal': false},
  ];
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    initializeShapes();
    _audioPlayer = AudioPlayer();

    // Listen for audio completion
    _audioPlayer.onPlayerComplete.listen((event) {
      if (isMeditating) {
        _restartAudio();
      }
    });
  }

  void _restartAudio() async {
    await _audioPlayer.stop(); // Stop any previous playback
    await _audioPlayer.setSource(AssetSource('${getAudio()}.mp3'));
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.resume();
  }

  String getAudio() {
    for (int i = 0; i < audios.length; i++) {
      if (audios[i].values.first) {
        return audios[i].keys.first.toString().toLowerCase();
      }
    }
    return '';
  }

  void _toggleMusic() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      _restartAudio();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  /// Generates a random path with one of several curve types.
  List<Offset> generateRandomPath(
      double centerX, double centerY, double maxRadius) {
    final pathType = random.nextInt(4);
    final points = <Offset>[];
    final numPoints = 8; // fewer control points for a smoother spline

    // Use the provided maxRadius instead of a random one
    final radius = (0.15 + random.nextDouble() * 0.1).clamp(0.0, maxRadius);
    final frequency1 = 1 + random.nextInt(3); // reduced max frequency
    final frequency2 = 1 + random.nextInt(3); // reduced max frequency
    final phase = random.nextDouble() * math.pi * 2;

    for (int i = 0; i < numPoints; i++) {
      final progress = i / numPoints;
      final angle = progress * math.pi * 2 + phase;
      double x = centerX;
      double y = centerY;

      switch (pathType) {
        case 0: // Lissajous curve
          x += radius * math.sin(frequency1 * angle);
          y += radius * math.cos(frequency2 * angle);
          break;
        case 1: // Figure-8
          x += radius * math.sin(2 * angle);
          y += radius * math.sin(angle);
          break;
        case 2: // Spiral
          final spiral = radius * (1 - progress * 0.5);
          x += spiral * math.cos(angle * 3);
          y += spiral * math.sin(angle * 3);
          break;
        case 3: // Rose curve
          final k = random.nextInt(5) + 2;
          final r = radius * math.cos(k * angle);
          x += r * math.cos(angle);
          y += r * math.sin(angle);
          break;
      }

      // Add some randomness to the path
      x += math.sin(angle * 3) * radius * 0.2;
      y += math.cos(angle * 2) * radius * 0.2;

      points.add(Offset(x, y));
    }

    // Ensure the path is closed
    points.add(points.first);
    return points;
  }

  /// Initialize shapes and set up their animation controllers.
  void initializeShapes() {
    shapes = List.generate(numberOfShapes, (index) {
      final centerX = 0.3 + random.nextDouble() * 0.4;
      final centerY = 0.3 + random.nextDouble() * 0.4;

      // Determine if this blob should be slow
      final isSlowBlob = random.nextDouble() < slowBlobChance;

      // Calculate duration - slower blobs take longer to complete their path
      final duration = isSlowBlob
          ? maxDuration + random.nextDouble() * 10 // Slow blobs: 30-40 seconds
          : minDuration + random.nextDouble() * 5; // Normal blobs: 20-25 seconds

      return ShapeData(
        controller: AnimationController(
          duration: Duration(seconds: duration.round()),
          vsync: this,
        ),
        size: 50.0 + random.nextDouble() * 100,
        points: 3 + random.nextInt(5),
        variance: 5 + random.nextDouble() * 15,
        pathPoints: generateRandomPath(
          centerX,
          centerY,
          isSlowBlob ? 0.15 : 0.25, // Smaller radius for slow blobs
        ),
        color: HSLColor.fromAHSL(
          0.6,
          random.nextDouble() * 360,
          0.6 + random.nextDouble() * 0.2,
          0.6 + random.nextDouble() * 0.2,
        ).toColor(),
      );
    });

    // Start continuous animations
    for (var shape in shapes) {
      shape.controller.repeat();
    }
  }

  /// Returns a smoothly interpolated position on the path using Catmull-Rom spline.
  Offset getSmoothPositionOnPath(List<Offset> path, double t) {
    // Number of segments equals number of control points (assuming closed loop)
    final n = path.length;
    // Scale t to the number of segments.
    final totalSegments = n - 1;
    final segment = (t * totalSegments).floor();
    // local parameter within the segment [0,1]
    final localT = (t * totalSegments) - segment;

    // Wrap indices around for closed-loop Catmull-Rom
    Offset p0 = path[(segment - 1 + n) % n];
    Offset p1 = path[segment % n];
    Offset p2 = path[(segment + 1) % n];
    Offset p3 = path[(segment + 2) % n];

    // Catmull-Rom spline formula
    double tt = localT;
    double tt2 = tt * tt;
    double tt3 = tt2 * tt;

    double x = 0.5 *
        ((2 * p1.dx) +
            (-p0.dx + p2.dx) * tt +
            (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * tt2 +
            (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * tt3);

    double y = 0.5 *
        ((2 * p1.dy) +
            (-p0.dy + p2.dy) * tt +
            (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * tt2 +
            (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * tt3);

    return Offset(x, y);
  }

  @override
  void dispose() {
    for (var shape in shapes) {
      shape.controller.dispose();
    }
    if (isMeditating) {
      timer.cancel();
    }
    _audioPlayer.dispose();
    super.dispose();
  }

  void toggleMeditation() {
    _toggleMusic();
    setState(() {
      isMeditating = !isMeditating;
      if (isMeditating) {
        startTime = DateTime.now();
        timer = Timer.periodic(const Duration(seconds: 1), updateTimer);
        for (var shape in shapes) {
          shape.controller.repeat();
        }
      } else {
        timer.cancel();
        elapsedTime = '00:00';
        for (var shape in shapes) {
          shape.controller.stop();
        }
      }
    });
  }

  void updateTimer(Timer timer) {
    final difference = DateTime.now().difference(startTime!);
    setState(() {
      elapsedTime =
          '${difference.inMinutes.toString().padLeft(2, '0')}:${(difference.inSeconds % 60).toString().padLeft(2, '0')}';
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A237E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1A237E), Color(0xFF000051)],
              ),
            ),
          ),
          if (isMeditating)
            ...shapes.map((shape) {
              return AnimatedBuilder(
                animation: shape.controller,
                builder: (context, child) {
                  // Wrap the raw controller value with an easing curve for more natural motion.
                  final easedValue = Curves.easeInOut.transform(shape.controller.value);
                  final position =
                      getSmoothPositionOnPath(shape.pathPoints, easedValue);

                  return Positioned(
                    left: position.dx * size.width - shape.size / 2,
                    top: position.dy * size.height - shape.size / 2,
                    child: CustomPaint(
                      painter: BlobPainter(
                        color: shape.color,
                        progress: shape.controller.value,
                        points: shape.points,
                        variance: shape.variance,
                      ),
                      size: Size(shape.size, shape.size),
                    ),
                  );
                },
              );
            }),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  elapsedTime,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: toggleMeditation,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: Colors.white.withOpacity(0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    isMeditating ? 'End Meditation' : 'Start Meditation',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isMeditating)
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.max,
              children: [
                MyChips(
                  categories: audios,
                  updateChips: (currAud, index) {
                    setState(() {
                      for (int i = 0; i < audios.length; i++) {
                        audios[i] = {audios[i].keys.first: false};
                      }
                      audios[index] = {
                        currAud.keys.first: !currAud.values.first
                      };
                    });
                  },
                ),
              ],
            )
        ],
      ),
    );
  }
}

class ShapeData {
  final AnimationController controller;
  final double size;
  final int points;
  final double variance;
  final List<Offset> pathPoints;
  final Color color;

  ShapeData({
    required this.controller,
    required this.size,
    required this.points,
    required this.variance,
    required this.pathPoints,
    required this.color,
  });
}

class BlobPainter extends CustomPainter {
  final Color color;
  final double progress;
  final int points;
  final double variance;

  BlobPainter({
    required this.color,
    required this.progress,
    required this.points,
    required this.variance,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    for (var i = 0; i <= 360; i++) {
      final angle = i * math.pi / 180;
      final currentVariance =
          math.sin(angle * points + progress * 2 * math.pi) * variance +
          math.cos(angle * (points - 1) + progress * 3 * math.pi) * variance * 0.5;

      final x = center.dx + (radius + currentVariance) * math.cos(angle);
      final y = center.dy + (radius + currentVariance) * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BlobPainter oldDelegate) =>
      color != oldDelegate.color ||
      progress != oldDelegate.progress ||
      points != oldDelegate.points ||
      variance != oldDelegate.variance;
}