class AppStrings {
  AppStrings._();

  static const String appName = 'VerveJot';
  static const String appTagline = 'Daily Notes & Tasks';
  static const String versionName = '1.1.1';
  static const String versionCode = '3';
  static const String version = '1.1.1 (3)';
  static const String developerName = 'Zahra ini';
  static const String privacyPolicyUrl = 'https://doc-hosting.flycricket.io/vervejot-privacy-policy/4c4cb463-fff5-4c6d-bbef-cec84bf1c1b1/privacy';

  // Tabs
  static const String tabAllNotes = 'All Notes';
  static const String tabPinned = 'Pinned';
  static const String tabTasks = 'Daily Tasks';
  static const String tabFolders = 'Folders';

  // Empty states
  static const String emptyNotesTitle = 'No Notes Yet';
  static const String emptyNotesSubtitle = 'Capture your thoughts, ideas, or meeting notes with high-fidelity markdown.';
  static const String emptyPinnedTitle = 'No Pinned Notes';
  static const String emptyPinnedSubtitle = 'Pin your critical notes to access them instantly from here.';
  static const String emptyTasksTitle = 'All Caught Up!';
  static const String emptyTasksSubtitle = 'Add daily action items to stay on top of your schedule.';
  static const String emptyFoldersTitle = 'No Folders Created';
  static const String emptyFoldersSubtitle = 'Create folders with custom colors and icons to organize your life.';

  // Actions
  static const String createNote = 'New Note';
  static const String createTask = 'New Task';
  static const String createFolder = 'New Folder';
  static const String editNote = 'Edit Note';
  static const String deleteNote = 'Delete Note';
  static const String searchHint = 'Search notes & tasks...';

  // Settings
  static const String settingsTitle = 'Settings';
  static const String appearanceSection = 'Appearance';
  static const String audioHapticsSection = 'Audio & Feedback';
  static const String aboutSection = 'About';

  static const String oledDarkMode = 'OLED True Black';
  static const String soundEffects = 'Sound Effects';
  static const String soundVolume = 'Sound Volume';
  static const String hapticFeedback = 'Haptic Feedback';

  // Privacy Policy & About
  static const String privacyPolicyTitle = 'Privacy Policy';
  static const String privacyPolicyContent = '''
VerveJot is built with a 100% offline-first architecture. 

• Local Storage: All your notes, folders, and daily tasks are stored locally on your device in an encrypted/private SQLite database.
• Zero Data Collection: We do not collect, track, store, or transmit any of your personal data, notes, or usage analytics.
• Zero Internet Permissions: VerveJot operates completely offline and requires no internet access.
• User Control: You retain full ownership and control over your data.
''';
}
