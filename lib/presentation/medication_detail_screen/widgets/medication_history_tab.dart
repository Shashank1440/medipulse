import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class MedicationHistoryTab extends StatelessWidget {
  final List<Map<String, dynamic>> doseHistory;

  const MedicationHistoryTab({
    Key? key,
    required this.doseHistory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (doseHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'history',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 12.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'No dose history available',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    // Group doses by date
    final groupedHistory = _groupDosesByDate(doseHistory);

    return RefreshIndicator(
      onRefresh: () async {
        // Simulate refresh
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: groupedHistory.length,
        itemBuilder: (context, index) {
          final dateEntry = groupedHistory.entries.elementAt(index);
          final date = dateEntry.key;
          final doses = dateEntry.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(date),
              SizedBox(height: 2.h),
              ...doses.map((dose) => _buildDoseHistoryCard(dose)).toList(),
              SizedBox(height: 3.h),
            ],
          );
        },
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupDosesByDate(
      List<Map<String, dynamic>> history) {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final dose in history) {
      final date = dose['date'] as String? ?? 'Unknown Date';
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(dose);
    }

    return grouped;
  }

  Widget _buildDateHeader(String date) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.primaryContainer
            .withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(2.w),
      ),
      child: Text(
        date,
        style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _buildDoseHistoryCard(Map<String, dynamic> dose) {
    final status = dose['status'] as String? ?? 'unknown';
    final time = dose['time'] as String? ?? 'N/A';
    final reason = dose['reason'] as String?;
    final latency = dose['latency'] as String?;

    Color statusColor;
    IconData statusIcon;

    switch (status.toLowerCase()) {
      case 'taken':
        statusColor = AppTheme.lightTheme.colorScheme.secondary;
        statusIcon = Icons.check_circle;
        break;
      case 'missed':
        statusColor = AppTheme.lightTheme.colorScheme.error;
        statusIcon = Icons.cancel;
        break;
      case 'snoozed':
        statusColor = Colors.orange;
        statusIcon = Icons.snooze;
        break;
      default:
        statusColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        statusIcon = Icons.help_outline;
    }

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(3.w),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 6.w,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      status.toUpperCase(),
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      time,
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (reason != null && reason.isNotEmpty) ...[
                  SizedBox(height: 1.h),
                  Text(
                    'Reason: $reason',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                if (latency != null && latency.isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    'Latency: $latency',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
