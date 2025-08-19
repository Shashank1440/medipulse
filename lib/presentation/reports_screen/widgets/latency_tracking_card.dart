import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LatencyTrackingCard extends StatelessWidget {
  final Map<String, dynamic> latencyData;

  const LatencyTrackingCard({
    super.key,
    required this.latencyData,
  });

  Color _getLatencyColor(int minutes) {
    if (minutes <= 15) return AppTheme.lightTheme.colorScheme.secondary;
    if (minutes <= 30) return AppTheme.lightTheme.colorScheme.tertiary;
    if (minutes <= 60) return AppTheme.lightTheme.colorScheme.primary;
    return AppTheme.lightTheme.colorScheme.error;
  }

  String _formatLatency(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      return remainingMinutes > 0
          ? '${hours}h ${remainingMinutes}m'
          : '${hours}h';
    }
  }

  @override
  Widget build(BuildContext context) {
    final averageLatency = latencyData['averageLatency'] as int;
    final medianLatency = latencyData['medianLatency'] as int;
    final distributionData =
        latencyData['distribution'] as List<Map<String, dynamic>>;
    final onTimePercentage = latencyData['onTimePercentage'] as double;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'timer',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Dose Timing Analysis',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Summary Statistics
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.colorScheme.secondary
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${onTimePercentage.toStringAsFixed(1)}%',
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'On Time',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme.lightTheme.colorScheme.secondary,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          '(±15 minutes)',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: _getLatencyColor(averageLatency)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _formatLatency(averageLatency),
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            color: _getLatencyColor(averageLatency),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Average Delay',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: _getLatencyColor(averageLatency),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: _getLatencyColor(medianLatency)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2.w),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _formatLatency(medianLatency),
                          style: AppTheme.lightTheme.textTheme.headlineSmall
                              ?.copyWith(
                            color: _getLatencyColor(medianLatency),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Median Delay',
                          style: AppTheme.lightTheme.textTheme.labelSmall
                              ?.copyWith(
                            color: _getLatencyColor(medianLatency),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),

            // Distribution Chart
            Text(
              'Timing Distribution',
              style: AppTheme.lightTheme.textTheme.titleSmall,
            ),
            SizedBox(height: 2.h),
            Container(
              height: 25.h,
              child: Semantics(
                label: "Dose Timing Distribution Pie Chart",
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 8.w,
                    sections: distributionData.asMap().entries.map((entry) {
                      final data = entry.value;
                      final percentage = data['percentage'] as double;
                      final label = data['label'] as String;
                      final color = _getLatencyColor(data['maxMinutes'] as int);

                      return PieChartSectionData(
                        color: color,
                        value: percentage,
                        title: '${percentage.toStringAsFixed(1)}%',
                        radius: 12.w,
                        titleStyle:
                            AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                          color: AppTheme.lightTheme.colorScheme.surface,
                          fontWeight: FontWeight.w600,
                        ),
                        badgeWidget: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                          child: Text(
                            label,
                            style: AppTheme.lightTheme.textTheme.labelSmall
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.surface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        badgePositionPercentageOffset: 1.3,
                      );
                    }).toList(),
                    pieTouchData: PieTouchData(
                      enabled: true,
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        // Handle touch interactions if needed
                      },
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),

            // Legend
            Wrap(
              spacing: 3.w,
              runSpacing: 1.h,
              children: distributionData.map((data) {
                final color = _getLatencyColor(data['maxMinutes'] as int);
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 3.w,
                      height: 3.w,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      data['label'] as String,
                      style: AppTheme.lightTheme.textTheme.labelSmall,
                    ),
                  ],
                );
              }).toList(),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(2.w),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.primary
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 5.w,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'Timing analysis helps identify patterns in medication adherence and optimize reminder schedules.',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
