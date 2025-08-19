import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MissedDosesAnalysisCard extends StatefulWidget {
  final Map<String, dynamic> missedDosesData;

  const MissedDosesAnalysisCard({
    super.key,
    required this.missedDosesData,
  });

  @override
  State<MissedDosesAnalysisCard> createState() =>
      _MissedDosesAnalysisCardState();
}

class _MissedDosesAnalysisCardState extends State<MissedDosesAnalysisCard>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getTimeColor(String timeOfDay) {
    switch (timeOfDay.toLowerCase()) {
      case 'morning':
        return AppTheme.lightTheme.colorScheme.tertiary;
      case 'afternoon':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'evening':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'night':
        return AppTheme.lightTheme.colorScheme.error;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  Color _getDayColor(String day) {
    final colors = [
      AppTheme.lightTheme.colorScheme.primary,
      AppTheme.lightTheme.colorScheme.secondary,
      AppTheme.lightTheme.colorScheme.tertiary,
      AppTheme.lightTheme.colorScheme.error,
      Colors.purple,
      Colors.orange,
      Colors.teal,
    ];
    final dayIndex = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ].indexOf(day);
    return dayIndex >= 0
        ? colors[dayIndex]
        : AppTheme.lightTheme.colorScheme.onSurfaceVariant;
  }

  Widget _buildTimeOfDayChart() {
    final timeData =
        widget.missedDosesData['timeOfDay'] as List<Map<String, dynamic>>;

    return Container(
        height: 25.h,
        child: Semantics(
            label: "Missed Doses by Time of Day Bar Chart",
            child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: timeData
                        .map((e) => e['count'] as int)
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() *
                    1.2,
                barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final data = timeData[group.x.toInt()];
                          return BarTooltipItem(
                              '${data['time']}\n${data['count']} missed doses',
                              AppTheme.lightTheme.textTheme.labelMedium!
                                  .copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600));
                        })),
                titlesData: FlTitlesData(
                    show: true,
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value.toInt() < timeData.length) {
                                return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(
                                        timeData[value.toInt()]['time']
                                            as String,
                                        style: AppTheme
                                            .lightTheme.textTheme.labelSmall));
                              }
                              return Container();
                            },
                            reservedSize: 30)),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(value.toInt().toString(),
                                  style:
                                      AppTheme.lightTheme.textTheme.labelSmall);
                            },
                            reservedSize: 28))),
                borderData: FlBorderData(show: false),
                barGroups: timeData.asMap().entries.map((entry) {
                  return BarChartGroupData(x: entry.key, barRods: [
                    BarChartRodData(
                        toY: (entry.value['count'] as int).toDouble(),
                        color: _getTimeColor(entry.value['time'] as String),
                        width: 8.w,
                        borderRadius: BorderRadius.circular(1.w)),
                  ]);
                }).toList()))));
  }

  Widget _buildDayOfWeekChart() {
    final dayData =
        widget.missedDosesData['dayOfWeek'] as List<Map<String, dynamic>>;

    return Container(
        height: 25.h,
        child: Semantics(
            label: "Missed Doses by Day of Week Bar Chart",
            child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: dayData
                        .map((e) => e['count'] as int)
                        .reduce((a, b) => a > b ? a : b)
                        .toDouble() *
                    1.2,
                barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                        tooltipRoundedRadius: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final data = dayData[group.x.toInt()];
                          return BarTooltipItem(
                              '${data['day']}\n${data['count']} missed doses',
                              AppTheme.lightTheme.textTheme.labelMedium!
                                  .copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.onSurface,
                                      fontWeight: FontWeight.w600));
                        })),
                titlesData: FlTitlesData(
                    show: true,
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value.toInt() < dayData.length) {
                                final day =
                                    dayData[value.toInt()]['day'] as String;
                                return SideTitleWidget(
                                    axisSide: meta.axisSide,
                                    child: Text(day.substring(0, 3),
                                        style: AppTheme
                                            .lightTheme.textTheme.labelSmall));
                              }
                              return Container();
                            },
                            reservedSize: 30)),
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              return Text(value.toInt().toString(),
                                  style:
                                      AppTheme.lightTheme.textTheme.labelSmall);
                            },
                            reservedSize: 28))),
                borderData: FlBorderData(show: false),
                barGroups: dayData.asMap().entries.map((entry) {
                  return BarChartGroupData(x: entry.key, barRods: [
                    BarChartRodData(
                        toY: (entry.value['count'] as int).toDouble(),
                        color: _getDayColor(entry.value['day'] as String),
                        width: 8.w,
                        borderRadius: BorderRadius.circular(1.w)),
                  ]);
                }).toList()))));
  }

  @override
  Widget build(BuildContext context) {
    final totalMissed = widget.missedDosesData['totalMissed'] as int;
    final mostMissedTime = widget.missedDosesData['mostMissedTime'] as String;
    final mostMissedDay = widget.missedDosesData['mostMissedDay'] as String;

    return Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        child: Padding(
            padding: EdgeInsets.all(4.w),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CustomIconWidget(
                    iconName: 'schedule',
                    color: AppTheme.lightTheme.colorScheme.error,
                    size: 6.w),
                SizedBox(width: 3.w),
                Text('Missed Doses Analysis',
                    style: AppTheme.lightTheme.textTheme.titleMedium),
              ]),
              SizedBox(height: 2.h),

              // Summary Stats
              Row(children: [
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.error
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2.w)),
                        child: Column(children: [
                          Text(totalMissed.toString(),
                              style: AppTheme.lightTheme.textTheme.headlineSmall
                                  ?.copyWith(
                                      color:
                                          AppTheme.lightTheme.colorScheme.error,
                                      fontWeight: FontWeight.bold)),
                          SizedBox(height: 0.5.h),
                          Text('Total Missed',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.error)),
                        ]))),
                SizedBox(width: 3.w),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.tertiary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2.w)),
                        child: Column(children: [
                          Text(mostMissedTime,
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.tertiary,
                                      fontWeight: FontWeight.w600)),
                          SizedBox(height: 0.5.h),
                          Text('Most Missed Time',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.tertiary)),
                        ]))),
                SizedBox(width: 3.w),
                Expanded(
                    child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.primary
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(2.w)),
                        child: Column(children: [
                          Text(mostMissedDay.substring(0, 3),
                              style: AppTheme.lightTheme.textTheme.titleSmall
                                  ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary,
                                      fontWeight: FontWeight.w600)),
                          SizedBox(height: 0.5.h),
                          Text('Most Missed Day',
                              style: AppTheme.lightTheme.textTheme.labelSmall
                                  ?.copyWith(
                                      color: AppTheme
                                          .lightTheme.colorScheme.primary)),
                        ]))),
              ]),
              SizedBox(height: 3.h),

              // Tab Bar
              TabBar(controller: _tabController, tabs: [
                Tab(text: 'By Time of Day'),
                Tab(text: 'By Day of Week'),
              ]),
              SizedBox(height: 2.h),

              // Tab Bar View
              Container(
                  height: 30.h,
                  child: TabBarView(controller: _tabController, children: [
                    _buildTimeOfDayChart(),
                    _buildDayOfWeekChart(),
                  ])),
            ])));
  }
}
