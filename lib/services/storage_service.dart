// services/storage_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase Storage Service
/// Handles all file upload/download operations using Firebase Storage
class StorageService {
  // Singleton pattern
  static StorageService? _instance;
  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  StorageService._();

  // Firebase Storage instance
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== STORAGE REFERENCES ====================

  /// Get reference to profile pictures folder
  Reference get profilePicturesRef => _storage.ref().child('profile_pictures');

  /// Get reference to documents folder
  Reference get documentsRef => _storage.ref().child('documents');

  /// Get reference to notices folder
  Reference get noticesRef => _storage.ref().child('notices');

  /// Get reference to maintenance folder
  Reference get maintenanceRef => _storage.ref().child('maintenance');

  /// Get reference to events folder
  Reference get eventsRef => _storage.ref().child('events');

  /// Get reference to society assets folder
  Reference get societyAssetsRef => _storage.ref().child('society_assets');

  // ==================== UPLOAD METHODS ====================

  /// Upload profile picture
  /// Returns download URL on success
  Future<StorageResult> uploadProfilePicture({
    required String userId,
    required File file,
    void Function(double)? onProgress,
  }) async {
    try {
      final String extension = file.path.split('.').last.toLowerCase();
      final String fileName = '$userId.$extension';
      final Reference ref = profilePicturesRef.child(fileName);

      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/$extension',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // Listen to progress
      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress =
              snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      // Wait for upload to complete
      await uploadTask;

      // Get download URL
      final String downloadUrl = await ref.getDownloadURL();

      return StorageResult.success(
        url: downloadUrl,
        path: ref.fullPath,
        message: 'Profile picture uploaded successfully',
      );
    } on FirebaseException catch (e) {
      return StorageResult.failure(_getStorageErrorMessage(e.code));
    } catch (e) {
      return StorageResult.failure('Failed to upload profile picture: ${e.toString()}');
    }
  }

  /// Upload profile picture from bytes (for web)
  Future<StorageResult> uploadProfilePictureBytes({
    required String userId,
    required Uint8List bytes,
    required String extension,
    void Function(double)? onProgress,
  }) async {
    try {
      final String fileName = '$userId.$extension';
      final Reference ref = profilePicturesRef.child(fileName);

      final UploadTask uploadTask = ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/$extension',
          customMetadata: {
            'userId': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress =
              snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await uploadTask;
      final String downloadUrl = await ref.getDownloadURL();

      return StorageResult.success(
        url: downloadUrl,
        path: ref.fullPath,
        message: 'Profile picture uploaded successfully',
      );
    } on FirebaseException catch (e) {
      return StorageResult.failure(_getStorageErrorMessage(e.code));
    } catch (e) {
      return StorageResult.failure('Failed to upload profile picture: ${e.toString()}');
    }
  }

  /// Upload document (PDF, images, etc.)
  Future<StorageResult> uploadDocument({
    required String userId,
    required File file,
    required String documentType, // e.g., 'id_proof', 'address_proof', etc.
    void Function(double)? onProgress,
  }) async {
    try {
      final String extension = file.path.split('.').last.toLowerCase();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${userId}_${documentType}_$timestamp.$extension';
      final Reference ref = documentsRef.child(userId).child(fileName);

      String contentType = _getContentType(extension);

      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'userId': userId,
            'documentType': documentType,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress =
              snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await uploadTask;
      final String downloadUrl = await ref.getDownloadURL();

      return StorageResult.success(
        url: downloadUrl,
        path: ref.fullPath,
        message: 'Document uploaded successfully',
      );
    } on FirebaseException catch (e) {
      return StorageResult.failure(_getStorageErrorMessage(e.code));
    } catch (e) {
      return StorageResult.failure('Failed to upload document: ${e.toString()}');
    }
  }

  /// Upload notice attachment
  Future<StorageResult> uploadNoticeAttachment({
    required String noticeId,
    required File file,
    void Function(double)? onProgress,
  }) async {
    try {
      final String extension = file.path.split('.').last.toLowerCase();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${noticeId}_$timestamp.$extension';
      final Reference ref = noticesRef.child(fileName);

      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: _getContentType(extension),
          customMetadata: {
            'noticeId': noticeId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress =
              snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await uploadTask;
      final String downloadUrl = await ref.getDownloadURL();

      return StorageResult.success(
        url: downloadUrl,
        path: ref.fullPath,
        message: 'Attachment uploaded successfully',
      );
    } on FirebaseException catch (e) {
      return StorageResult.failure(_getStorageErrorMessage(e.code));
    } catch (e) {
      return StorageResult.failure('Failed to upload attachment: ${e.toString()}');
    }
  }

  /// Upload maintenance request attachment (images of issues, etc.)
  Future<StorageResult> uploadMaintenanceAttachment({
    required String requestId,
    required File file,
    void Function(double)? onProgress,
  }) async {
    try {
      final String extension = file.path.split('.').last.toLowerCase();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${requestId}_$timestamp.$extension';
      final Reference ref = maintenanceRef.child(fileName);

      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: _getContentType(extension),
          customMetadata: {
            'requestId': requestId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress =
              snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await uploadTask;
      final String downloadUrl = await ref.getDownloadURL();

      return StorageResult.success(
        url: downloadUrl,
        path: ref.fullPath,
        message: 'Attachment uploaded successfully',
      );
    } on FirebaseException catch (e) {
      return StorageResult.failure(_getStorageErrorMessage(e.code));
    } catch (e) {
      return StorageResult.failure('Failed to upload attachment: ${e.toString()}');
    }
  }

  /// Upload event image
  Future<StorageResult> uploadEventImage({
    required String eventId,
    required File file,
    void Function(double)? onProgress,
  }) async {
    try {
      final String extension = file.path.split('.').last.toLowerCase();
      final String fileName = '$eventId.$extension';
      final Reference ref = eventsRef.child(fileName);

      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: 'image/$extension',
          customMetadata: {
            'eventId': eventId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress =
              snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await uploadTask;
      final String downloadUrl = await ref.getDownloadURL();

      return StorageResult.success(
        url: downloadUrl,
        path: ref.fullPath,
        message: 'Event image uploaded successfully',
      );
    } on FirebaseException catch (e) {
      return StorageResult.failure(_getStorageErrorMessage(e.code));
    } catch (e) {
      return StorageResult.failure('Failed to upload event image: ${e.toString()}');
    }
  }

  /// Generic file upload
  Future<StorageResult> uploadFile({
    required String path,
    required File file,
    Map<String, String>? metadata,
    void Function(double)? onProgress,
  }) async {
    try {
      final String extension = file.path.split('.').last.toLowerCase();
      final Reference ref = _storage.ref().child(path);

      final UploadTask uploadTask = ref.putFile(
        file,
        SettableMetadata(
          contentType: _getContentType(extension),
          customMetadata: metadata,
        ),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress =
              snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await uploadTask;
      final String downloadUrl = await ref.getDownloadURL();

      return StorageResult.success(
        url: downloadUrl,
        path: ref.fullPath,
        message: 'File uploaded successfully',
      );
    } on FirebaseException catch (e) {
      return StorageResult.failure(_getStorageErrorMessage(e.code));
    } catch (e) {
      return StorageResult.failure('Failed to upload file: ${e.toString()}');
    }
  }

  // ==================== DOWNLOAD METHODS ====================

  /// Get download URL for a file
  Future<String?> getDownloadUrl(String path) async {
    try {
      return await _storage.ref().child(path).getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  /// Download file to local path
  Future<StorageResult> downloadFile({
    required String storagePath,
    required String localPath,
    void Function(double)? onProgress,
  }) async {
    try {
      final Reference ref = _storage.ref().child(storagePath);
      final File localFile = File(localPath);

      final DownloadTask downloadTask = ref.writeToFile(localFile);

      if (onProgress != null) {
        downloadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final double progress =
              snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      await downloadTask;

      return StorageResult.success(
        path: localPath,
        message: 'File downloaded successfully',
      );
    } on FirebaseException catch (e) {
      return StorageResult.failure(_getStorageErrorMessage(e.code));
    } catch (e) {
      return StorageResult.failure('Failed to download file: ${e.toString()}');
    }
  }

  /// Download file as bytes
  Future<Uint8List?> downloadFileAsBytes(String path) async {
    try {
      final Reference ref = _storage.ref().child(path);
      // Max 10MB
      return await ref.getData(10 * 1024 * 1024);
    } catch (e) {
      return null;
    }
  }

  // ==================== DELETE METHODS ====================

  /// Delete profile picture
  Future<StorageResult> deleteProfilePicture(String userId) async {
    try {
      // Try common extensions
      final extensions = ['jpg', 'jpeg', 'png', 'webp'];
      
      for (final ext in extensions) {
        try {
          await profilePicturesRef.child('$userId.$ext').delete();
          return StorageResult.success(message: 'Profile picture deleted successfully');
        } catch (_) {
          // Continue to next extension
        }
      }
      
      return StorageResult.failure('Profile picture not found');
    } on FirebaseException catch (e) {
      return StorageResult.failure(_getStorageErrorMessage(e.code));
    } catch (e) {
      return StorageResult.failure('Failed to delete profile picture: ${e.toString()}');
    }
  }

  /// Delete file by path
  Future<StorageResult> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
      return StorageResult.success(message: 'File deleted successfully');
    } on FirebaseException catch (e) {
      return StorageResult.failure(_getStorageErrorMessage(e.code));
    } catch (e) {
      return StorageResult.failure('Failed to delete file: ${e.toString()}');
    }
  }

  /// Delete all files in a folder
  Future<StorageResult> deleteFolder(String folderPath) async {
    try {
      final ListResult result = await _storage.ref().child(folderPath).listAll();

      // Delete all files
      for (final Reference ref in result.items) {
        await ref.delete();
      }

      // Recursively delete subfolders
      for (final Reference prefix in result.prefixes) {
        await deleteFolder(prefix.fullPath);
      }

      return StorageResult.success(message: 'Folder deleted successfully');
    } on FirebaseException catch (e) {
      return StorageResult.failure(_getStorageErrorMessage(e.code));
    } catch (e) {
      return StorageResult.failure('Failed to delete folder: ${e.toString()}');
    }
  }

  /// Delete user's documents folder
  Future<StorageResult> deleteUserDocuments(String userId) async {
    return await deleteFolder('documents/$userId');
  }

  // ==================== LIST METHODS ====================

  /// List all files in a folder
  Future<List<StorageFileInfo>> listFiles(String folderPath) async {
    try {
      final ListResult result = await _storage.ref().child(folderPath).listAll();
      
      final List<StorageFileInfo> files = [];
      
      for (final Reference ref in result.items) {
        final FullMetadata metadata = await ref.getMetadata();
        final String downloadUrl = await ref.getDownloadURL();
        
        files.add(StorageFileInfo(
          name: ref.name,
          path: ref.fullPath,
          downloadUrl: downloadUrl,
          size: metadata.size ?? 0,
          contentType: metadata.contentType ?? 'application/octet-stream',
          createdAt: metadata.timeCreated,
          updatedAt: metadata.updated,
          customMetadata: metadata.customMetadata,
        ));
      }
      
      return files;
    } catch (e) {
      return [];
    }
  }

  /// List user's documents
  Future<List<StorageFileInfo>> listUserDocuments(String userId) async {
    return await listFiles('documents/$userId');
  }

  // ==================== HELPER METHODS ====================

  /// Get content type from file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'xls':
        return 'application/vnd.ms-excel';
      case 'xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case 'txt':
        return 'text/plain';
      case 'mp4':
        return 'video/mp4';
      case 'mp3':
        return 'audio/mpeg';
      default:
        return 'application/octet-stream';
    }
  }

  /// Get user-friendly error message from Firebase Storage error code
  String _getStorageErrorMessage(String code) {
    switch (code) {
      case 'storage/unknown':
        return 'An unknown error occurred';
      case 'storage/object-not-found':
        return 'File not found';
      case 'storage/bucket-not-found':
        return 'Storage bucket not found';
      case 'storage/project-not-found':
        return 'Project not found';
      case 'storage/quota-exceeded':
        return 'Storage quota exceeded';
      case 'storage/unauthenticated':
        return 'Please login to upload files';
      case 'storage/unauthorized':
        return 'You don\'t have permission to perform this action';
      case 'storage/retry-limit-exceeded':
        return 'Upload failed. Please try again';
      case 'storage/invalid-checksum':
        return 'File corrupted during upload. Please try again';
      case 'storage/canceled':
        return 'Upload cancelled';
      case 'storage/invalid-event-name':
        return 'Invalid operation';
      case 'storage/invalid-url':
        return 'Invalid file URL';
      case 'storage/invalid-argument':
        return 'Invalid file';
      case 'storage/no-default-bucket':
        return 'Storage not configured properly';
      case 'storage/cannot-slice-blob':
        return 'File cannot be processed';
      case 'storage/server-file-wrong-size':
        return 'File size mismatch. Please try again';
      default:
        return 'Storage operation failed';
    }
  }
}

/// Storage operation result
class StorageResult {
  final bool isSuccess;
  final String message;
  final String? url;
  final String? path;

  StorageResult._({
    required this.isSuccess,
    required this.message,
    this.url,
    this.path,
  });

  factory StorageResult.success({
    String? url,
    String? path,
    required String message,
  }) {
    return StorageResult._(
      isSuccess: true,
      message: message,
      url: url,
      path: path,
    );
  }

  factory StorageResult.failure(String message) {
    return StorageResult._(
      isSuccess: false,
      message: message,
    );
  }
}

/// Storage file info model
class StorageFileInfo {
  final String name;
  final String path;
  final String downloadUrl;
  final int size;
  final String contentType;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, String>? customMetadata;

  StorageFileInfo({
    required this.name,
    required this.path,
    required this.downloadUrl,
    required this.size,
    required this.contentType,
    this.createdAt,
    this.updatedAt,
    this.customMetadata,
  });

  /// Get file size in human readable format
  String get formattedSize {
    if (size < 1024) {
      return '$size B';
    } else if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)} KB';
    } else if (size < 1024 * 1024 * 1024) {
      return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(size / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Check if file is an image
  bool get isImage => contentType.startsWith('image/');

  /// Check if file is a document
  bool get isDocument =>
      contentType.contains('pdf') ||
      contentType.contains('word') ||
      contentType.contains('excel') ||
      contentType.contains('text');

  /// Get file extension
  String get extension => name.split('.').last.toLowerCase();
}
