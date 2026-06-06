import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});
 @override
  State<TripsScreen> createState() => _TripsScreenState();
}
class _TripsScreenState extends State<TripsScreen> {
List trips = [];
Future<void> fetchTrips() async {
 var url = Uri.parse(
      "http://localhost:5000/get_trips",
    );
var response = await http.get(url);
var data = jsonDecode(response.body);
setState(() {
      trips = data;
    });
  }
@override
  void initState() {
    super.initState();
    fetchTrips();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text("Saved Trips"),
      ),

      body: ListView.builder(

        itemCount: trips.length,

        itemBuilder: (context, index) {

          var trip = trips[index];

          return Card(

            margin: EdgeInsets.all(10),

            elevation: 5,

            child: ListTile(

              leading: Icon(Icons.flight),

              title: Text(trip["city"]),

              subtitle: Text(
                trip["transport"],
              ),

            ),
          );
        },
      ),
    );
  }
}
