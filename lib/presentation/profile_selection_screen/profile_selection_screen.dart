import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/profile_context_menu_widget.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  String? selectedProfileId;
  bool showContextMenu = false;
  Map<String, dynamic>? contextMenuProfile;
  bool isLoading = false;
  bool isRefreshing = false;

  // Clean profiles list - removed all random/demo profiles
  final List<Map<String, dynamic>> profiles = [];

  @override
  void initState() {
    super.initState();
    selectedProfileId = profiles.isNotEmpty ? profiles.first['id'] : null;

    // Auto-navigate if single profile
    if (profiles.length == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToTodayView();
      });
    }
  }

  void _selectProfile(String profileId) {
    setState(() {
      selectedProfileId = profileId;
    });

    // Navigate to Today View after selection
    Future.delayed(const Duration(milliseconds: 300), () {
      _navigateToTodayView();
    });
  }

  void _showContextMenu(Map<String, dynamic> profile) {
    setState(() {
      contextMenuProfile = profile;
      showContextMenu = true;
    });
  }

  void _hideContextMenu() {
    setState(() {
      showContextMenu = false;
      contextMenuProfile = null;
    });
  }

  void _navigateToTodayView() {
    // Navigate to medication list screen as today view
    Navigator.pushReplacementNamed(context, '/medication-list-screen');
  }

  void _navigateToAddProfile() {
    Navigator.pushNamed(context, '/add-medication-screen');
  }

  void _editProfile() {
    _hideContextMenu();
    // Navigate to edit profile screen
    Navigator.pushNamed(context, '/add-medication-screen');
  }

  void _showMedicationSummary() {
    _hideContextMenu();
    // Navigate to medication summary
    Navigator.pushNamed(context, '/medication-detail-screen');
  }

  void _removeAccess() {
    _hideContextMenu();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Remove Profile Access',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to remove access to ${contextMenuProfile?['name']}\'s medication profile? This action cannot be undone.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _performRemoveAccess();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
                foregroundColor: AppTheme.lightTheme.colorScheme.onError,
              ),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  void _performRemoveAccess() {
    setState(() {
      profiles
          .removeWhere((profile) => profile['id'] == contextMenuProfile?['id']);
      if (selectedProfileId == contextMenuProfile?['id']) {
        selectedProfileId = profiles.isNotEmpty ? profiles.first['id'] : null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Profile access removed successfully'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _refreshProfiles() async {
    setState(() {
      isRefreshing = true;
    });

    // Simulate network refresh
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isRefreshing = false;
      // Update last sync times
      for (var profile in profiles) {
        profile['lastSync'] = DateTime.now();
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profiles synced successfully'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        centerTitle: true,
        title: Text(
          'Select Profile',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle?.copyWith(
            fontSize: 18.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/reports-screen');
            },
            icon: CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.appBarTheme.iconTheme?.color ??
                  AppTheme.lightTheme.colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Stack(
        children: [
          // Main Content - Always show empty state since profiles list is now empty
          EmptyStateWidget(
            onAddProfile: _navigateToAddProfile,
          ),

          // Context Menu Overlay
          if (showContextMenu && contextMenuProfile != null)
            ProfileContextMenuWidget(
              profile: contextMenuProfile!,
              onEditProfile: _editProfile,
              onMedicationSummary: _showMedicationSummary,
              onRemoveAccess: _removeAccess,
              onDismiss: _hideContextMenu,
            ),

          // Loading Overlay
          if (isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Loading profile...',
                        style: AppTheme.lightTheme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),

      // Remove FAB since no profiles exist
      floatingActionButton: null,
    );
  }
}
