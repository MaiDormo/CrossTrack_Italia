import 'package:crosstrack_italia/features/map/constants/map_constants.dart';
import 'package:crosstrack_italia/features/map/models/regions.dart';
import 'package:crosstrack_italia/features/map/notifiers/map_notifier.dart';
import 'package:crosstrack_italia/features/map/notifiers/user_location_notifier.dart';
import 'package:crosstrack_italia/features/map/presentation/widget/marker/all_tracks_markers.dart';
import 'package:crosstrack_italia/features/map/presentation/widget/marker/lombardia_tracks_markers.dart';
import 'package:crosstrack_italia/features/map/presentation/widget/marker/trentino_alto_adige_tracks_markers.dart';
import 'package:crosstrack_italia/features/map/presentation/widget/marker/veneto_tracks_markers.dart';
import 'package:crosstrack_italia/features/map/providers/controller_utils.dart';
import 'package:crosstrack_italia/features/map/providers/floating_searching_bar_utils.dart';
import 'package:crosstrack_italia/features/track/notifiers/track_notifier.dart';
import 'package:crosstrack_italia/features/track/presentation/track_card.dart';
import 'package:crosstrack_italia/features/track/providers/search_track_provider.dart';
import 'package:crosstrack_italia/features/map/presentation/panel_widget.dart';
import 'package:crosstrack_italia/features/user_info/notifiers/user_permission_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

//------------------RIVERPOD------------------//
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _panelHeightOpen = 526.h;
    final panelController = ref.watch(panelControllerProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0).h,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(20),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Theme.of(context).colorScheme.background,
          body: SafeArea(
            child: SlidingUpPanel(
              controller: ref.watch(panelControllerProvider),
              minHeight: 0.0,
              maxHeight: _panelHeightOpen,
              parallaxEnabled: true,
              parallaxOffset: 0.5,
              color: Theme.of(context).colorScheme.secondary,
              body: const ClipRRect(
                borderRadius: const BorderRadius.all(
                  Radius.circular(20),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const Map(),
                    const FloatingSearchMapBar(),
                  ],
                ),
              ),
              panelBuilder: (scrollController) => SafeArea(
                child: PanelWidget(null,
                    hideDragHandle: false,
                    scrollController: scrollController,
                    panelController: panelController),
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Map extends ConsumerStatefulWidget {
  const Map({
    Key? key,
  }) : super(key: key);

  @override
  _MapState createState() => _MapState();
}

class _MapState extends ConsumerState<Map> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _animatedMapController = ref.watch(animatedMapControllerProvider);
    final locationPermission = ref.watch(locationPermissionProvider);
    final showCurrentLocation = ref.watch(showCurrentLocationProvider);
    final centerUserLocation = ref.watch(centerUserLocationProvider);
    final selectedRegion = ref.watch(selectedRegionProvider);

    return FlutterMap(
      mapController: _animatedMapController.mapController,
      options: MapOptions(
        center: const LatLng(46.066775, 11.149904),
        zoom: 10.0,
        minZoom: 7.0,
        maxZoom: 18.0,
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        onTap: (tapPosition, position) {
          ref.read(panelControllerProvider).close();
          ref.read(popupControllerProvider).hideAllPopups();
        }, //close panel when tap on map
      ),
      nonRotatedChildren: [
        RichAttributionWidget(
          permanentHeight: 15.h,
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
            ),
          ],
        ),
      ],
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.crosstrack_italia.app',
          tileProvider: FMTC.instance('mapStore').getTileProvider(),
        ),
        //contains layers
        //which themselves will contain all the makers

        switch (locationPermission) {
          AsyncData(:final value) => value && showCurrentLocation
              ? CurrentLocationLayer(
                  followOnLocationUpdate: centerUserLocation,
                  turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
                  style: LocationMarkerStyle(
                    marker: DefaultLocationMarker(
                      color: Theme.of(context).colorScheme.secondary,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    markerSize: const Size.square(35),
                    showHeadingSector: false,
                  ),
                  // moveAnimationDuration: Duration.zero,
                )
              : const SizedBox.shrink(),
          AsyncError() => const Center(child: Icon(Icons.error)),
          _ => const Center(child: CircularProgressIndicator()),
        },

        switch (locationPermission) {
          AsyncData(:final value) => Positioned(
              top: 90,
              right: 8,
              child: Padding(
                padding: const EdgeInsets.all(8.0).r,
                child: Visibility(
                  visible: value,
                  child: Opacity(
                    opacity: showCurrentLocation ? 1 : 0.5,
                    child: FloatingActionButton(
                      backgroundColor: showCurrentLocation
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey[300],
                      onPressed: showCurrentLocation && value
                          ? () {
                              //wait for the map to center
                              ref
                                  .read(centerUserLocationProvider.notifier)
                                  .follow();
                              Future.delayed(const Duration(milliseconds: 500),
                                  () {
                                ref
                                    .read(centerUserLocationProvider.notifier)
                                    .stopFollowing();
                              });
                            }
                          : null,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          AsyncError() => const Positioned(
              top: 90,
              right: 8,
              child: Icon(
                Icons.error,
              ),
            ),
          _ => const Positioned(
              top: 90,
              right: 8,
              child: CircularProgressIndicator(),
            ),
        },

        switch (selectedRegion) {
          Regions.all => const AllTracksMarkers(),
          Regions.veneto => const VenetoTracksMarkers(),
          Regions.lombardia => const LombardiaTracksMarkers(),
          Regions.trentinoAltoAdige => const TrentinoAltoAdigeTracksMarkers(),
        }
      ],
    );
  }
}

class FloatingSearchMapBar extends ConsumerWidget {
  const FloatingSearchMapBar({
    super.key,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = ref.watch(searchTrackProvider);
    final _animatedMapController = ref.watch(animatedMapControllerProvider);
    bool isLoading = false;
    return Padding(
      padding: const EdgeInsets.all(8.0).r,
      child: FloatingSearchBar(
        shadowColor: Colors.transparent,
        showCursor: false,
        borderRadius: BorderRadius.circular(20.0),
        backgroundColor: Theme.of(context).colorScheme.onSecondary,
        controller: ref.watch(floatingSearchBarControllerProvider),
        hint: 'Cerca...',
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
        ),
        queryStyle: TextStyle(
          color: Theme.of(context).colorScheme.secondary,
          fontWeight: FontWeight.normal,
        ),
        scrollPadding: EdgeInsets.only(top: 16.h, bottom: 56.h),
        transitionDuration: const Duration(milliseconds: 500),
        transitionCurve: Curves.easeInOut,
        physics: const BouncingScrollPhysics(),
        progress: isLoading,
        axisAlignment: 0.0,
        openAxisAlignment: 0.0,
        width: 600.w,
        debounceDelay: const Duration(milliseconds: 500),
        onFocusChanged: (isFocused) => isFocused == true
            ? ref.read(searchTrackProvider.notifier).onSearchTrack(
                '',
                ref.read(fetchAllTracksProvider).when(
                      data: (tracks) {
                        isLoading = false;
                        return tracks;
                      },
                      loading: () {
                        isLoading = true;
                        return {};
                      },
                      error: (error, stackTrace) {
                        isLoading = false;
                        return [];
                      },
                    ) ??
                    [])
            : null,
        onQueryChanged: (query) {
          ref.read(searchTrackProvider.notifier).onSearchTrack(
              query.trim(),
              ref.read(fetchAllTracksProvider).when(
                    data: (tracks) {
                      isLoading = false;
                      return tracks;
                    },
                    loading: () {
                      isLoading = true;
                      return [];
                    },
                    error: (error, stackTrace) {
                      isLoading = false;
                      return [];
                    },
                  ) ??
                  []);
        },
        transition: SlideFadeFloatingSearchBarTransition(),
        actions: [
          FloatingSearchBarAction.searchToClear(
            showIfClosed: false,
            color: Theme.of(context).colorScheme.secondary,
          ),
          PopupMenuButton<Regions>(
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            icon: const Icon(Icons.filter_alt),
            color: Theme.of(context).colorScheme.onSecondary,
            iconColor: Theme.of(context).colorScheme.secondary,
            onSelected: (Regions result) {
              ref.read(selectedRegionProvider.notifier).setRegion(result);
              LatLng center;
              switch (result) {
                case Regions.veneto:
                  center = MapConstans.venice;
                  break;
                case Regions.lombardia:
                  center = MapConstans.milan;
                  break;
                case Regions.trentinoAltoAdige:
                  center = MapConstans.trento;
                  break;
                default:
                  center = MapConstans.defaultLocation;
              }
              _animatedMapController.animateTo(
                dest: center,
                zoom: MapConstans.defaultZoom,
              ); // Center the map on the selected region
              // Update markers here based on the selected region
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Regions>>[
              const PopupMenuItem<Regions>(
                value: Regions.all,
                child: Text(MapConstans.all),
              ),
              const PopupMenuItem<Regions>(
                value: Regions.veneto,
                child: Text(MapConstans.veneto),
              ),
              // Add more PopupMenuItem entries for other regions
              const PopupMenuItem<Regions>(
                value: Regions.lombardia,
                child: Text(MapConstans.lombardia),
              ),
              const PopupMenuItem<Regions>(
                value: Regions.trentinoAltoAdige,
                child: Text(MapConstans.trentinoAltoAdige),
              ),
            ],
          ),
        ],
        builder: (context, transition) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(20.0),
            child: Material(
              color: Theme.of(context).colorScheme.primary,
              elevation: 4.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0).r,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...searchController.map(
                      (track) => TrackCard(track: track),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
