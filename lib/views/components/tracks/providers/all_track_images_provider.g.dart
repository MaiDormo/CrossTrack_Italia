// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'all_track_images_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$allTrackImagesHash() => r'f6856bd61a4b1f585c5e04bb8c6576ade13a38ec';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

typedef AllTrackImagesRef = AutoDisposeStreamProviderRef<Iterable<Image>>;

/// See also [allTrackImages].
@ProviderFor(allTrackImages)
const allTrackImagesProvider = AllTrackImagesFamily();

/// See also [allTrackImages].
class AllTrackImagesFamily extends Family<AsyncValue<Iterable<Image>>> {
  /// See also [allTrackImages].
  const AllTrackImagesFamily();

  /// See also [allTrackImages].
  AllTrackImagesProvider call(
    TrackInfoModel? track,
  ) {
    return AllTrackImagesProvider(
      track,
    );
  }

  @override
  AllTrackImagesProvider getProviderOverride(
    covariant AllTrackImagesProvider provider,
  ) {
    return call(
      provider.track,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'allTrackImagesProvider';
}

/// See also [allTrackImages].
class AllTrackImagesProvider
    extends AutoDisposeStreamProvider<Iterable<Image>> {
  /// See also [allTrackImages].
  AllTrackImagesProvider(
    this.track,
  ) : super.internal(
          (ref) => allTrackImages(
            ref,
            track,
          ),
          from: allTrackImagesProvider,
          name: r'allTrackImagesProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$allTrackImagesHash,
          dependencies: AllTrackImagesFamily._dependencies,
          allTransitiveDependencies:
              AllTrackImagesFamily._allTransitiveDependencies,
        );

  final TrackInfoModel? track;

  @override
  bool operator ==(Object other) {
    return other is AllTrackImagesProvider && other.track == track;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, track.hashCode);

    return _SystemHash.finish(hash);
  }
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member
