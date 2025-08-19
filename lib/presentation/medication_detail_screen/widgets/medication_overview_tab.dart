import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class MedicationOverviewTab extends StatelessWidget {
  final Map<String, dynamic> medication;

  const MedicationOverviewTab({
    Key? key,
    required this.medication,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailCard(
            title: 'Medication Information',
            children: [
              _buildDetailRow(
                  'Strength', medication['strength'] as String? ?? 'N/A'),
              _buildDetailRow('Form', medication['form'] as String? ?? 'N/A'),
              _buildDetailRow('Route', medication['route'] as String? ?? 'N/A'),
              _buildDetailRow(
                  'Frequency', medication['frequency'] as String? ?? 'N/A'),
              _buildDetailRow(
                  'Dosage', medication['dosage'] as String? ?? 'N/A'),
            ],
          ),
          SizedBox(height: 3.h),
          _buildDetailCard(
            title: 'Prescription Details',
            children: [
              _buildDetailRow('Prescribing Doctor',
                  medication['doctor'] as String? ?? 'N/A'),
              _buildDetailRow(
                  'Start Date', medication['startDate'] as String? ?? 'N/A'),
              _buildDetailRow(
                  'End Date', medication['endDate'] as String? ?? 'Ongoing'),
              _buildDetailRow(
                  'Pharmacy', medication['pharmacy'] as String? ?? 'N/A'),
            ],
          ),
          SizedBox(height: 3.h),
          if (medication['instructions'] != null &&
              (medication['instructions'] as String).isNotEmpty)
            _buildDetailCard(
              title: 'Special Instructions',
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.primaryContainer
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2.w),
                    border: Border.all(
                      color: AppTheme.lightTheme.colorScheme.outline
                          .withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    medication['instructions'] as String,
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          SizedBox(height: 3.h),
          _buildDetailCard(
            title: 'Reminders',
            children: [
              _buildDetailRow(
                  'Next Dose', medication['nextDose'] as String? ?? 'N/A'),
              _buildDetailRow('Reminder Times',
                  medication['reminderTimes'] as String? ?? 'N/A'),
              _buildDetailRow('Snooze Duration',
                  '${medication['snoozeDuration'] ?? 10} minutes'),
            ],
          ),
          SizedBox(height: 10.h), // Extra space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildDetailCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.primaryContainer
                  .withValues(alpha: 0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(3.w),
                topRight: Radius.circular(3.w),
              ),
            ),
            child: Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 2.w),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
