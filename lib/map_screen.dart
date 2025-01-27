import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _currentPosition; // Position actuelle
  List<Marker> _markers = []; // Liste des marqueurs

  @override
  void initState() {
    super.initState();
    _getRealLocation(); // Récupère la position réelle de l'utilisateur
  }

  // Fonction pour obtenir la position réelle de l'utilisateur
  Future<void> _getRealLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Le service de localisation est désactivé.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        throw Exception('La permission de localisation est refusée de façon permanente.');
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _addMarkerForCurrentLocation();
    });

    // Charger les chauffeurs proches après avoir la position
    _fetchNearbyDrivers(position.latitude, position.longitude);
  }

  // Fonction pour récupérer les chauffeurs proches depuis le backend
  Future<void> _fetchNearbyDrivers(double latitude, double longitude) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.18:3000/api/drivers/nearby'), // Remplacez l'IP par celle de votre serveur
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'latitude': latitude, 'longitude': longitude}),
      );

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          _markers.addAll(data.map((driver) {
            return Marker(
              width: 80.0,
              height: 80.0,
              point: LatLng(driver['latitude'], driver['longitude']),
              builder: (ctx) => Icon(
                Icons.local_taxi,
                color: Colors.blue,
                size: 40.0,
              ),
            );
          }).toList());
        });
      } else {
        print('Erreur lors de la récupération des chauffeurs.');
      }
    } catch (e) {
      print('Erreur : $e');
    }
  }

  // Ajouter un marqueur pour la position actuelle
  void _addMarkerForCurrentLocation() {
    if (_currentPosition != null) {
      _markers.add(
        Marker(
          width: 80.0,
          height: 80.0,
          point: _currentPosition!,
          builder: (ctx) => Icon(
            Icons.location_on_sharp,
            color: Colors.blue,
            size: 40.0,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carte interactive'),
      ),
      body: _currentPosition == null
          ? Center(child: CircularProgressIndicator()) // Loader pendant la récupération de la position
          : FlutterMap(
        options: MapOptions(
          center: _currentPosition, // Centre sur la position actuelle
          zoom: 13.0, // Niveau de zoom
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: _markers, // Marqueurs de la position actuelle et des chauffeurs
          ),
        ],
      ),
    );
  }
}
