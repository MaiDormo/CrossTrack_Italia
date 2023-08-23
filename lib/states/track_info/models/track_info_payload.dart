import 'dart:collection' show MapView;

import 'package:crosstrack_italia/states/constants/firebase_field_name.dart';
import 'package:crosstrack_italia/states/track_info/models/typedefs/track_types.dart';
import 'package:flutter/foundation.dart' show immutable;

@immutable
class TrackInfoPayload extends MapView<String, dynamic> {
  TrackInfoPayload({
    required TrackId? trackId,
    required String? displayName,
    required String region,
    required String location,
    required String motoclub,
    required String? category,
    required List<String>? acceptedLicenses,
    required String? terrainType,
    required String? trackLength,
    required String? hasMinicross,
    required Map<String, String>? services,
    required List<String>? phones,
    required List<String>? fax,
    required String? email,
    required String? website,
    required String? info,
    required Map<String, String>? openingHours,
    required String latitude,
    required String longitude,
  }) : super({
          FirebaseFieldName.trackId: trackId ?? '',
          FirebaseFieldName.displayName: displayName ?? '',
          FirebaseFieldName.region: region,
          FirebaseFieldName.location: location,
          FirebaseFieldName.motoclub: motoclub,
          FirebaseFieldName.category: category ?? '',
          FirebaseFieldName.acceptedLicenses: acceptedLicenses ?? [],
          FirebaseFieldName.terrainType: terrainType ?? '',
          FirebaseFieldName.trackLength: trackLength ?? '',
          FirebaseFieldName.hasMinicross: hasMinicross ?? 'no',
          FirebaseFieldName.services: services ?? {},
          FirebaseFieldName.phones: phones ?? {},
          FirebaseFieldName.fax: fax ?? '',
          FirebaseFieldName.email: email ?? '',
          FirebaseFieldName.website: website ?? '',
          FirebaseFieldName.info: info ?? '',
          FirebaseFieldName.openingHours: openingHours ?? {},
          FirebaseFieldName.latitude: latitude,
          FirebaseFieldName.longitude: longitude,
        });
}
