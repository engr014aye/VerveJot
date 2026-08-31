import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/database/database_helper.dart';
import '../../data/models/backup_data_model.dart';

class BackupService {
  static final BackupService instance = BackupService._internal();
  BackupService._internal();

  Future<File> exportBackupToFile() async {
    final backup = await DatabaseHelper.instance.exportAllData();
    final jsonString = backup.encode();

    final dir = await getApplicationDocumentsDirectory();
    final dateStr = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final file = File('${dir.path}/vervejot_backup_$dateStr.json');
    await file.writeAsString(jsonString);

    return file;
  }

  Future<void> shareBackup() async {
    final file = await exportBackupToFile();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        subject: 'VerveJot Backup - ${DateTime.now().toString().split(' ').first}',
        text: 'VerveJot local data backup export.',
      ),
    );
  }

  Future<BackupDataModel> validateAndParse(String rawJson) async {
    try {
      final model = BackupDataModel.decode(rawJson);
      return model;
    } catch (e) {
      throw FormatException('Invalid or corrupted VerveJot backup format: $e');
    }
  }

  Future<void> restoreFromBackup(
    BackupDataModel backup, {
    bool replaceExisting = false,
  }) async {
    await DatabaseHelper.instance.importAllData(
      backup,
      replaceExisting: replaceExisting,
    );
  }
}
