import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../utils/constants.dart';

/// Abstracts file system for ImageFlow app storage.
/// Creates /ImageFlow/faces/ and /ImageFlow/docs/ under app documents.
/// All heavy IO is done here so UI never blocks.
abstract class StorageService {
  /// Root directory for app files (e.g. .../ApplicationDocuments/ImageFlow).
  Future<Directory> getAppRoot();

  /// Directory for face result images.
  Future<Directory> getFacesDir();

  /// Directory for document PDFs.
  Future<Directory> getDocsDir();

  /// Build a unique file path under [dir] with optional [extension].
  /// Uses timestamp in filename for uniqueness and traceability.
  String uniquePath(Directory dir, {String? prefix, String extension = ''});

  /// Get file size in bytes. Returns 0 if file does not exist.
  Future<int> fileSize(String path);

  /// Delete file at path. No-op if file does not exist.
  Future<void> deleteFile(String path);
}

class StorageServiceImpl implements StorageService {
  Directory? _root;

  @override
  Future<Directory> getAppRoot() async {
    _root ??= await _ensureAppRoot();
    return _root!;
  }

  Future<Directory> _ensureAppRoot() async {
    final base = await getApplicationDocumentsDirectory();
    final root = Directory(p.join(base.path, AppConstants.appStorageFolder));
    if (!await root.exists()) {
      await root.create(recursive: true);
    }
    return root;
  }

  @override
  Future<Directory> getFacesDir() async {
    final root = await getAppRoot();
    final dir = Directory(p.join(root.path, AppConstants.facesSubfolder));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  @override
  Future<Directory> getDocsDir() async {
    final root = await getAppRoot();
    final dir = Directory(p.join(root.path, AppConstants.docsSubfolder));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  @override
  String uniquePath(Directory dir, {String? prefix, String extension = ''}) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    final name = prefix != null ? '${prefix}_$ts' : 'file_$ts';
    return p.join(dir.path, '$name$extension');
  }

  @override
  Future<int> fileSize(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) return await f.length();
    } catch (_) {}
    return 0;
  }

  @override
  Future<void> deleteFile(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
