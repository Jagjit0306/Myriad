import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:myriad/helper/mental_health.dart';

class NotifyPage extends StatefulWidget {
  const NotifyPage({Key? key}) : super(key: key);

  @override
  State<NotifyPage> createState() => _NotifyPageState();
}

class _NotifyPageState extends State<NotifyPage> {
  final MentalHealthAnalyzer _analyzer = MentalHealthAnalyzer();
  int _mentalHealthScore = 0;
  bool mentalHealthIsLoading = true;

  @override
  void initState() {
    super.initState();
    _updateMentalHealthScore();
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
    // Sample data for the past 7 days
    final List<MedicineData> chartData = [
      MedicineData(10, 4200),
      MedicineData(11, 4000),
      MedicineData(12, 4300),
      MedicineData(13, 4500),
      MedicineData(14, 4100),
      MedicineData(15, 4400),
      MedicineData(16, 4200),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notify'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Medicine Consistency',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                '5 Days',
                style: TextStyle(
                  color: Colors.grey,
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
                    minimum: 10,
                    maximum: 16,
                    interval: 1,
                    majorGridLines:
                        const MajorGridLines(width: 1, color: Colors.grey),
                    axisLine: const AxisLine(width: 0),
                    labelStyle: const TextStyle(color: Colors.grey),
                  ),
                  primaryYAxis: NumericAxis(
                    minimum: 3500,
                    maximum: 5000,
                    interval: 500,
                    axisLine: const AxisLine(width: 0),
                    majorGridLines:
                        const MajorGridLines(width: 1, color: Colors.grey),
                    labelStyle: const TextStyle(color: Colors.grey),
                  ),
                  series: <CartesianSeries>[
                    SplineSeries<MedicineData, int>(
                      dataSource: chartData,
                      xValueMapper: (MedicineData data, _) => data.day,
                      yValueMapper: (MedicineData data, _) => data.value,
                      color: Colors.white,
                      width: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Mental Health',
                        style: TextStyle(
                          color: Colors.white,
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
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          ),
                          Column(
                            children: [
                              Text(
                                mentalHealthIsLoading
                                    ? "- -"
                                    : _mentalHealthScore.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                mentalHealthIsLoading
                                    ? "analysing"
                                    : _getMentalHealthStatus(
                                        _mentalHealthScore),
                                style: const TextStyle(
                                  color: Colors.white,
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

class MedicineData {
  final int day;
  final double value;

  MedicineData(this.day, this.value);
}
