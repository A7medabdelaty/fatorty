import 'package:flutter/material.dart';
import '../../constants/colour.dart';
import '../../constants/widgets.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsAnalyticsScreen extends StatefulWidget {
  const ReportsAnalyticsScreen({super.key});

  @override
  State<ReportsAnalyticsScreen> createState() => _ReportsAnalyticsScreenState();
}

class _ReportsAnalyticsScreenState extends State<ReportsAnalyticsScreen> {
  String _selectedPeriod = 'اليوم';
  final List<String> _periods = ['اليوم', 'الأسبوع', 'الشهر', 'السنة'];

  // بيانات وهمية للإحصائيات
  final Map<String, dynamic> _stats = {
    'إجمالي المبيعات': 2500.0,
    'عدد التأجيرات': 45,
    'متوسط القيمة ': 55.5,
    'عدد العملاء': 38,
  };

  // بيانات وهمية للرسم البياني
  final List<FlSpot> _salesData = [
    const FlSpot(0, 300),
    const FlSpot(1, 450),
    const FlSpot(2, 350),
    const FlSpot(3, 500),
    const FlSpot(4, 400),
    const FlSpot(5, 550),
    const FlSpot(6, 450),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'التقارير والتحليلات',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // اختيار الفترة الزمنية
            DropdownButtonFormField<String>(
              value: _selectedPeriod,
              decoration: const InputDecoration(
                labelText: 'الفترة الزمنية',
                border: OutlineInputBorder(),
              ),
              items: _periods.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(period),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPeriod = value);
                }
              },
            ),
            const SizedBox(height: 24),

            // الإحصائيات
            const Text(
              'الإحصائيات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.5,
              children: _stats.entries.map((entry) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          entry.value is double
                              ? '${entry.value.toStringAsFixed(2)} ريال'
                              : entry.value.toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            color: AppColors.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // الرسم البياني
            const Text(
              'المبيعات',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _salesData,
                      isCurved: true,
                      color: AppColors.primaryColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primaryColor.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
