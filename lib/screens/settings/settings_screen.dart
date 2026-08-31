import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/audio_service.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../providers/settings_provider.dart';
import 'backup_restore_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: isDark ? AppColors.oledBackground : AppColors.lightBackground,
      appBar: AppBar(
        leading: BouncingButton(
          shrinkScale: 0.85,
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        ),
        title: const Text(AppStrings.settingsTitle),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Section: Appearance
          _buildSectionHeader('Appearance', isDark),
          _buildCardWrapper(
            isDark: isDark,
            children: [
              SwitchListTile(
                value: settings.isDarkMode,
                onChanged: (val) => settings.setDarkMode(val),
                title: const Text(
                  AppStrings.oledDarkMode,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'True #000000 black background optimized for OLED displays',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                activeThumbColor: AppColors.primary,
              ),
              const Divider(),
              SwitchListTile(
                value: settings.isGridView,
                onChanged: (_) => settings.toggleViewMode(),
                title: const Text(
                  'Grid Dashboard Layout',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Switch between responsive 2-column masonry grid and single column list',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section: Audio & Haptics
          _buildSectionHeader(AppStrings.audioHapticsSection, isDark),
          _buildCardWrapper(
            isDark: isDark,
            children: [
              SwitchListTile(
                value: settings.soundEnabled,
                onChanged: (val) => settings.setSoundEnabled(val),
                title: const Text(
                  AppStrings.soundEffects,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Crisp tactile paper rustle, tap clicks, and completion chimes',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                activeThumbColor: AppColors.primary,
              ),
              if (settings.soundEnabled) ...[
                const Divider(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            AppStrings.soundVolume,
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          Text(
                            '${(settings.soundVolume * 100).toInt()}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Slider(
                        value: settings.soundVolume,
                        min: 0.0,
                        max: 1.0,
                        activeColor: AppColors.primary,
                        onChanged: (val) => settings.setSoundVolume(val),
                        onChangeEnd: (_) => AudioService().playChime(),
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(),
              SwitchListTile(
                value: settings.hapticsEnabled,
                onChanged: (val) => settings.setHapticsEnabled(val),
                title: const Text(
                  AppStrings.hapticFeedback,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Vibration feedback on tap and spring interactions',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section: Data & Storage
          _buildSectionHeader(AppStrings.dataManagementSection, isDark),
          _buildCardWrapper(
            isDark: isDark,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.backup_table_rounded, color: AppColors.primary, size: 20),
                ),
                title: const Text(
                  'Backup & Restore',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Export or import full JSON data backups offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const BackupRestoreScreen()),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Section: Zero-Permission Assurance
          _buildSectionHeader('Zero-Permission Guarantee', isDark),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.oledCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.security_rounded, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '100% Offline & Private',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.privacyPledge,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.45,
                    color: isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _buildPledgeBadge('Zero Ads', Icons.block_rounded),
                    const SizedBox(width: 8),
                    _buildPledgeBadge('Zero Trackers', Icons.no_encryption_gmailerrorred_rounded),
                    const SizedBox(width: 8),
                    _buildPledgeBadge('Zero Cloud', Icons.cloud_off_rounded),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // App Footer info
          Center(
            child: Column(
              children: [
                Text(
                  '${AppStrings.appName} • Version ${AppStrings.version}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Crafted with spring physics & SQLite persistence',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
        ),
      ),
    );
  }

  Widget _buildCardWrapper({required bool isDark, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.oledCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildPledgeBadge(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
