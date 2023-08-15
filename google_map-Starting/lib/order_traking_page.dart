import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_mao/constants.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({Key? key}) : super(key: key);

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();

  static const LatLng sourceLocation = LatLng(19.165896, 72.961219);
  static const LatLng destination = LatLng(19.167529, 72.961063);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  void getCurrentLocation () async {
    Location location = Location();

    location.getLocation().then(
            (location) {
      currentLocation = location;
    },
    );

    GoogleMapController googleMapController = await _controller.future;

    location.onLocationChanged.listen((newLoc) {
      currentLocation = newLoc;

      googleMapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(zoom: 13.5, target: LatLng(newLoc.latitude!, newLoc.longitude!))));

      setState(() {});
    },
    );
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );

    if(result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
      ),
      );
      setState(() {});
    }
  }


  @override
  void initState() {
    getCurrentLocation();
    getPolyPoints();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "123 Mulund Depot -> CSMT Gate",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: currentLocation == null ? const Center(child: Text("Loading")): GoogleMap(
            initialCameraPosition: CameraPosition(
                target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),zoom: 13.5,
            ),
          polylines: {
              Polyline(polylineId: PolylineId("route"),
                points: polylineCoordinates,
                color: primaryColor,
                width: 6,
              ),
          },
          markers: {
              Marker(markerId: const MarkerId("currentLocation"),position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!)),Marker(markerId: MarkerId("source"), position: sourceLocation),Marker(markerId: MarkerId("destination"), position: destination),
          },
        onMapCreated: (mapController) {
              _controller.complete(mapController);
        },
        ),
    );
  }
}
