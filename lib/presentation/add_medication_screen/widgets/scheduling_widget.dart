import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SchedulingWidget extends StatelessWidget {
  final bool useExactTimes;
  final List<TimeOfDay> exactTimes;
  final Map<String, bool> timeBuckets;
  final Function(bool) onScheduleTypeChanged;
  final Function(List<TimeOfDay>) onExactTimesChanged;
  final Function(String, bool) onTimeBucketChanged;

  const SchedulingWidget({
    Key? key,
    required this.useExactTimes,
    required this.exactTimes,
    required this.timeBuckets,
    required this.onScheduleTypeChanged,
    required this.onExactTimesChanged,
    required this.onTimeBucketChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheduling',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              SwitchListTile(
                title: Text(
                  'Use Exact Times',
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
                value: useExactTimes,
                onChanged: onScheduleTypeChanged,
                contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
              ),
              Divider(height: 1),
              useExactTimes
                  ? _buildExactTimesSection(context)
                  : _buildTimeBucketsSection(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExactTimesSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Times',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton.icon(
                onPressed: () => _addTime(context),
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 16,
                ),
                label: Text('Add Time'),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          ...exactTimes.asMap().entries.map((entry) {
            final index = entry.key;
            final time = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 1.h),
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    time.format(context),
                    style: AppTheme.lightTheme.textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () => _removeTime(index),
                    child: CustomIconWidget(
                      iconName: 'close',
                      color: AppTheme.lightTheme.colorScheme.error,
                      size: 20,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTimeBucketsSection() {
    final buckets = ['Morning', 'Afternoon', 'Evening', 'Night'];
    final bucketIcons = ['wb_sunny', 'wb_sunny', 'wb_twilight', 'nights_stay'];

    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time Buckets',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          ...buckets.asMap().entries.map((entry) {
            final index = entry.key;
            final bucket = entry.value;
            final icon = bucketIcons[index];
            final isSelected = timeBuckets[bucket] ?? false;

            return Container(
              margin: EdgeInsets.only(bottom: 1.h),
              child: CheckboxListTile(
                title: Row(
                  children: [
                    CustomIconWidget(
                      iconName: icon,
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      bucket,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  ],
                ),
                value: isSelected,
                onChanged: (bool? value) {
                  if (value != null) {
                    onTimeBucketChanged(bucket, value);
                  }
                },
                contentPadding: EdgeInsets.zero,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  void _addTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final newTimes = List<TimeOfDay>.from(exactTimes)..add(picked);
      newTimes.sort((a, b) => a.hour.compareTo(b.hour));
      onExactTimesChanged(newTimes);
    }
  }

  void _removeTime(int index) {
    final newTimes = List<TimeOfDay>.from(exactTimes)..removeAt(index);
    onExactTimesChanged(newTimes);
  }
}
