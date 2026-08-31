import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showComingSoonDialog(BuildContext context, String featureName) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Feature Coming Soon'),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text('$featureName will be available in the next update.'),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse(AppStrings.privacyPolicyUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Fallback to platform default
        await launchUrl(uri);
      }
    } catch (_) {
      if (context.mounted) {
        _showFallbackDialog(
          context: context,
          title: 'Privacy Policy',
          url: AppStrings.privacyPolicyUrl,
        );
      }
    }
  }

  Future<void> _openRateUs(BuildContext context) async {
    const packageName = 'com.zahraini.vervejot';
    final marketUri = Uri.parse('market://details?id=$packageName');
    final playStoreUri = Uri.parse('https://play.google.com/store/apps/details?id=$packageName');

    try {
      final launchedMarket = await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      if (!launchedMarket) {
        final launchedWeb = await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
        if (!launchedWeb && context.mounted) {
          _showFallbackDialog(
            context: context,
            title: 'Rate Us on Play Store',
            url: playStoreUri.toString(),
          );
        }
      }
    } catch (_) {
      try {
        await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
      } catch (_) {
        if (context.mounted) {
          _showFallbackDialog(
            context: context,
            title: 'Rate Us on Play Store',
            url: playStoreUri.toString(),
          );
        }
      }
    }
  }

  void _showFallbackDialog({
    required BuildContext context,
    required String title,
    required String url,
  }) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text('Visit the link below:\n\n$url'),
        ),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
          // Section: Appearance & Theme
          _buildSectionHeader('Appearance', isDark),
          _buildCardWrapper(
            isDark: isDark,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Theme Mode',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Select your preferred visual style or adapt to your system preferences',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _buildThemeOption(
                          context: context,
                          label: 'System',
                          icon: Icons.brightness_auto_rounded,
                          isSelected: settings.themeMode == ThemeMode.system,
                          onTap: () => settings.setThemeMode(ThemeMode.system),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildThemeOption(
                          context: context,
                          label: 'Light',
                          icon: Icons.light_mode_rounded,
                          isSelected: settings.themeMode == ThemeMode.light,
                          onTap: () => settings.setThemeMode(ThemeMode.light),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildThemeOption(
                          context: context,
                          label: 'Dark',
                          icon: Icons.dark_mode_rounded,
                          isSelected: settings.themeMode == ThemeMode.dark,
                          onTap: () => settings.setThemeMode(ThemeMode.dark),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
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

          // Section: Audio & Haptics (Disabled for now with iOS coming-soon prompt)
          _buildSectionHeader(AppStrings.audioHapticsSection, isDark),
          _buildCardWrapper(
            isDark: isDark,
            children: [
              SwitchListTile(
                value: false,
                onChanged: (_) => _showComingSoonDialog(context, 'Sound Effects'),
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
              const Divider(),
              SwitchListTile(
                value: false,
                onChanged: (_) => _showComingSoonDialog(context, 'Haptic Feedback'),
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

          // Section: About
          _buildSectionHeader(AppStrings.aboutSection, isDark),
          _buildCardWrapper(
            isDark: isDark,
            children: [
              // Version item (directly linked with versionName and versionCode)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                ),
                title: const Text(
                  'Version',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: const Text(
                  '${AppStrings.versionName} (${AppStrings.versionCode})',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const Divider(),

              // Developed by item (Bold Zahra ini with Branding Green Color)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.code_rounded, color: AppColors.primary, size: 20),
                ),
                title: const Text(
                  'Developed by',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: const Text(
                  'Zahra ini',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Divider(),

              // Privacy Policy item (Directly launches Flycricket URL in Browser)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.security_rounded, color: AppColors.accent, size: 20),
                ),
                title: const Text(
                  'Privacy Policy',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  '100% offline & private on-device notes',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => _openPrivacyPolicy(context),
              ),
              const Divider(),

              // Rate Us item (Directly launches Play Store)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBBF24).withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.star_rounded, color: Color(0xFFFBBF24), size: 20),
                ),
                title: const Text(
                  'Rate Us',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Rate VerveJot on Google Play Store',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => _openRateUs(context),
              ),
            ],
          ),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Expanded(
      child: BouncingButton(
        shrinkScale: 0.93,
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.18)
                : (isDark ? AppColors.oledSurface : AppColors.lightBackground),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : (isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected
                    ? AppColors.primary
                    : (isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : Colors.black)
                      : (isDark ? AppColors.oledTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
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
    return Material(
      color: isDark ? AppColors.oledCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isDark ? AppColors.oledCardBorder : AppColors.lightCardBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }
}
