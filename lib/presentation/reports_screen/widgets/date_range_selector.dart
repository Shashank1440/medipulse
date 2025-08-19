import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DateRangeSelector extends StatelessWidget {
  final String selectedRange;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final Function(String) onRangeChanged;
  final Function(DateTime, DateTime) onCustomRangeSelected;

  const DateRangeSelector({
    super.key,
    required this.selectedRange,
    this.customStartDate,
    this.customEndDate,
    required this.onRangeChanged,
    required this.onCustomRangeSelected,
  });

  Future<void> _selectCustomRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: customStartDate != null && customEndDate != null
          ? DateTimeRange(start: customStartDate!, end: customEndDate!)
          : DateTimeRange(
              start: DateTime.now().subtract(Duration(days: 30)),
              end: DateTime.now(),
            ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onCustomRangeSelected(picked.start, picked.end);
    }
  }

  String _getCustomRangeText() {
    if (customStartDate != null && customEndDate != null) {
      final start =
          '${customStartDate!.day}/${customStartDate!.month}/${customStartDate!.year}';
      final end =
          '${customEndDate!.day}/${customEndDate!.month}/${customEndDate!.year}';
      return '$start - $end';
    }
    return 'Select Custom Range';
  }

  @override
  Widget build(BuildContext context) {
    final ranges = [
      {'key': '7days', 'label': 'Last 7 Days'},
      {'key': '30days', 'label': 'Last 30 Days'},
      {'key': '3months', 'label': 'Last 3 Months'},
      {
        'key': 'custom',
        'label':
            selectedRange == 'custom' ? _getCustomRangeText() : 'Custom Range'
      },
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'date_range',
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 5.w,
              ),
              SizedBox(width: 2.w),
              Text(
                'Date Range',
                style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ranges.map((range) {
                final isSelected = selectedRange == range['key'];
                final isCustom = range['key'] == 'custom';

                return Padding(
                  padding: EdgeInsets.only(right: 3.w),
                  child: GestureDetector(
                    onTap: () {
                      if (isCustom) {
                        _selectCustomRange(context);
                      } else {
                        onRangeChanged(range['key'] as String);
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 4.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.lightTheme.colorScheme.primary
                            : AppTheme.lightTheme.colorScheme.surface,
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.lightTheme.colorScheme.primary
                              : AppTheme.lightTheme.colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(6.w),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCustom) ...[
                            CustomIconWidget(
                              iconName: 'calendar_today',
                              color: isSelected
                                  ? AppTheme.lightTheme.colorScheme.onPrimary
                                  : AppTheme.lightTheme.colorScheme.primary,
                              size: 4.w,
                            ),
                            SizedBox(width: 2.w),
                          ],
                          Flexible(
                            child: Text(
                              range['label'] as String,
                              style: AppTheme.lightTheme.textTheme.labelMedium
                                  ?.copyWith(
                                color: isSelected
                                    ? AppTheme.lightTheme.colorScheme.onPrimary
                                    : AppTheme.lightTheme.colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
