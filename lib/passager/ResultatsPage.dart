import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultatsPage extends StatefulWidget {
  final List<Map<String, dynamic>> trajets;

  const ResultatsPage({super.key, required this.trajets});

  @override
  State<ResultatsPage> createState() => _ResultatsPageState();
}

class _ResultatsPageState extends State<ResultatsPage> {
  late List<Map<String, dynamic>> trajets;

  @override
  void initState() {
    super.initState();
    trajets = widget.trajets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      appBar: AppBar(title: Text('Résultats de recherche')),
      body: trajets.isEmpty
          ? Center(child: Text("Aucun trajet trouvé."))
          : ListView.builder(
              itemCount: trajets.length,
              itemBuilder: (context, index) {
                final trajet = trajets[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text("${trajet['depart']} --> ${trajet['arrivee']}"),
                    leading: Icon(Icons.directions_car),
                    subtitle: Text(
                        "Prix: ${trajet['prix']} DT\nDate: ${trajet['date'] is Timestamp ? trajet['date'].toDate().toString().split(' ')[0] : trajet['date'].toString()}"),
                  ),
                );
              },
            ),
    );
  }
}
