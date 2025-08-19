import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/add_profile_card_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/profile_card_widget.dart';
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

  // Mock profiles data
  final List<Map<String, dynamic>> profiles = [
    {
      "id": "1",
      "name": "Rajesh Kumar",
      "relationship": "Self",
      "type": "patient",
      "avatarUrl":
          "https://images.pexels.com/photos/2379004/pexels-photo-2379004.jpeg?auto=compress&cs=tinysrgb&w=400",
      "medicationCount": 5,
      "isActive": true,
      "lastSync": DateTime.now().subtract(const Duration(minutes: 15)),
      "permissions": ["read", "write", "delete"],
    },
    {
      "id": "2",
      "name": "Sunita Devi",
      "relationship": "Mother",
      "type": "caregiver",
      "avatarUrl":
          "https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400",
      "medicationCount": 8,
      "isActive": false,
      "lastSync": DateTime.now().subtract(const Duration(hours: 2)),
      "permissions": ["read"],
    },
    {
      "id": "3",
      "name": "Amit Sharma",
      "relationship": "Spouse",
      "type": "caregiver",
      "avatarUrl":
          "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400",
      "medicationCount": 3,
      "isActive": false,
      "lastSync": DateTime.now().subtract(const Duration(hours: 1)),
      "permissions": ["read", "write"],
    },
  ];

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
          // Main Content
          profiles.isEmpty
              ? EmptyStateWidget(
                  onAddProfile: _navigateToAddProfile,
                )
              : RefreshIndicator(
                  onRefresh: _refreshProfiles,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Text
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Choose a profile to continue',
                                  style: AppTheme
                                      .lightTheme.textTheme.titleMedium
                                      ?.copyWith(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Manage medications for yourself or your loved ones',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontSize: 13.sp,
                                    color: AppTheme
                                        .lightTheme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 3.h),

                          // Profile Cards
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: profiles.length,
                            itemBuilder: (context, index) {
                              final profile = profiles[index];
                              return ProfileCardWidget(
                                profile: profile,
                                isSelected: selectedProfileId == profile['id'],
                                onTap: () => _selectProfile(profile['id']),
                                onLongPress: () => _showContextMenu(profile),
                              );
                            },
                          ),

                          SizedBox(height: 2.h),

                          // Add New Profile Card
                          AddProfileCardWidget(
                            onTap: _navigateToAddProfile,
                          ),

                          SizedBox(height: 4.h),
                        ],
                      ),
                    ),
                  ),
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

      // Quick Profile Switch FAB
      floatingActionButton: profiles.length > 1
          ? FloatingActionButton(
              onPressed: () {
                // Quick switch to next profile
                final currentIndex =
                    profiles.indexWhere((p) => p['id'] == selectedProfileId);
                final nextIndex = (currentIndex + 1) % profiles.length;
                _selectProfile(profiles[nextIndex]['id']);
              },
              backgroundColor:
                  AppTheme.lightTheme.floatingActionButtonTheme.backgroundColor,
              foregroundColor:
                  AppTheme.lightTheme.floatingActionButtonTheme.foregroundColor,
              child: CustomIconWidget(
                iconName: 'swap_horiz',
                color: AppTheme
                        .lightTheme.floatingActionButtonTheme.foregroundColor ??
                    Colors.white,
                size: 6.w,
              ),
            )
          : null,
    );
  }
}
