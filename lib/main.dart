import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:untitled1/login.dart';
import 'package:untitled1/registration.dart';
import 'map_screen.dart'; // Import de la page MapScreen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Liste des utilisateurs et chauffeurs',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UserListScreen(),
      routes: {
        '/map': (context) => MapScreen(), // Route pour la page de la carte
      },
    );
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List users = []; // Liste des utilisateurs
  List drivers = []; // Liste des chauffeurs disponibles

  @override
  void initState() {
    super.initState();
    fetchUsers();
    fetchDrivers();
  }

  // Récupérer les utilisateurs depuis l'API
  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('http://192.168.1.18:3000/api/users'));
    if (response.statusCode == 200) {
      setState(() {
        users = json.decode(response.body);
      });
    } else {
      print('Erreur lors du chargement des utilisateurs.');
    }
  }

  // Récupérer les chauffeurs disponibles depuis l'API
  Future<void> fetchDrivers() async {
    final response = await http.get(Uri.parse('http://192.168.1.18:3000/api/drivers'));
    if (response.statusCode == 200) {
      setState(() {
        drivers = json.decode(response.body);
      });
    } else {
      print('Erreur lors du chargement des chauffeurs.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des utilisateurs et chauffeurs'),
      ),
      body: Column(
        children: [
          // Bouton pour accéder à la carte
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()), // Navigation vers MapScreen
              );
            },
            child: Text('Voir la carte'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Login()), // Navigation vers MapScreen
              );
            },
            child: Text('Voir la connexion'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Registration()), // Navigation vers MapScreen
              );
            },
            child: Text('Voir inscription'),
          ),

          // Liste des utilisateurs
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Liste des utilisateurs',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(users[index]['nom'] ?? 'Nom inconnu'),
                        subtitle: Text(users[index]['email'] ?? 'Email inconnu'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Liste des chauffeurs disponibles
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Liste des chauffeurs disponibles',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: drivers.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(drivers[index]['nom'] ?? 'Nom inconnu'),
                        subtitle: Text(
                          'Position : ${drivers[index]['latitude']}, ${drivers[index]['longitude']}',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
