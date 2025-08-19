import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MedicationCardWidget extends StatelessWidget {
  final Map<String, dynamic> medication;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDuplicate;
  final VoidCallback? onPause;
  final VoidCallback? onDelete;
  final VoidCallback? onViewHistory;
  final VoidCallback? onExportData;
  final VoidCallback? onShare;

  const MedicationCardWidget({
    Key? key,
    required this.medication,
    this.onTap,
    this.onEdit,
    this.onDuplicate,
    this.onPause,
    this.onDelete,
    this.onViewHistory,
    this.onExportData,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isActive = (medication['status'] as String) == 'Active';
    final double adherencePercentage =
        (medication['adherencePercentage'] as num).toDouble();
    final bool hasConflict = medication['hasConflict'] as bool? ?? false;

    return Dismissible(
      key: Key('medication_${medication['id']}'),
      background: _buildSwipeBackground(isLeftSwipe: false),
      secondaryBackground: _buildSwipeBackground(isLeftSwipe: true),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          // Right swipe - Edit action
          onEdit?.call();
        } else if (direction == DismissDirection.endToStart) {
          // Left swipe - Delete action
          _showDeleteConfirmation(context);
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          return await _showDeleteConfirmation(context);
        }
        return false; // Don't actually dismiss for edit
      },
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: hasConflict
                ? Border.all(
                    color: AppTheme.lightTheme.colorScheme.tertiary, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: AppTheme.lightTheme.colorScheme.shadow,
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              if (hasConflict) _buildConflictWarning(),
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMedicationHeader(),
                    SizedBox(height: 2.h),
                    _buildMedicationDetails(),
                    SizedBox(height: 2.h),
                    _buildAdherenceSection(adherencePercentage),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeBackground({required bool isLeftSwipe}) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: isLeftSwipe
            ? AppTheme.lightTheme.colorScheme.error
            : AppTheme.lightTheme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: isLeftSwipe ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 6.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: isLeftSwipe ? 'delete' : 'edit',
            color: Colors.white,
            size: 6.w,
          ),
          SizedBox(height: 0.5.h),
          Text(
            isLeftSwipe ? 'Delete' : 'Edit',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConflictWarning() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'warning',
            color: AppTheme.lightTheme.colorScheme.tertiary,
            size: 4.w,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              'Drug interaction detected - Tap to view details',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.tertiary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: _getMedicationCategoryColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: _getMedicationIcon(),
              color: _getMedicationCategoryColor(),
              size: 6.w,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medication['name'] as String,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              Text(
                '${medication['dosage']} • ${medication['form']}',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final String status = medication['status'] as String;
    Color statusColor;
    String statusText;

    switch (status) {
      case 'Active':
        statusColor = AppTheme.lightTheme.colorScheme.secondary;
        statusText = 'Active';
        break;
      case 'Paused':
        statusColor = AppTheme.lightTheme.colorScheme.tertiary;
        statusText = 'Paused';
        break;
      case 'Completed':
        statusColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        statusText = 'Completed';
        break;
      default:
        statusColor = AppTheme.lightTheme.colorScheme.onSurfaceVariant;
        statusText = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        statusText,
        style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
          color: statusColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildMedicationDetails() {
    return Row(
      children: [
        Expanded(
          child: _buildDetailItem(
            icon: 'schedule',
            label: 'Frequency',
            value: medication['frequency'] as String,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: _buildDetailItem(
            icon: 'access_time',
            label: 'Next Dose',
            value: medication['nextDose'] as String,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required String icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 3.5.w,
            ),
            SizedBox(width: 1.w),
            Text(
              label,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAdherenceSection(double adherencePercentage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Adherence',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${adherencePercentage.toInt()}%',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: _getAdherenceColor(adherencePercentage),
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        LinearProgressIndicator(
          value: adherencePercentage / 100,
          backgroundColor:
              AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          valueColor: AlwaysStoppedAnimation<Color>(
            _getAdherenceColor(adherencePercentage),
          ),
          minHeight: 0.8.h,
        ),
      ],
    );
  }

  Color _getMedicationCategoryColor() {
    final String category = medication['category'] as String? ?? 'Other';
    switch (category) {
      case 'Heart':
        return const Color(0xFFE53E3E);
      case 'Diabetes':
        return const Color(0xFF3182CE);
      case 'Blood Pressure':
        return const Color(0xFF38A169);
      case 'Pain Relief':
        return const Color(0xFFD69E2E);
      case 'Vitamin':
        return const Color(0xFF805AD5);
      default:
        return AppTheme.lightTheme.colorScheme.primary;
    }
  }

  String _getMedicationIcon() {
    final String category = medication['category'] as String? ?? 'Other';
    switch (category) {
      case 'Heart':
        return 'favorite';
      case 'Diabetes':
        return 'bloodtype';
      case 'Blood Pressure':
        return 'monitor_heart';
      case 'Pain Relief':
        return 'healing';
      case 'Vitamin':
        return 'eco';
      default:
        return 'medication';
    }
  }

  Color _getAdherenceColor(double percentage) {
    if (percentage >= 90) {
      return AppTheme.lightTheme.colorScheme.secondary;
    } else if (percentage >= 70) {
      return AppTheme.lightTheme.colorScheme.tertiary;
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  Future<bool?> _showDeleteConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Medication',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'Are you sure you want to delete ${medication['name']}? This action cannot be undone.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                onDelete?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: Text(
                'Delete',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                medication['name'] as String,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              _buildContextMenuItem(
                icon: 'history',
                title: 'View History',
                onTap: () {
                  Navigator.pop(context);
                  onViewHistory?.call();
                },
              ),
              _buildContextMenuItem(
                icon: 'file_download',
                title: 'Export Data',
                onTap: () {
                  Navigator.pop(context);
                  onExportData?.call();
                },
              ),
              _buildContextMenuItem(
                icon: 'share',
                title: 'Share with Doctor',
                onTap: () {
                  Navigator.pop(context);
                  onShare?.call();
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContextMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: AppTheme.lightTheme.colorScheme.primary,
        size: 5.w,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge,
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
