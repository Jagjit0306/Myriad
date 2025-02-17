import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:myriad/helper/mental_health.dart';
import 'package:myriad/helper/medication_response_helper.dart';
import 'package:myriad/models/medicine_data.dart';

class NotifyPage extends StatefulWidget {
  const NotifyPage({Key? key}) : super(key: key);

  @override
  State<NotifyPage> createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> with WidgetsBindingObserver {
  final MentalHealthAnalyzer _analyzer = MentalHealthAnalyzer();
  int _mentalHealthScore = 0;
  bool mentalHealthIsLoading = true;
  List<MedicineData> _chartData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateMentalHealthScore();
    _loadMedicationData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadMedicationData();
    }
  }

  Future<void> _loadMedicationData() async {
    final data = await MedicationResponseHelper.getWeeklyConsistency();
    setState(() {
      _chartData = data;
    });
    
    print('Loaded chart data: $_chartData'); // Debugging line
  }

  Future<void> _updateMentalHealthScore() async {
    final score = await _analyzer.analyzeMentalHealth();
    setState(() {
      _mentalHealthScore = score;
      mentalHealthIsLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notify'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Medicine Consistency',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Last 7 Days',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 200,
                child: SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  primaryXAxis: NumericAxis(
                    minimum: 0,
                    maximum: 7,
                    interval: 1,
                    majorGridLines: const MajorGridLines(width: 0),
                    axisLine: const AxisLine(width: 1, color: Colors.grey),
                    labelStyle: const TextStyle(color: Colors.grey),
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 0,
                    maximum: 20,
                    interval: 2,
                    axisLine: const AxisLine(width: 1, color: Colors.grey),
                    majorGridLines: const MajorGridLines(width: 0),
                    labelStyle: const TextStyle(color: Colors.grey),
                  ),
                  series: <CartesianSeries>[
                    SplineSeries<MedicineData, int>(
                      dataSource: _chartData,
                      xValueMapper: (MedicineData data, _) => data.day,
                      yValueMapper: (MedicineData data, _) => data.value,
                      color: Theme.of(context).colorScheme.inversePrimary,
                      width: 2,
                      markerSettings: MarkerSettings(
                        isVisible: true,
                        color: Theme.of(context).colorScheme.secondary,
                        shape: DataMarkerType.circle,
                        borderColor: Colors.white,
                        borderWidth: 1,
                      ),
                    ),
                  ],
                  tooltipBehavior: TooltipBehavior(enable: true),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Card(
                  color: Theme.of(context).colorScheme.secondary,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: Column(
                      children: [
                        Text(
                          'Mental Health',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
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
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.inversePrimary),
                              ),
                            ),
                            Column(
                              children: [
                                Text(
                                  mentalHealthIsLoading
                                      ? "- -"
                                      : _mentalHealthScore.toString(),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.inversePrimary,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  mentalHealthIsLoading
                                      ? "Analyzing"
                                      : _getMentalHealthStatus(_mentalHealthScore),
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.inversePrimary,
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
                ),
              ),
            ],
          ),
        ),
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