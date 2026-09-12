import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/in_app_update_service.dart';
import '../../core/widgets/bouncing_button.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final uri = Uri.parse(AppStrings.privacyPolicyUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
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

  Future<void> _checkForUpdates(BuildContext context) async {
    AudioService().playTap();

    showCupertinoDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const CupertinoAlertDialog(
        title: Text('Checking for Updates'),
        content: Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: CupertinoActivityIndicator(radius: 12),
        ),
      ),
    );

    final status = await InAppUpdateService().checkUpdateManual();
    if (!context.mounted) return;
    Navigator.of(context).pop(); // dismiss loading

    String title;
    String message;

    switch (status) {
      case UpdateCheckStatus.updateAvailable:
        title = 'Update Available';
        message = 'A new version of VerveJot is available on Google Play. Follow the prompt to install.';
        break;
      case UpdateCheckStatus.upToDate:
        title = 'Up to Date';
        message = 'VerveJot ${AppStrings.versionName} is currently the latest version available.';
        break;
      case UpdateCheckStatus.failed:
      case UpdateCheckStatus.notSupported:
        title = 'Google Play Store Check';
        message = 'Updates are distributed through the Google Play Store once published to Closed Testing or Production tracks.';
        break;
    }

    if (context.mounted) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: Text(title),
          content: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(message),
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
          onTap: () {
            AudioService().playTap();
            Navigator.of(context).pop();
          },
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
                          onTap: () {
                            AudioService().playTap();
                            settings.setThemeMode(ThemeMode.system);
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildThemeOption(
                          context: context,
                          label: 'Light',
                          icon: Icons.light_mode_rounded,
                          isSelected: settings.themeMode == ThemeMode.light,
                          onTap: () {
                            AudioService().playTap();
                            settings.setThemeMode(ThemeMode.light);
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildThemeOption(
                          context: context,
                          label: 'Dark',
                          icon: Icons.dark_mode_rounded,
                          isSelected: settings.themeMode == ThemeMode.dark,
                          onTap: () {
                            AudioService().playTap();
                            settings.setThemeMode(ThemeMode.dark);
                          },
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
                onChanged: (_) {
                  AudioService().playTap();
                  settings.toggleViewMode();
                },
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

          // Section: Audio & Haptics (Re-activated with Volume Control)
          _buildSectionHeader(AppStrings.audioHapticsSection, isDark),
          _buildCardWrapper(
            isDark: isDark,
            children: [
              SwitchListTile(
                value: settings.soundEnabled,
                onChanged: (val) {
                  settings.setSoundEnabled(val);
                  if (val) AudioService().playTap();
                },
                title: const Text(
                  AppStrings.soundEffects,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Crisp tactile paper rustles, tap clicks, and save chimes',
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        settings.soundVolume > 0.5
                            ? Icons.volume_up_rounded
                            : (settings.soundVolume > 0
                                ? Icons.volume_down_rounded
                                : Icons.volume_mute_rounded),
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Slider(
                          value: settings.soundVolume,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          activeColor: AppColors.primary,
                          inactiveColor: isDark ? Colors.white12 : Colors.black12,
                          onChanged: (vol) {
                            settings.setSoundVolume(vol);
                          },
                          onChangeEnd: (vol) {
                            AudioService().playTap();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(settings.soundVolume * 100).round()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Divider(),
              SwitchListTile(
                value: settings.hapticsEnabled,
                onChanged: (val) {
                  settings.setHapticsEnabled(val);
                  if (val) AudioService().playTap(haptic: true);
                },
                title: const Text(
                  AppStrings.hapticFeedback,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Subtle tactile vibration on taps, buttons, and drag interactions',
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
              // Version item
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

              // Check for Updates item
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.system_update_rounded, color: Color(0xFF38BDF8), size: 20),
                ),
                title: const Text(
                  'Check for Updates',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                subtitle: Text(
                  'Check Google Play Store for new version releases',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.oledTextMuted : AppColors.lightTextMuted,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                onTap: () => _checkForUpdates(context),
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
