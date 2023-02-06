import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:helpers/helpers.dart';
import 'package:http/http.dart';
import 'package:image_editor/image_editor.dart';
import 'package:location/location.dart' as loc;
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'dart:ui' as ui;

import '../data/app_data.dart';
import '../utils/local_utils.dart';
import '../utils/utils.dart';

enum MapButtonAction {
  direction,
  bus,
}



class GoogleMapWidget extends StatefulWidget{
  GoogleMapWidget(this.showLocation, {Key? key,
    this.mapHeight = 400,
    this.showMyLocation = true,
    this.showDirection = false,
    this.showPosButton = true,
    this.showButtons = false,
    this.onButtonAction,
    this.onMarkerSelected,
    this.onCameraMoved,
  }) : super(key: key);

  bool showMyLocation;
  bool showPosButton;
  bool showDirection;
  bool showButtons;
  double mapHeight;
  List<JSON> showLocation;
  Function(MapButtonAction)? onButtonAction;
  Function(JSON)? onMarkerSelected;
  Function(CameraPosition, LatLngBounds)? onCameraMoved;

  // LatLng startLocation  = LatLng(27.6683619, 85.3101895);
  // LatLng endLocation    = LatLng(27.6875436, 85.2751138);

  @override
  GoogleMapState createState() => GoogleMapState();
}

class GoogleMapState extends State<GoogleMapWidget> {

  GoogleMapController? mapController; //contrller for Google map
  PolylinePoints polylinePoints = PolylinePoints();
  ByteData? markerBgImage;

  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  double markerSize = 150.0;
  double distance = 0.0;
  JSON? targetPosition;
  bool isMoveActive = false;

  refreshMap() {
    if (widget.showDirection) {
      if (AppData.currentLocation == null) {
        getGeoLocationPosition().then((startLoc) {
          setState(() {
            AppData.currentLocation = LatLng(startLoc.latitude, startLoc.longitude);
            showCurrentLocation();
            LOG('--> set startLocation : ${AppData.currentLocation!.latitude} / ${AppData.currentLocation!.longitude}');
          });
        })
        .onError((error, stackTrace) {
          LOG('--> refreshMap error : $error');
          // setState(() {
            initMarker();
          // });
        });
      } else {
        showCurrentLocation();
      }
    } else {
      initMarker();
    }
  }

  refreshMarker(List<JSON> list, [bool isBoundsFresh = true]) {
    widget.showLocation = list;
    initMarker(isBoundsFresh);
  }

  initMarker([bool isBoundsFresh = true]) {
    LOG('--> GoogleDirectionListWidget initMarker : ${widget.showLocation.length} / $isBoundsFresh');
    LatLng? targetLoc;
    markers = Set();
    isMoveActive = false;
    // add normal marker..
    for (var item in widget.showLocation) {
      var address = item['address'];
      if (address != null) {
        var loc = LatLng(DBL(address['lat']), DBL(address['lng']));
        targetLoc ??= loc;
        markers.add(Marker( //add distination location marker
          markerId: MarkerId(STR(item['id'])),
          position: loc, //position of marker
          icon: BitmapDescriptor.defaultMarker,
          // infoWindow: InfoWindow( //popup info
          //   title: STR(item['title']),
          //   // snippet: DESC(item['desc']),
          // ),
          onTap: () {
            onMarkerTaped(item);
          },
        ));
      }
      if (widget.showDirection && targetLoc != null) {
        getDirections(targetLoc);
      }
    }
    // replace image marker..
    for (var item in widget.showLocation) {
      LOG('--> add Image Marker : ${STR(item['pic'])}');
      getMarkerImage(STR(item['pic'])).then((icon) {
        if (icon != null) {
          LOG('--> getMarkerImage result : $icon / $markerSize');
          var address = item['address'];
          if (address != null) {
            setState(() {
              markers.add(Marker( //add distination location marker
                markerId: MarkerId(STR(item['id'])),
                position: LatLng(DBL(address['lat']), DBL(address['lng'])), //position of marker
                icon: icon ?? BitmapDescriptor.defaultMarker,
                // infoWindow: InfoWindow( //popup info
                //   title: STR(item['title']),
                //   // snippet: DESC(item['desc']),
                // ),
                onTap: () {
                  onMarkerTaped(item);
                },
                // onTap: onMarkerTaped(item),
              ));
            });
          }
        }
      });
    }
    if (isBoundsFresh && markers.isNotEmpty) {
      Future.delayed(Duration(milliseconds: 200), () {
        LOG('--> newLatLngBounds : ${markers.length}');
        mapController!.moveCamera(CameraUpdate.newLatLngBounds(
            MapUtils.boundsFromLatLngList(markers.map((loc) => loc.position).toList()), 100));
        Future.delayed(Duration(milliseconds: 200), () {
          isMoveActive = true;
        });
      });
    }
  }

  getMarkerImage(String imagePath) async {
    final fileName = imagePath.split('=').last;
    // LOG('--> getMarkerImage : $fileName');
    // final Uint8List? response = await getBytesFromAsset(imagePath, markerSize);
    // if (response != null) {
    //   writeLocalFile(fileName, String.fromCharCodes(response));
    //   var result = BitmapDescriptor.fromBytes(response);
    //   LOG('--> load server image : $imagePath');
    //   return result;
    // }
    final localData = await readLocalFile(fileName);
    if (localData.isNotEmpty) {
      LOG('--> load local image : $imagePath');
      var result = Uint8List.fromList(localData.codeUnits);
      return BitmapDescriptor.fromBytes(result);
    } else {
      final Uint8List? response = await getBytesFromAsset(imagePath, markerSize);
      if (response != null) {
        writeLocalFile(fileName, String.fromCharCodes(response));
        var result = BitmapDescriptor.fromBytes(response);
        LOG('--> load server image : $imagePath');
        return result;
      }
    }
    return null;
  }

  onMarkerTaped(JSON item) {
    if (widget.onMarkerSelected != null) widget.onMarkerSelected!(item);
  }

  Future<Uint8List?> getBytesFromAsset(String imagePath, double width) async {
    Uint8List? result;
    try {
      final option = ImageMergeOption(
        canvasSize: Size(width, width),
        format: OutputFormat.png(),
      );
      final imgSize = width * 0.75;
      final Response response = await get(Uri.parse(imagePath));
      final image1 = response.bodyBytes;
      option.addImage(
        MergeImageConfig(
          image: MemoryImageSource(image1),
          position: ImagePosition(
            Offset((width - imgSize) / 2, 7),
            Size.square(imgSize),
          ),
        ),
      );
      option.addImage(
        MergeImageConfig(
          image: MemoryImageSource(markerBgImage!.buffer.asUint8List()),
          position: ImagePosition(
            Offset(0, 0),
            Size.square(width),
          ),
        ),
      );
      result = await ImageMerger.mergeToMemory(option: option);
    } catch (e) {
      LOG('--> getBytesFromAsset error : $e');
    }
    return result;
  }

  showCurrentLocation() {
    markers.add(Marker( //add distination location marker
      markerId: MarkerId('myLoc'),
      position: LatLng(AppData.currentLocation!.latitude, AppData.currentLocation!.longitude),
      //position of marker
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      infoWindow: InfoWindow( //popup info
        title: 'Im Here',
        // snippet: DESC(item['desc']),
      ),
    ));
    initMarker();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(oldWidget) {
    // LOG('--> didUpdateWidget : ${markers.length}');
    // if (mapController != null) {
    //   refreshMap(false);
    // }
    super.didUpdateWidget(oldWidget);
  }

  getDirections(LatLng endLocation) async {
    LOG('--> GoogleMapWidget getDirections : ${AppData.currentLocation} -> $endLocation');
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_MAP_KEY,
      PointLatLng(AppData.currentLocation!.latitude, AppData.currentLocation!.longitude),
      PointLatLng(endLocation.latitude, endLocation.longitude),
      travelMode: TravelMode.transit,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        var loc = LatLng(point.latitude, point.longitude);
        polylineCoordinates.add(loc);
        // markers.add(Marker( //add distination location marker
        //   markerId: MarkerId(GlobalKey().toString()),
        //   position: loc,
        //   icon: BitmapDescriptor.defaultMarker,
        // ));
      }
    } else {
      LOG('--> getDirections errorMessage : ${result.errorMessage}');
    }

    //polulineCoordinates is the List of longitute and latidtude.
    double totalDistance = 0;
    for(var i = 0; i < polylineCoordinates.length-1; i++){
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i+1].latitude,
          polylineCoordinates[i+1].longitude);
    }
    LOG('--> totalDistance : $totalDistance');
    setState(() {
      distance = totalDistance;
      if (mapController != null) {
        Future.delayed(
            Duration(milliseconds: 200), () => mapController!.animateCamera(CameraUpdate.newLatLngBounds(
            MapUtils.boundsFromLatLngList(markers.map((loc) => loc.position).toList()), 50))
        );
      }
    });

    //add to the list of poly line coordinates
    addPolyLine(polylineCoordinates);

    // if (mapController != null && markers.isNotEmpty) {
    //   Future.delayed(const Duration(milliseconds: 1000), () {
    //     LOG('--> show marker window : ${markers.last.markerId} / ${markers.length}');
    //     mapController!.showMarkerInfoWindow(markers.last.markerId);
    //     // mapController!.animateCamera(CameraUpdate.newLatLng(markers.last.position));
    //   });
    // }
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    LOG('--> show GoogleMap : ${widget.showLocation.length}');
    final showPos = widget.showMyLocation && AppData.currentLocation != null ?
      AppData.currentLocation : widget.showLocation.isNotEmpty ?
      LATLNG(widget.showLocation.first['address']): LatLng(37.55594599, 126.972317);
    LOG('--> showPos : $showPos');

    return PointerInterceptor(
      child: SizedBox(
        height: widget.mapHeight,
        child: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                myLocationButtonEnabled: widget.showMyLocation,
                zoomGesturesEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                padding: EdgeInsets.all(20),
                initialCameraPosition: CameraPosition( //innital position in map
                  target: showPos, //initial position
                  zoom: 12.0, //initial zoom level
                ),
                markers: markers.toSet(),
                polylines: Set<Polyline>.of(polylines.values),
                onMapCreated: (controller) { //method called when map is created
                  mapController = controller;
                  // markerSize = MediaQuery.of(context).size.width * 0.4;
                  LOG('--> show marker window ready : ${markers.length}');
                  rootBundle.load('assets/ui/map_marker_00.png').then((value) {
                    markerBgImage = value;
                    refreshMap();
                  });
                },
                onCameraMove: (pos) {
                  if (mapController == null || !isMoveActive) return;
                  LOG('--> onCameraMove');
                  isMoveActive = false;
                  Future.delayed(Duration(milliseconds: 300), () {
                    isMoveActive = true;
                  });
                  mapController!.getVisibleRegion().then((region) {
                    if (widget.onCameraMoved !=null) widget.onCameraMoved!(pos, region);
                  });
                },
                // onTap: (pos) {
                //   LOG('--> pick GoogleMap : $pos');
                // },
                // onCameraMove: (pos) {
                //   LOG('--> onCameraMove : $pos');
                // },
                gestureRecognizers: Set()
                  ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))..add(
                        Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
              ),
              if (widget.showButtons)...[
                BottomRightAlign(
                  child: GestureDetector(
                    onTap: () {
                      if (widget.onButtonAction != null) widget.onButtonAction!(MapButtonAction.direction);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)]),
                      child: Center(
                        child: Icon(Icons.place, color: Colors.blueAccent, size: 30),
                      )
                    )
                  ),
                ),
                BottomRightAlign(
                  child: GestureDetector(
                      onTap: () {
                        if (widget.onButtonAction != null) widget.onButtonAction!(MapButtonAction.bus);
                      },
                      child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 3)]),
                          child: Center(
                            child: Icon(Icons.directions_bus_rounded, color: Colors.blueAccent, size: 30),
                          )
                      )
                  ),
                ),
              ],
              if (distance > 0)
                BottomCenterAlign(
                    child: Container(
                        child: Card(
                          color: Colors.white,
                          child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                              child: Text(distance.toStringAsFixed(2) + " km",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent))
                          ),
                        )
                    )
                )
            ]
        )
      )
    );
  }
}

class GoogleDirectionWidget extends StatefulWidget{
  GoogleDirectionWidget(this.endLocation, {Key? key, this.startLocation, this.mapHeight = 120}) : super(key: key);

  double mapHeight;
  LatLng? startLocation;
  LatLng endLocation;

  // LatLng startLocation  = LatLng(27.6683619, 85.3101895);
  // LatLng endLocation    = LatLng(27.6875436, 85.2751138);

  @override
  _GoogleDirectionState createState() => _GoogleDirectionState();
}

class _GoogleDirectionState extends State<GoogleDirectionWidget> {

  GoogleMapController? mapController; //contrller for Google map
  PolylinePoints polylinePoints = PolylinePoints();

  Set<Marker> markers = Set(); //markers for google map
  Map<PolylineId, Polyline> polylines = {}; //polylines to show direction

  double distance = 0.0;

  initMarker() {
    LOG('--> GoogleMapWidget initMarker : ${widget.startLocation}');
    markers.add(Marker( //add distination location marker
      markerId: MarkerId(widget.endLocation.toString()),
      position: widget.endLocation, //position of marker
      infoWindow: InfoWindow( //popup info
        title: '도착지점',
        snippet: 'Destination Marker',
      ),
      icon: BitmapDescriptor.defaultMarker, //Icon for Marker
    ));

    if (widget.startLocation != null) {
      markers.add(Marker( //add start location marker
        markerId: MarkerId(widget.startLocation.toString()),
        position: widget.startLocation!, //position of marker
        infoWindow: InfoWindow( //popup info
          title: '출발지점',
          snippet: 'Start Marker',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));
      getDirections(); //fetch direction polylines from Google API
    }
  }

  @override
  void initState() {
    LOG('--> GoogleMapWidget init');
    if (widget.startLocation == null) {
      getGeoLocationPosition().then((startLoc) {
        LOG('--> startLoc : $startLoc');
        setState(() {
          widget.startLocation = LatLng(startLoc.latitude, startLoc.longitude);
          LOG('--> set startLocation : ${widget.startLocation!.latitude} / ${widget.startLocation!.longitude}');
          initMarker();
        });
      })
      .onError((error, stackTrace) {
        LOG('--> startLocation error : $error');
        setState(() {
          initMarker();
        });
      });
    }
    // initMarker();
    super.initState();
  }

  getDirections() async {
    LOG('--> GoogleMapWidget getDirections : ${widget.startLocation} -> ${widget.endLocation}');
    List<LatLng> polylineCoordinates = [];
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_MAP_KEY,
      PointLatLng(widget.startLocation!.latitude, widget.startLocation!.longitude),
      PointLatLng(widget.endLocation.latitude, widget.endLocation.longitude),
      travelMode: TravelMode.transit,
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      LOG('--> getDirections errorMessage : ${result.errorMessage}');
    }

    //polulineCoordinates is the List of longitute and latidtude.
    double totalDistance = 0;
    for(var i = 0; i < polylineCoordinates.length-1; i++){
      totalDistance += calculateDistance(
          polylineCoordinates[i].latitude,
          polylineCoordinates[i].longitude,
          polylineCoordinates[i+1].latitude,
          polylineCoordinates[i+1].longitude);
    }
    LOG('--> totalDistance : $totalDistance');
    setState(() {
      distance = totalDistance;
      if (mapController != null) {
        Future.delayed(
            Duration(milliseconds: 200), () => mapController!.animateCamera(CameraUpdate.newLatLngBounds(
            MapUtils.boundsFromLatLngList(markers.map((loc) => loc.position).toList()), 40))
        );
      }
    });

    //add to the list of poly line coordinates
    addPolyLine(polylineCoordinates);
  }

  addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      polylineId: id,
      color: Colors.deepPurpleAccent,
      points: polylineCoordinates,
      width: 4,
    );
    polylines[id] = polyline;
  }

  double calculateDistance(lat1, lon1, lat2, lon2){
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.mapHeight,
      child: Stack(
        children: [
          GoogleMap(
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              scrollGesturesEnabled: true,
              myLocationButtonEnabled: true,
              initialCameraPosition: CameraPosition( //innital position in map
                target: widget.endLocation, //initial position
                zoom: 14.0, //initial zoom level
              ),
              markers: markers,
              polylines: Set<Polyline>.of(polylines.values),
              mapType: MapType.normal,
              onMapCreated: (controller) { //method called when map is created
                mapController = controller;
              },
              gestureRecognizers: Set()
                ..add(Factory<PanGestureRecognizer>(() => PanGestureRecognizer()))
                ..add(Factory<ScaleGestureRecognizer>(() => ScaleGestureRecognizer()))
          ),
          if (distance > 0)
            BottomCenterAlign(
              child: Container(
                child: Card(
                  color: Colors.white,
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      child: Text(distance.toStringAsFixed(2) + " km",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueAccent))
                  ),
                )
              )
            ),
        ]
      )
    );
  }
}

class MapUtils {
  static LatLngBounds boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(northeast: LatLng(x1!, y1!), southwest: LatLng(x0!, y0!));
  }
}

Future<Position> getGeoLocationPosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the
    // App to enable the location services.
    // await Geolocator.openLocationSettings();
    if (await showLocationServiceDialog()) {
      return await getGeoLocationPosition();
    } else {
      return Future.error('--> Location services are disabled.');
    }
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('--> Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately.
    return Future.error(
        '--> Location permissions are permanently denied, we cannot request permissions.');
  }
  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
}

Future<bool> showLocationServiceDialog() async {
  final location = loc.Location();
  bool isOn = await location.serviceEnabled();
  if (!isOn) { //if defvice is off
    bool isTurnedOn = await location.requestService();
    if (isTurnedOn) {
      LOG("--> GPS device is turned ON");
      return true;
    }else{
      LOG("--> GPS Device is still OFF");
    }
  }
  return false;
}

