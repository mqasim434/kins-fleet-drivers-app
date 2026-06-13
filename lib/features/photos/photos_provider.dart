import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:kins_fleet_drivers/core/imagekit/imagekit_config.dart';
import 'package:kins_fleet_drivers/core/imagekit/imagekit_models.dart';
import 'package:kins_fleet_drivers/core/utils/date_utils.dart';
import 'package:kins_fleet_drivers/features/photos/models/bus_option.dart';
import 'package:kins_fleet_drivers/features/photos/models/bus_photo.dart';
import 'package:kins_fleet_drivers/features/photos/photos_repository.dart';

enum PhotoErrorKey {
  loadFailed,
  imageKitNotConfigured,
  fileTooLarge,
  invalidType,
  uploadFailed,
  saveFailed,
  busRequired,
}

class PhotosProvider extends ChangeNotifier {
  PhotosProvider(this._repository);

  final PhotosRepository _repository;

  List<BusPhoto> photos = [];
  List<BusOption> busOptions = [];
  BusOption? selectedBus;
  DateTime selectedDate = DateTime.now();
  String notes = '';

  bool isLoading = false;
  bool isLoadingBuses = false;
  bool isUploading = false;
  int uploadPercent = 0;
  bool hasError = false;
  PhotoErrorKey? errorKey;
  String? debugError;

  String get selectedDateIso => AppDateUtils.todayIsoFrom(selectedDate);

  List<BusOption> get todayShiftBuses =>
      busOptions.where((bus) => bus.fromTodayShift).toList();

  List<BusOption> get otherBuses =>
      busOptions.where((bus) => !bus.fromTodayShift).toList();

  Future<void> load({
    required String driverId,
    required String uid,
  }) async {
    isLoading = true;
    hasError = false;
    errorKey = null;
    debugError = null;
    notifyListeners();

    try {
      await Future.wait([
        _loadPhotos(uid),
        _loadBusOptions(driverId),
      ]);
    } on FirebaseException catch (error) {
      hasError = true;
      errorKey = PhotoErrorKey.loadFailed;
      debugError = '${error.code}: ${error.message}';
      if (kDebugMode) {
        debugPrint('PhotosProvider.load failed: $debugError');
      }
    } on Exception catch (error) {
      hasError = true;
      errorKey = PhotoErrorKey.loadFailed;
      debugError = error.toString();
      if (kDebugMode) {
        debugPrint('PhotosProvider.load failed: $debugError');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh({
    required String driverId,
    required String uid,
  }) =>
      load(driverId: driverId, uid: uid);

  Future<void> _loadPhotos(String uid) async {
    photos = await _repository.fetchMyPhotos(uid);
  }

  Future<void> _loadBusOptions(String driverId) async {
    isLoadingBuses = true;
    notifyListeners();

    try {
      busOptions = await _repository.fetchBusOptions(driverId);
      if (selectedBus != null &&
          !busOptions.any((bus) => bus.id == selectedBus!.id)) {
        selectedBus = null;
      }
      selectedBus ??= todayShiftBuses.isNotEmpty ? todayShiftBuses.first : null;
    } finally {
      isLoadingBuses = false;
    }
  }

  void selectBus(BusOption? bus) {
    selectedBus = bus;
    notifyListeners();
  }

  void selectDate(DateTime date) {
    selectedDate = date;
    notifyListeners();
  }

  void updateNotes(String value) {
    notes = value;
  }

  void clearUploadError() {
    errorKey = null;
    notifyListeners();
  }

  Future<bool> uploadFromFile({
    required File file,
    required String uploadedBy,
    required String uploadedByName,
  }) async {
    if (!ImageKitConfig.isUploadReady) {
      errorKey = PhotoErrorKey.imageKitNotConfigured;
      notifyListeners();
      return false;
    }

    if (selectedBus == null) {
      errorKey = PhotoErrorKey.busRequired;
      notifyListeners();
      return false;
    }

    isUploading = true;
    uploadPercent = 0;
    errorKey = null;
    debugError = null;
    notifyListeners();

    try {
      final photo = await _repository.uploadPhoto(
        bus: selectedBus!,
        dateIso: selectedDateIso,
        notes: notes.trim(),
        uploadedBy: uploadedBy,
        uploadedByName: uploadedByName,
        file: file,
        onProgress: (percent) {
          uploadPercent = percent;
          notifyListeners();
        },
      );

      photos.insert(0, photo);
      notes = '';
      return true;
    } on ImageKitException catch (error) {
      errorKey = _mapImageKitError(error.message);
      debugError = error.message;
      if (kDebugMode) {
        debugPrint('PhotosProvider.upload failed: $debugError');
      }
      return false;
    } on FirebaseException catch (error) {
      errorKey = PhotoErrorKey.saveFailed;
      debugError = '${error.code}: ${error.message}';
      if (kDebugMode) {
        debugPrint('PhotosProvider.upload failed: $debugError');
      }
      return false;
    } on Exception catch (error) {
      errorKey = PhotoErrorKey.uploadFailed;
      debugError = error.toString();
      if (kDebugMode) {
        debugPrint('PhotosProvider.upload failed: $debugError');
      }
      return false;
    } finally {
      isUploading = false;
      uploadPercent = 0;
      notifyListeners();
    }
  }

  PhotoErrorKey _mapImageKitError(String message) {
    switch (message) {
      case 'file_too_large':
        return PhotoErrorKey.fileTooLarge;
      case 'invalid_type':
        return PhotoErrorKey.invalidType;
      case 'ImageKit not configured':
        return PhotoErrorKey.imageKitNotConfigured;
      default:
        return PhotoErrorKey.uploadFailed;
    }
  }
}
