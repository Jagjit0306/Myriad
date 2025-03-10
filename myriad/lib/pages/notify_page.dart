import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:myriad/helper/mental_health.dart';
import 'package:myriad/helper/medify_functions.dart';
import 'package:intl/intl.dart';

class NotifyPage extends StatefulWidget {
  final bool hideMediGraph;
  const NotifyPage({
    super.key,
    this.hideMediGraph = false,
  });

  @override
  State<NotifyPage> createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> {
  final MentalHealthAnalyzer _analyzer = MentalHealthAnalyzer();
  final MedifyHistory _medifyHistory = MedifyHistory();
  late final MedifyConsistencyCalculator _consistencyCalculator;

  int _mentalHealthScore = 0;
  bool mentalHealthIsLoading = true;
  List<DailyConsistency> _consistencyData = [];
  bool _isLoading = true;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _consistencyCalculator = MedifyConsistencyCalculator(_medifyHistory);
    _updateMentalHealthScore();
    _loadConsistencyData();
  }

  Future<void> _updateMentalHealthScore() async {
    final score = await _analyzer.analyzeMentalHealth();
    setState(() {
      _mentalHealthScore = score;
      mentalHealthIsLoading = false;
    });
  }

  Future<void> _loadConsistencyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get consistency data from MedifyHistory
      final data = await _consistencyCalculator.getConsistencyForLastWeek();
      final streak = await _consistencyCalculator.calculateConsistencyStreak();

      setState(() {
        _consistencyData = data;
        _streak = streak;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading consistency data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Here is your overview",
            style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 15,
          ),
          if (!widget.hideMediGraph)
            Stack(
              children: [
                Card(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Medicine Consistency',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          _isLoading ? 'Calculating...' : '$_streak Days',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inversePrimary,
                                ),
                              )
                            : SizedBox(
                                height: 200,
                                child: SfCartesianChart(
                                  plotAreaBorderWidth: 0,
                                  primaryXAxis: DateTimeAxis(
                                    dateFormat: DateFormat.d(),
                                    intervalType: DateTimeIntervalType.days,
                                    interval: 1,
                                    majorGridLines: const MajorGridLines(
                                        width: 1, color: Colors.grey),
                                    axisLine: const AxisLine(width: 0),
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                  ),
                                  primaryYAxis: NumericAxis(
                                    minimum: 0,
                                    maximum: 100,
                                    plotOffset: 20,
                                    interval: 20,
                                    axisLine: const AxisLine(width: 0),
                                    majorGridLines: const MajorGridLines(
                                        width: 1, color: Colors.grey),
                                    labelStyle:
                                        const TextStyle(color: Colors.grey),
                                    labelFormat: '{value}%',
                                  ),
                                  series: <CartesianSeries>[
                                    SplineSeries<DailyConsistency, DateTime>(
                                      dataSource: _consistencyData,
                                      xValueMapper:
                                          (DailyConsistency data, _) =>
                                              data.date,
                                      yValueMapper:
                                          (DailyConsistency data, _) =>
                                              data.percentage,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .inversePrimary,
                                      width: 2,
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                                        borderWidth: 2,
                                        borderColor: Theme.of(context)
                                            .colorScheme
                                            .onSecondary,
                                      ),
                                    ),
                                  ],
                                  tooltipBehavior: TooltipBehavior(
                                    enable: true,
                                    format:
                                        'Day {point.x}: {point.y.toStringAsFixed(1)}%',
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      // _updateMentalHealthScore();
                      _loadConsistencyData();
                    },
                    icon: Icon(
                      Icons.refresh_rounded,
                      color: Theme.of(context).colorScheme.inversePrimary,
                      semanticLabel: "Refresh data",
                    ),
                  ),
                ),
              ],
            ),
          if (!widget.hideMediGraph) const SizedBox(height: 20),
          Center(
            child: Card(
              color: Theme.of(context).colorScheme.secondary,
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          'Mental Health',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: 150,
                              width: 150,
                              child: CircularProgressIndicator(
                                value: _mentalHealthScore / 100,
                                strokeWidth: 12,
                                backgroundColor:
                                    Theme.of(context).colorScheme.primary,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context)
                                        .colorScheme
                                        .inversePrimary),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  mentalHealthIsLoading
                                      ? "- -"
                                      : _mentalHealthScore.toString(),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  mentalHealthIsLoading
                                      ? "analysing"
                                      : _getMentalHealthStatus(
                                          _mentalHealthScore),
                                  style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inversePrimary,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      onPressed: () {
                        _updateMentalHealthScore();
                        // _loadConsistencyData();
                      },
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: Theme.of(context).colorScheme.inversePrimary,
                        semanticLabel: "Refresh data",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMentalHealthStatus(int score) {
    if (score >= 80) return 'Excellent';
    if (score >= 60) return 'Good';
    if (score >= 40) return 'Fair';
    if (score >= 20) return 'Needs Attention';
    return 'Seek Support';
  }
}
