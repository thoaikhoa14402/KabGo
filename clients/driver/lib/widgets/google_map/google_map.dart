import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:driver/models/location.dart';
import 'package:driver/providers/current_location.dart';
import 'package:driver/providers/socket_provider.dart';
import 'package:driver/widgets/icon_button/icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/customer_booking.dart';
import '../../models/direction_model.dart';
import '../../models/driver.dart';
import '../../models/vehicle.dart';
import '../../providers/customer_request.dart';

import 'dart:math' as math;

import '../../providers/request_status.dart';

class KGoogleMap extends ConsumerStatefulWidget {
  const KGoogleMap({Key? key}) : super(key: key);

  @override
  ConsumerState<KGoogleMap> createState() => _GoogleMapState();
}

class _GoogleMapState extends ConsumerState<KGoogleMap> {
  final Completer<GoogleMapController> _controller = Completer();

  late GoogleMapController _mapController;
  late Position _currentPosition;

  static bool running = true;
  static int process = 0;

  static const LatLng _center = LatLng(10.7552928, 106.3655788);
  static const CameraPosition _cameraPosition =
      CameraPosition(target: _center, zoom: 10, tilt: 0, bearing: 0);

  Set<Circle> _circles = {};
  Set<Marker> _markers = {};
  Set<Polyline> _polyline = {};

  late BitmapDescriptor currentLocationIcon;
  late BitmapDescriptor driverIcon;
  late BitmapDescriptor departureLocationIcon;

  Directions? _info;

  Circle _createCircle(String? id, LatLng latLng, {double radius = 50}) {
    id ??= 'circle_id_${DateTime.now().millisecondsSinceEpoch}';

    return Circle(
      circleId: CircleId(id),
      center: latLng,
      radius: radius == 0 ? radius * 1.5 : 50,
      fillColor: const Color.fromRGBO(255, 100, 51, 0.15),
      strokeColor: const Color.fromRGBO(255, 100, 51, 0.3),
      strokeWidth: 1,
    );
  }

  Marker _createMarker(
      String? id, String title, LatLng latLng, BitmapDescriptor icon,
      {double rotate = 0.0}) {
    id ??= 'marker_id_${DateTime.now().millisecondsSinceEpoch}';

    return Marker(
        markerId: MarkerId(id),
        position: latLng,
        infoWindow: InfoWindow(title: title),
        rotation: rotate,
        anchor: const Offset(0.5, 0.5),
        icon: icon);
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);

    DefaultAssetBundle.of(context)
        .loadString('lib/assets/map/map.json')
        .then((String value) async {
      _mapController = await _controller.future;
      await _mapController.setMapStyle(value);

      _moveToCurrent();
      // _livePosition();
    });
  }

  void _updateIconCurrentLocation(final currentPosition, { double rotate = 0.0 }) {
    final requestStatus = ref.watch(requestStatusProvider);

    if (requestStatus == RequestStatus.comming) {
      setState(() {
        _markers.add(_createMarker(
            'my_location',
            'Vị trí của tôi',
            LatLng(currentPosition.latitude, currentPosition.longitude),
            driverIcon, rotate: rotate));
        _circles.clear();
      });
      return;
    }

    setState(() {
      _markers.add(_createMarker(
          'my_location',
          'Vị trí của tôi',
          LatLng(currentPosition.latitude, currentPosition.longitude),
          currentLocationIcon));

      _circles.add(_createCircle('my_location',
          LatLng(currentPosition.latitude, currentPosition.longitude),
          radius: currentPosition.accuracy));
    });
  }

  void _moveToCurrent() {
    ref
        .read(currentLocationProvider.notifier)
        .getCurrentLocation()
        .then((value) {
      _currentPosition = value;

      _mapController.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target:
                  LatLng(_currentPosition.latitude, _currentPosition.longitude),
              zoom: 17,
              tilt: 0,
              bearing: 0)));

      _updateIconCurrentLocation(_currentPosition);
    });
  }

  void _livePosition() {
    LocationSettings settings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation, distanceFilter: 0);

    Geolocator.getPositionStream(locationSettings: settings)
        .listen((Position position) {
      // _mapController.animateCamera(CameraUpdate.newCameraPosition(
      //     CameraPosition(
      //         target: LatLng(position.latitude, position.longitude),
      //         zoom: 18,
      //         tilt: 0,
      //         bearing: 0)));

      // ref.read(currentLocationProvider.notifier).updateLocation(position);
      _currentPosition = position;

      _updateIconCurrentLocation(position);
    });
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    DefaultAssetBundle.of(context)
        .load('lib/assets/icons/current_location.png')
        .then((ByteData bytes) => currentLocationIcon =
            BitmapDescriptor.fromBytes(bytes.buffer.asUint8List()));

    DefaultAssetBundle.of(context).load('lib/assets/map/bike.png').then(
        (ByteData bytes) => driverIcon =
            BitmapDescriptor.fromBytes(bytes.buffer.asUint8List()));

    DefaultAssetBundle.of(context).load('lib/assets/map/original.png').then(
        (ByteData bytes) => departureLocationIcon =
            BitmapDescriptor.fromBytes(bytes.buffer.asUint8List()));
  }

  @override
  Widget build(BuildContext context) {
    final bool active = ref.watch(socketClientProvider);

    if (active) {
      final requestStatus = ref.watch(requestStatusProvider);
      final customerRequest = ref.watch(customerRequestProvider);

      if (customerRequest.hasValue()) {
        if (requestStatus == RequestStatus.accepted) {
          final LocationPostion customerLocation = LocationPostion(
              latitude: double.parse(customerRequest
                  .customer_infor.departure_information.latitude),
              longitude: double.parse(customerRequest
                  .customer_infor.departure_information.longitude));

          // final LocationPostion destinationLocation = LocationPostion(
          //     latitude: double.parse(
          //         customerRequest.customer_infor.arrival_information.latitude),
          //     longitude: double.parse(customerRequest
          //         .customer_infor.arrival_information.longitude));

          if (_info == null) {
            _info = customerRequest.direction;

            _mapController.animateCamera(CameraUpdate.newLatLngBounds(
                customerRequest.direction.bounds, 100.0));

            setState(() {
              _polyline = {
                Polyline(
                    polylineId: const PolylineId('customer_direction'),
                    color: Colors.orangeAccent,
                    width: 6,
                    points: customerRequest.direction.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList())
              };

              _markers.addAll({
                _createMarker(
                    'customer_location',
                    'Vị trí khách hàng',
                    LatLng(
                        customerLocation.latitude, customerLocation.longitude),
                    departureLocationIcon),

                // _createMarker(
                //     'destination_location',
                //     'Điểm đến  khách hàng',
                //     LatLng(destinationLocation.latitude,
                //         destinationLocation.longitude),
                //     BitmapDescriptor.defaultMarkerWithHue(
                //         BitmapDescriptor.hueOrange)),
              });
            });
          }
        }

        if (requestStatus == RequestStatus.comming &&
            running == true &&
            _info != null) {

            LocationPostion current_location = LocationPostion(
                latitude: customerRequest.direction.polylinePoints[process].latitude,
                longitude: customerRequest.direction.polylinePoints[process].longitude);

            final destinationPosition = LocationPostion(
                latitude: customerRequest.direction.polylinePoints[process + 1].latitude,
                longitude: customerRequest.direction.polylinePoints[process + 1]
                    .longitude); // Replace with your destination's coordinates

            final bearing = math.atan2(
                math.sin(math.pi * (destinationPosition.longitude - current_location.longitude) / 180.0),
                math.cos(math.pi * current_location.latitude / 180.0) *
                        math.tan(math.pi * destinationPosition.latitude / 180.0) - math.sin(math.pi * current_location.latitude / 180.0) *
                        math.cos(math.pi * (destinationPosition.longitude - current_location.longitude) / 180.0));

            double rotate = bearing * 180.0 / math.pi;

          _updateIconCurrentLocation(current_location, rotate: rotate);

          Timer.periodic(const Duration(seconds: 1), (timer) {
            if (_info == null ||
                requestStatus == RequestStatus.waiting ||
                process >= customerRequest.direction.polylinePoints.length - 1) {
              timer.cancel();
              return;
            }

            if (process < customerRequest.direction.polylinePoints.length - 1) {
              process++;

              LocationPostion current_location = LocationPostion(
                  latitude: customerRequest.direction.polylinePoints[process].latitude,
                  longitude: customerRequest.direction.polylinePoints[process].longitude);

              final destinationPosition = LocationPostion(
                  latitude: customerRequest.direction.polylinePoints[process - 1].latitude,
                  longitude: customerRequest.direction.polylinePoints[process - 1]
                      .longitude); // Replace with your destination's coordinates

              final bearing = math.atan2(
                  math.sin(math.pi * (destinationPosition.longitude - current_location.longitude) / 180.0),
                  math.cos(math.pi * current_location.latitude / 180.0) *
                          math.tan(math.pi * destinationPosition.latitude / 180.0) - math.sin(math.pi * current_location.latitude / 180.0) *
                          math.cos(math.pi * (destinationPosition.longitude - current_location.longitude) / 180.0));

              double rotate = bearing * 180.0 / math.pi;

              // _info!.polylinePoints.removeAt(0);

              _polyline = {
                Polyline(
                    polylineId: const PolylineId('customer_direction'),
                    color: Colors.orangeAccent,
                    width: 6,
                    points: _info!.polylinePoints
                        .map((e) => LatLng(e.latitude, e.longitude))
                        .toList().sublist(process, _info!.polylinePoints.length - 1))
              };

              _updateIconCurrentLocation(current_location, rotate: rotate);

              ref.read(socketClientProvider.notifier).publish(
                  'driver-moving',
                  jsonEncode(DriverSubmit(
                          user_id: customerRequest
                              .customer_infor.user_information.phonenumber,
                          driver: Driver(
                              "https://example.com/avatar0.jpg",
                              "Nguyễn Đức Minh",
                              "0778568685",
                              Vehicle(
                                  name: "Honda Wave RSX",
                                  brand: "Honda",
                                  type: "Xe máy",
                                  color: "Xanh đen",
                                  number: "68S164889"),
                              current_location,
                              rotate,
                              5.0))
                      .toJson()));
            }
          });
          running = false;
        }
      }

      if (requestStatus == RequestStatus.waiting) {
        setState(() {
          _info = null;
          _polyline.clear();
          _markers.clear();
          _markers.add(_createMarker(
              'my_location',
              'Vị trí của tôi',
              LatLng(_currentPosition.latitude, _currentPosition.longitude),
              currentLocationIcon));
          process = 0;
          running = true;
        });
      }
    } else {
      setState(() {
        _info = null;
        _polyline.clear();
        process = 0;
        running = true;
      });
    }

    return Stack(children: <Widget>[
      GoogleMap(
        myLocationButtonEnabled: false,
        myLocationEnabled: false,
        zoomControlsEnabled: true,
        zoomGesturesEnabled: true,
        onMapCreated: _onMapCreated,
        initialCameraPosition: _cameraPosition,
        markers: _markers,
        circles: _circles,
        polylines: _polyline,
      ),
      Align(
          alignment: Alignment.bottomRight,
          child: Container(
            padding: const EdgeInsets.only(bottom: 120, right: 3),
            child: CIconButton(
              elevation: 1,
              backgroundColor: Colors.white,
              foregroundColor: Colors.grey[500],
              padding: const EdgeInsets.all(12),
              icon: const Icon(FontAwesomeIcons.locationCrosshairs,
                  color: Color(0xFFFF772B)),
              onPressed: _moveToCurrent,
            ),
          )),
    ]);
  }
}
