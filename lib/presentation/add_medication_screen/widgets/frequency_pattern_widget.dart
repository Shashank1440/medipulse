import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FrequencyPatternWidget extends StatelessWidget {
  final String selectedPattern;
  final int intervalHours;
  final List<String> selectedDays;
  final Function(String) onPatternChanged;
  final Function(int) onIntervalChanged;
  final Function(List<String>) onDaysChanged;

  const FrequencyPatternWidget({
    Key? key,
    required this.selectedPattern,
    required this.intervalHours,
    required this.selectedDays,
    required this.onPatternChanged,
    required this.onIntervalChanged,
    required this.onDaysChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequency Pattern',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        _buildPatternSelector(),
        SizedBox(height: 2.h),
        _buildPatternDetails(),
      ],
    );
  }

  Widget _buildPatternSelector() {
    final patterns = [
      {'value': 'daily', 'label': 'Daily', 'icon': 'today'},
      {'value': 'interval', 'label': 'Every N Hours', 'icon': 'schedule'},
      {'value': 'specific', 'label': 'Specific Days', 'icon': 'date_range'},
      {'value': 'alternate', 'label': 'Alternate Days', 'icon': 'swap_horiz'},
    ];

    return Column(
      children: patterns.map((pattern) {
        final isSelected = selectedPattern == pattern['value'];
        return Container(
          margin: EdgeInsets.only(bottom: 1.h),
          child: RadioListTile<String>(
            title: Row(
              children: [
                CustomIconWidget(
                  iconName: pattern['icon']!,
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  pattern['label']!,
                  style: AppTheme.lightTheme.textTheme.bodyMedium,
                ),
              ],
            ),
            value: pattern['value']!,
            groupValue: selectedPattern,
            onChanged: (String? value) {
              if (value != null) {
                onPatternChanged(value);
              }
            },
            contentPadding: EdgeInsets.symmetric(horizontal: 2.w),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPatternDetails() {
    switch (selectedPattern) {
      case 'interval':
        return _buildIntervalSelector();
      case 'specific':
        return _buildDaySelector();
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildIntervalSelector() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Every',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          SizedBox(width: 3.w),
          Container(
            width: 20.w,
            child: DropdownButtonFormField<int>(
              value: intervalHours,
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: List.generate(24, (index) => index + 1).map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString()),
                );
              }).toList(),
              onChanged: (int? newValue) {
                if (newValue != null) {
                  onIntervalChanged(newValue);
                }
              },
            ),
          ),
          SizedBox(width: 3.w),
          Text(
            'hours',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Days',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: days.map((day) {
              final isSelected = selectedDays.contains(day);
              return GestureDetector(
                onTap: () {
                  final newDays = List<String>.from(selectedDays);
                  if (isSelected) {
                    newDays.remove(day);
                  } else {
                    newDays.add(day);
                  }
                  onDaysChanged(newDays);
                },
                child: Container(
                  width: 12.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      day,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w500 : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
