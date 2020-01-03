import 'package:flutter/material.dart';
import 'dart:async';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

Future<Map<PermissionGroup, PermissionStatus>> _getLocationPermission() async {
  return await PermissionHandler()
      .requestPermissions([PermissionGroup.location]);
}

Future<LocationData> _getCurrentLocation() async {
  return await Location().onLocationChanged().first;
}

class GetLocation extends StatefulWidget {
  @override
  _GetLocation createState() => _GetLocation();
}

class _GetLocation extends State<GetLocation> {
  String _longitude = "Longitude: NULL ", _latitude = "Latitude: NULL";
  String _status = "Request Location";

  Future<LocationData> getLocation() async {
    var permissionStatus = await _getLocationPermission();
    if (permissionStatus.containsValue(PermissionStatus.granted)) {
      _status = "Permission Granted";
    } else {
      _status = "Permission Denied, grant permission to Continue";
    }
    setState(() {});
    var location = await _getCurrentLocation();
    return location;
  }

  void tester() async {
    setState(() {
      _status = "Requesting Location...";
    });
    getLocation().then((_location) {
      setState(() {
        _longitude = "Longitude : " + _location.longitude.toString();
        _latitude = "Latitude : " + _location.latitude.toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
       
        title: Text('Device location'),
      ),
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "$_longitude",
            
          ),
          Text(
            "$_latitude"
          ),
          RaisedButton(
            child: Text(
              "$_status",
            ),
            onPressed: tester,
          ),
        ],
      )),
    );
  }
}
