import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AdherenceOverviewCard extends StatelessWidget {
  final double adherencePercentage;
  final int currentStreak;
  final double previousPeriodComparison;
  final String selectedPeriod;

  const AdherenceOverviewCard({
    super.key,
    required this.adherencePercentage,
    required this.currentStreak,
    required this.previousPeriodComparison,
    required this.selectedPeriod,
  });

  Color _getAdherenceColor() {
    if (adherencePercentage >= 90)
      return AppTheme.lightTheme.colorScheme.secondary;
    if (adherencePercentage >= 70)
      return AppTheme.lightTheme.colorScheme.tertiary;
    return AppTheme.lightTheme.colorScheme.error;
  }

  String _getAdherenceStatus() {
    if (adherencePercentage >= 90) return 'Excellent';
    if (adherencePercentage >= 70) return 'Good';
    return 'Needs Improvement';
  }

  @override
  Widget build(BuildContext context) {
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
                  iconName: 'analytics',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 6.w,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Overall Adherence',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${adherencePercentage.toStringAsFixed(1)}%',
                        style: AppTheme.lightTheme.textTheme.displaySmall
                            ?.copyWith(
                          color: _getAdherenceColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: _getAdherenceColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(2.w),
                        ),
                        child: Text(
                          _getAdherenceStatus(),
                          style: AppTheme.lightTheme.textTheme.labelMedium
                              ?.copyWith(
                            color: _getAdherenceColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 20.w,
                        height: 20.w,
                        child: Stack(
                          children: [
                            CircularProgressIndicator(
                              value: adherencePercentage / 100,
                              strokeWidth: 2.w,
                              backgroundColor: AppTheme
                                  .lightTheme.colorScheme.outline
                                  .withValues(alpha: 0.2),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  _getAdherenceColor()),
                            ),
                            Center(
                              child: CustomIconWidget(
                                iconName: 'medication',
                                color: _getAdherenceColor(),
                                size: 8.w,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Divider(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2)),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Streak',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'local_fire_department',
                            color: AppTheme.lightTheme.colorScheme.tertiary,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '$currentStreak days',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'vs Previous $selectedPeriod',
                        style: AppTheme.lightTheme.textTheme.bodySmall,
                      ),
                      SizedBox(height: 0.5.h),
                      Row(
                        children: [
                          CustomIconWidget(
                            iconName: previousPeriodComparison >= 0
                                ? 'trending_up'
                                : 'trending_down',
                            color: previousPeriodComparison >= 0
                                ? AppTheme.lightTheme.colorScheme.secondary
                                : AppTheme.lightTheme.colorScheme.error,
                            size: 5.w,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            '${previousPeriodComparison >= 0 ? '+' : ''}${previousPeriodComparison.toStringAsFixed(1)}%',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              color: previousPeriodComparison >= 0
                                  ? AppTheme.lightTheme.colorScheme.secondary
                                  : AppTheme.lightTheme.colorScheme.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
