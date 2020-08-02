import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'rounded_button.dart';
import 'constants.dart';
import 'login_screen.dart';
import 'add_bin.dart';

void main() => runApp(MaterialApp(
      home: MapView(),
    ));

class MapView extends StatefulWidget {
  static const String id = '/';

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MapView> {
  Completer<GoogleMapController> _controller = Completer();

  static const LatLng _center = const LatLng(32.1893343, 74.1879645);

  final Set<Marker> _markers = {};

  LatLng _lastMapPosition = _center;

  MapType _currentMapType = MapType.normal;
  final Map<String, Marker> _markerCurrent = {};

  Position position;
  Set<Marker> markers = Set();
  List<Marker> addMarkers = [
    Marker(
        markerId: MarkerId("TJ"),
        infoWindow: InfoWindow(
          title: "Taj Street",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: LatLng(32.1893343, 74.1879645)),
    Marker(
        markerId: MarkerId("Jinnah Road JDIHS"),
        infoWindow: InfoWindow(
          title: "Jinnad Road JDIHSS",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: LatLng(32.185156, 74.189999)),
    Marker(
        markerId: MarkerId("Jinnad Road Underpass"),
        infoWindow: InfoWindow(
          title: "Jinnad Road Underpass",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: LatLng(32.180071, 74.177382)),
    Marker(
        markerId: MarkerId("Alif Laam Meem"),
        infoWindow: InfoWindow(
          title: "Alif Laam Meem",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow),
        position: LatLng(32.189156, 74.187134)),
    Marker(
        markerId: MarkerId("Bhutta Street"),
        infoWindow: InfoWindow(
          title: "Bhutta Street",
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        position: LatLng(32.186301, 74.188156)),
  ];

  @override
  void initState() {
    markers.addAll(addMarkers); // add markers to the list
    super.initState();
    getCurrentLocation();
  }

  void getCurrentLocation() async {
    Position pos = await Geolocator().getCurrentPosition();
    setState(() {
      position = pos;

      // added markers on user current location
      markers.add(Marker(
        markerId: MarkerId("current Id"),
        infoWindow: InfoWindow(
          title: "Current",
        ),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));
    });
  }

  void _getLocation() async {
    final GoogleMapController controller = await _controller.future;
    var currentLocation = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);

    setState(() {
      _markers.clear();
      final marker = Marker(
        markerId: MarkerId("curr_loc"),
        position: LatLng(currentLocation.latitude, currentLocation.longitude),
        infoWindow: InfoWindow(title: 'Your Location'),
      );
      _markerCurrent["Current Location"] = marker;
    });

    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        bearing: 0,
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 17.0,
      ),
    ));
  }

  void _onMapTypeButtonPressed() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : MapType.normal;
    });
  }

  void _onAddMarkerButtonPressed() {
    setState(() {
      markers.add(Marker(
        // This marker id can be anything that uniquely identifies each marker.
        markerId: MarkerId(_lastMapPosition.toString()),
        position: _lastMapPosition,
        infoWindow: InfoWindow(
          title: 'Really cool place',
          snippet: '5 Star Rating',
        ),
        icon: BitmapDescriptor.defaultMarker,
      ));
    });
  }

  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller.complete(controller);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomPadding: false,
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text('Maps Sample App'),
          backgroundColor: Colors.green,
        ),
        body: Stack(
          children: <Widget>[
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              mapType: _currentMapType,
              markers: markers,
              onCameraMove: _onCameraMove,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: Column(
                  children: <Widget>[
                    FloatingActionButton(
                      onPressed: _onMapTypeButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.map, size: 36.0),
                    ),
                    SizedBox(height: 16.0),
                    FloatingActionButton(
                      onPressed: _onAddMarkerButtonPressed,
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.green,
                      child: const Icon(Icons.add_location, size: 36.0),
                    ),
                    SizedBox(height: 480.0),
                    FloatingActionButton(
                      onPressed: _getLocation,
                      tooltip: 'Get Location',
                      materialTapTargetSize: MaterialTapTargetSize.padded,
                      backgroundColor: Colors.green,
                      child: Icon(Icons.my_location, size: 36.0),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavDrawer extends StatelessWidget {
  final popupKey = GlobalKey<FormState>();
  final binIdController = TextEditingController();
  final binAddressController = TextEditingController();
  final remarksController = TextEditingController();
  bool _loading = false;

  Future<Position> getLocation() async {
    return await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.lowest);
  }

  Future<http.Response> sendData(binData) async {
    log('data:$binData');

    var url = 'http://192.168.10.34:3000/api/bins/new';
    Map<String, String> headers = {"Content-type": "application/json"};

    return await http.post(url, headers: headers, body: jsonEncode(binData));
  }

  @override
  Widget build(BuildContext context) {
    final _screenSize = MediaQuery.of(context).size;
    return Drawer(
      child: GestureDetector(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text(
                'Welcome DRB',
                style: TextStyle(color: Colors.white, fontSize: 25),
              ),
              decoration: BoxDecoration(
                  color: Colors.green,
                  image: DecorationImage(
                      fit: BoxFit.fill, image: AssetImage('images/cover.jpg'))),
            ),
            ListTile(
              leading: Icon(Icons.directions),
              title: Text('Track'),
              onTap: () => {},
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Add Bin'),
              onTap: () => {
              Navigator.of(context).popAndPushNamed('add_bin')
//                showDialog(
//                  context: context,
//                  builder: (BuildContext context) => AlertDialog(
//                    backgroundColor: Colors.white,
//                    title: Text(
//                      'Bin Installation',
//                      style: TextStyle(
//                        color: Colors.black,
//                      ),
//                    ),
//                    content: Flexible(
//                      child: Container(
//                        padding: EdgeInsets.all(10),
//                        height: 350.0,
//                        width: 400.0,
//                        child: Stack(
//                          overflow: Overflow.visible,
//                          children: <Widget>[
//                            Form(
//                              key: popupKey,
//                              child: SingleChildScrollView(
//                                child: Column(
//                                  crossAxisAlignment: CrossAxisAlignment.stretch,
//                                  children: <Widget>[
//                                    TextFormField(
//                                      controller: binIdController,
//                                      decoration: kTextFieldDecoration.copyWith(
//                                          hintText: 'Bin ID'),
//                                      keyboardType:
//                                          TextInputType.numberWithOptions(
//                                              decimal: false, signed: false),
//                                      validator: (value) {
//                                        if (value.isEmpty) {
//                                          return 'Please enter some number';
//                                        }
//                                        return null;
//                                      },
//                                    ),
//                                    SizedBox(
//                                      height: 8.0,
//                                    ),
//                                    TextFormField(
//                                      controller: binAddressController,
//                                      decoration: kTextFieldDecoration.copyWith(
//                                          hintText: 'Address'),
//                                      validator: (value) {
//                                        if (value.isEmpty) {
//                                          return 'Please enter some text';
//                                        }
//                                        return null;
//                                      },
//                                    ),
//                                    SizedBox(
//                                      height: 8.0,
//                                    ),
//                                    TextFormField(
//                                      controller: remarksController,
//                                      decoration: kTextFieldDecoration.copyWith(
//                                          hintText: 'Remarks'),
//                                      validator: (value) {
//                                        if (value.isEmpty) {
//                                          return 'Please enter some text';
//                                        }
//                                        return null;
//                                      },
//                                    ),
//                                    RoundedButton(
//                                      title: 'Add Bin',
//                                      color: Colors.lightBlueAccent,
//                                      onPress: () {
//                                        if (popupKey.currentState.validate()) {
//
//                                          binIdController.clear();
//                                          binAddressController.clear();
//                                          remarksController.clear();
//                                        } else {
//                                          Scaffold.of(context).showSnackBar(SnackBar(
//                                              content: Text(
//                                                  "Oops! Something went wrong.")));
//                                        }
//                                      },
//                                    ),
//                                  ],
//                                ),
//                              ),
//                            ),
//                          ],
//                        ),
//                      ),
//                    ),
//                  ),
//                )
              },
            ),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
              onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()))},
            ),
          ],
        ),
      ),
    );
  }
}
