import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SyncStatusWidget extends StatelessWidget {
  final bool isOnline;
  final DateTime? lastSyncTime;
  final bool isSyncing;
  final VoidCallback? onRetrySync;

  const SyncStatusWidget({
    Key? key,
    required this.isOnline,
    this.lastSyncTime,
    this.isSyncing = false,
    this.onRetrySync,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isOnline && !isSyncing && lastSyncTime != null) {
      return const SizedBox.shrink(); // Hide when everything is normal
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getBorderColor(),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildStatusIcon(),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(),
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: _getTextColor(),
                  ),
                ),
                if (_getStatusSubtitle().isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    _getStatusSubtitle(),
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: _getTextColor().withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isOnline && onRetrySync != null) ...[
            SizedBox(width: 2.w),
            GestureDetector(
              onTap: onRetrySync,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Retry',
                  style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    if (isSyncing) {
      return SizedBox(
        width: 5.w,
        height: 5.w,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
        ),
      );
    }

    return CustomIconWidget(
      iconName: _getStatusIcon(),
      color: _getTextColor(),
      size: 5.w,
    );
  }

  Color _getBackgroundColor() {
    if (isSyncing) {
      return AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1);
    } else if (!isOnline) {
      return AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1);
    } else {
      return AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1);
    }
  }

  Color _getBorderColor() {
    if (isSyncing) {
      return AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.3);
    } else if (!isOnline) {
      return AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.3);
    } else {
      return AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.3);
    }
  }

  Color _getTextColor() {
    if (isSyncing) {
      return AppTheme.lightTheme.colorScheme.primary;
    } else if (!isOnline) {
      return AppTheme.lightTheme.colorScheme.error;
    } else {
      return AppTheme.lightTheme.colorScheme.tertiary;
    }
  }

  String _getStatusIcon() {
    if (!isOnline) {
      return 'cloud_off';
    } else if (lastSyncTime == null) {
      return 'sync_problem';
    } else {
      return 'cloud_done';
    }
  }

  String _getStatusTitle() {
    if (isSyncing) {
      return 'Syncing...';
    } else if (!isOnline) {
      return 'Offline Mode';
    } else if (lastSyncTime == null) {
      return 'Sync Pending';
    } else {
      return 'Last synced';
    }
  }

  String _getStatusSubtitle() {
    if (isSyncing) {
      return 'Updating medication data';
    } else if (!isOnline) {
      return 'Some features may be limited';
    } else if (lastSyncTime == null) {
      return 'Waiting for connection';
    } else {
      return _formatLastSyncTime();
    }
  }

  String _formatLastSyncTime() {
    if (lastSyncTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(lastSyncTime!);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
