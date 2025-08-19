import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdherenceChartCard extends StatefulWidget {
  final List<Map<String, dynamic>> chartData;
  final String selectedPeriod;

  const AdherenceChartCard({
    super.key,
    required this.chartData,
    required this.selectedPeriod,
  });

  @override
  State<AdherenceChartCard> createState() => _AdherenceChartCardState();
}

class _AdherenceChartCardState extends State<AdherenceChartCard> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Padding(
            padding: EdgeInsets.all(4.w),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CustomIconWidget(
                    iconName: 'show_chart',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 6.w),
                SizedBox(width: 3.w),
                Text('Adherence Trends',
                    style: AppTheme.lightTheme.textTheme.titleMedium),
                Spacer(),
                Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2.w)),
                    child: Text(widget.selectedPeriod,
                        style: AppTheme.lightTheme.textTheme.labelSmall
                            ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.primary,
                                fontWeight: FontWeight.w500))),
              ]),
              SizedBox(height: 3.h),
              Container(
                  height: 30.h,
                  child: Semantics(
                      label:
                          "Adherence Trends Line Chart for ${widget.selectedPeriod}",
                      child: LineChart(LineChartData(
                          gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 20,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                    color: AppTheme
                                        .lightTheme.colorScheme.outline
                                        .withValues(alpha: 0.2),
                                    strokeWidth: 1);
                              }),
                          titlesData: FlTitlesData(
                              show: true,
                              rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 30,
                                      interval:
                                          widget.chartData.length > 7 ? 2 : 1,
                                      getTitlesWidget:
                                          (double value, TitleMeta meta) {
                                        if (value.toInt() >= 0 &&
                                            value.toInt() <
                                                widget.chartData.length) {
                                          final data =
                                              widget.chartData[value.toInt()];
                                          return SideTitleWidget(
                                              axisSide: meta.axisSide,
                                              child: Text(
                                                  data['label'] as String,
                                                  style: AppTheme.lightTheme
                                                      .textTheme.labelSmall));
                                        }
                                        return Container();
                                      })),
                              leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 25,
                                      getTitlesWidget:
                                          (double value, TitleMeta meta) {
                                        return Text('${value.toInt()}%',
                                            style: AppTheme.lightTheme.textTheme
                                                .labelSmall);
                                      },
                                      reservedSize: 42))),
                          borderData: FlBorderData(
                              show: true,
                              border: Border(
                                  bottom: BorderSide(
                                      color: AppTheme
                                          .lightTheme.colorScheme.outline
                                          .withValues(alpha: 0.2)),
                                  left: BorderSide(
                                      color: AppTheme
                                          .lightTheme.colorScheme.outline
                                          .withValues(alpha: 0.2)))),
                          minX: 0,
                          maxX: (widget.chartData.length - 1).toDouble(),
                          minY: 0,
                          maxY: 100,
                          lineBarsData: [
                            LineChartBarData(
                                spots: widget.chartData
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  return FlSpot(
                                      entry.key.toDouble(),
                                      (entry.value['adherence'] as double)
                                          .clamp(0.0, 100.0));
                                }).toList(),
                                isCurved: true,
                                gradient: LinearGradient(colors: [
                                  AppTheme.lightTheme.colorScheme.primary,
                                  AppTheme.lightTheme.colorScheme.secondary,
                                ]),
                                barWidth: 3,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                          radius: touchedIndex == index ? 6 : 4,
                                          color: AppTheme
                                              .lightTheme.colorScheme.primary,
                                          strokeWidth: 2,
                                          strokeColor: AppTheme
                                              .lightTheme.colorScheme.surface);
                                    }),
                                belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                        colors: [
                                          AppTheme
                                              .lightTheme.colorScheme.primary
                                              .withValues(alpha: 0.3),
                                          AppTheme
                                              .lightTheme.colorScheme.primary
                                              .withValues(alpha: 0.1),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter))),
                          ],
                          lineTouchData: LineTouchData(
                              enabled: true,
                              touchCallback: (FlTouchEvent event,
                                  LineTouchResponse? touchResponse) {
                                setState(() {
                                  if (touchResponse != null &&
                                      touchResponse.lineBarSpots != null) {
                                    touchedIndex = touchResponse
                                        .lineBarSpots!.first.spotIndex;
                                  } else {
                                    touchedIndex = -1;
                                  }
                                });
                              },
                              touchTooltipData: LineTouchTooltipData(
                                  tooltipRoundedRadius: 8,
                                  getTooltipItems:
                                      (List<LineBarSpot> touchedBarSpots) {
                                    return touchedBarSpots.map((barSpot) {
                                      final flSpot = barSpot;
                                      if (flSpot.x.toInt() <
                                          widget.chartData.length) {
                                        final data =
                                            widget.chartData[flSpot.x.toInt()];
                                        return LineTooltipItem(
                                            '${data['label']}\n${flSpot.y.toStringAsFixed(1)}%',
                                            AppTheme.lightTheme.textTheme
                                                .labelMedium!
                                                .copyWith(
                                                    color: AppTheme.lightTheme
                                                        .colorScheme.onSurface,
                                                    fontWeight:
                                                        FontWeight.w600));
                                      }
                                      return null;
                                    }).toList();
                                  })))))),
              SizedBox(height: 2.h),
              Text('Touch any point to view detailed adherence data',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant)),
            ])));
  }
}
