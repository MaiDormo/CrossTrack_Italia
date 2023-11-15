import 'package:crosstrack_italia/features/map/constants/map_constants.dart';
import 'package:crosstrack_italia/features/map/models/regions.dart';
import 'package:crosstrack_italia/features/map/notifiers/user_location_notifier.dart';
import 'package:crosstrack_italia/features/map/presentation/widget/marker/all_tracks_markers.dart';
import 'package:crosstrack_italia/features/map/presentation/widget/marker/lombardia_tracks_markers.dart';
import 'package:crosstrack_italia/features/map/presentation/widget/marker/trentino_alto_adige_tracks_markers.dart';
import 'package:crosstrack_italia/features/map/presentation/widget/marker/veneto_tracks_markers.dart';
import 'package:crosstrack_italia/features/map/providers/controller_utils.dart';
import 'package:crosstrack_italia/features/map/providers/floating_searching_bar_utils.dart';
import 'package:crosstrack_italia/features/track/notifiers/track_notifier.dart';
import 'package:crosstrack_italia/views/components/search_track/providers/search_track_provider.dart';
import 'package:crosstrack_italia/features/map/presentation/widget/panel_widget.dart';
import 'package:crosstrack_italia/views/components/tracks/track_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:material_floating_search_bar_2/material_floating_search_bar_2.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class MapScreenView extends ConsumerWidget {
  const MapScreenView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final _panelHeightClosed = MediaQuery.of(context).size.height * 0.1;
    final _panelHeightOpen = MediaQuery.of(context).size.height * 0.6;
    final mapController = ref.watch(mapControllerProvider);
    final panelController = ref.watch(panelControllerProvider);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SlidingUpPanel(
        controller: ref.watch(panelControllerProvider),
        minHeight: 0.0,
        maxHeight: _panelHeightOpen,
        parallaxEnabled: true,
        parallaxOffset: 0.5,
        color: Theme.of(context).colorScheme.secondary,
        body: ClipRRect(
          borderRadius: const BorderRadius.all(
            Radius.circular(20),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Map(mapController: mapController),
              FloatingSearchMapBar(),
            ],
          ),
        ),
        panelBuilder: (scrollController) => PanelWidget(
            scrollController: scrollController,
            panelController: panelController),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
    );
  }
}

class Map extends ConsumerWidget {
  const Map({
    super.key,
    required this.mapController,
  });

  final MapController mapController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: const LatLng(46.066775, 11.149904),
        zoom: 10.0,
        minZoom: 7.0,
        maxZoom: 18.0, // consider setting maxNativeZoom per TileLayer instead,
        // to allow tiles to scale (and lose quality) on the final zoom level, instead of setting a hard limit.

        //maxBounds: Limits how far the map can be moved by the user to a coordinate-based boundary
        interactiveFlags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        //keepAlive: true, in  order to keep the map from rebuilding in a nested widget tree (when out of sight)
      ),
      nonRotatedChildren: [
        RichAttributionWidget(
          permanentHeight: 15,
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
            ),
          ],
        ),
      ], //should not be used in order to keep the map in place
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.crosstrack_italia.app',
          tileProvider: FMTC.instance('mapStore').getTileProvider(),
        ),
        //contains layers
        //which themselves will contain all the makers

        Consumer(
          builder: (context, ref, child) {
            final hasLocationPermission =
                ref.watch<bool>(hasLocationPermissionProvider);
            final showCurrentLocation =
                ref.watch<bool>(showCurrentLocationProvider);
            final centerUserLocation = ref.watch(centerUserLocationProvider);
            if (showCurrentLocation && hasLocationPermission) {
              return CurrentLocationLayer(
                followOnLocationUpdate: centerUserLocation,
                turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
                style: LocationMarkerStyle(
                  marker: const DefaultLocationMarker(
                    color: Colors.red,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                    ),
                  ),
                  markerSize: const Size.square(35),
                  accuracyCircleColor: Colors.red.withOpacity(0.1),
                  headingSectorColor: Colors.red.withOpacity(0.8),
                  headingSectorRadius: 120,
                ),
                // moveAnimationDuration: Duration.zero,
              );
            } else {
              return Container();
            }
          },
        ),
        Consumer(
          builder: (context, ref, child) {
            final showCurrentLocation = ref.watch(showCurrentLocationProvider);
            return Positioned(
              top: 90,
              right: 8,
              child: FloatingActionButton(
                backgroundColor: showCurrentLocation
                    ? Colors.black
                    : Colors.black.withOpacity(0.5),
                onPressed: showCurrentLocation
                    ? () {
                        //wait for the map to center
                        ref.read(centerUserLocationProvider.notifier).follow();
                        Future.delayed(const Duration(milliseconds: 500), () {
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
            );
          },
        ),
        Consumer(
          builder: (context, ref, child) {
            final selectedRegion = ref.watch<Regions>(selectedRegionProvider);
            return switch (selectedRegion) {
              Regions.all => const AllTracksMarkers(),
              Regions.veneto => const VenetoTracksMarkers(),
              Regions.lombardia => const LombardiaTracksMarkers(),
              Regions.trentinoAltoAdige =>
                const TrentinoAltoAdigeTracksMarkers(),
            };
          },
        ),
        // Add cases for other regions
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
    final mapController = ref.watch(mapControllerProvider);

    return FloatingSearchBar(
      controller: ref.watch(floatingSearchBarControllerProvider),
      hint: 'Cerca...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      //progress: true, //TODO: da aggiungere quando avviene una ricerca
      axisAlignment: 0.0,
      openAxisAlignment: 0.0,
      width: 600,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
        ref
            .read(searchTrackStringProvider.notifier)
            .setSearchTrackString(query);
        ref.read(searchTrackProvider.notifier).onSearchTrack(
            query,
            ref.read(fetchAllTracksProvider).when(
                      data: (tracks) => tracks,
                      loading: () => [],
                      error: (error, stackTrace) => [],
                    ) ??
                []);
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),
        PopupMenuButton<Regions>(
          onSelected: (Regions result) {
            ref.read(selectedRegionProvider.notifier).setRegion(result);
            LatLng center;
            switch (result) {
              case Regions.veneto:
                //pop current marker Layer
                center = MapConstans.venice; // Replace with actual coordinates
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
            mapController.move(
                center,
                MapConstans
                    .defaultZoom); // Center the map on the selected region
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
        return Consumer(
          builder: (BuildContext context, WidgetRef ref, Widget? child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Material(
                color: Theme.of(context).colorScheme.primary,
                elevation: 4.0,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
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
        );
      },
    );
  }
}
