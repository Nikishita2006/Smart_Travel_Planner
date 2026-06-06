import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Travel(),
    );
  }
}

class Travel extends StatefulWidget {
  const Travel({super.key});

  @override
  State<Travel> createState() => _Planner();
}

class _Planner extends State<Travel> {

  // CONTROLLERS
  TextEditingController myController =
      TextEditingController();

  TextEditingController daysController =
      TextEditingController();

  TextEditingController aiController =
      TextEditingController();

  // VARIABLES
  String? mode;

  String weather = "";

  String temperature = "";

  String budgetType = "Economy";

  int estimatedBudget = 0;

  String aiReply = "";

  bool showChat = false;

  bool wallet = false;

  bool charger = false;
  bool identity_card = false;
  bool medications = false;
  bool toiletries = false;
  bool cash = false;
  

  bool needHotel = false;
  

  // LISTS
  List<String> packingSuggestions = [];

  List<String> suggestedPlaces = [];

  // TOURIST DATA
  Map<String, List<String>> touristPlaces = {

    "Hyderabad":[
      "Charminar",
      "Golconda Fort",
      "Ramoji Film City",
    ],

    "Delhi":[
      "India Gate",
      "Qutub Minar",
    ],

    "Mumbai":[
      "Gateway Of India",
      "Marine Drive",
    ],

    "Goa":[
      "Baga Beach",
      "Dudhsagar Falls",
    ],

  };

  // SEND TRIP DATA
  Future<void> sendTripData() async {

    var url = Uri.parse(
      "http://127.0.0.1:5000/add_trip",
    );

    await http.post(

      url,

      headers: {
        "Content-Type":"application/json",
      },

      body: jsonEncode({

        "city": myController.text,

        "transport": mode,
         "wallet":wallet,
        "charger": charger,
        "identity_card":identity_card,
        "medications":medications,
        "toiletries":toiletries,
        "cash": cash,
      }),

    );
  }

  // FETCH WEATHER
  Future<void> fetchWeather() async {

    try {

      var url = Uri.parse(
        "http://127.0.0.1:5000/weather/${myController.text}",
      );

      var response = await http.get(url);

      var data = jsonDecode(response.body);

      if(response.statusCode == 200){

        setState(() {

          weather = data['description'];

          temperature =
              data['temperature'].toString();

        });

      }

      else {

        setState(() {

          weather = "City not found";

          temperature = "N/A";

        });

      }

    }

    catch(e){

      print(e);

    }

  }

  // CALCULATE BUDGET
  void calculateBudget() {

    int days =
        int.tryParse(daysController.text) ?? 1;

    int total = 0;

    // TRANSPORT
    if(mode == "Flight"){

      total += 5000;

    }

    else if(mode == "Bus"){

      total += 2000;

    }

    else if(mode == "Car"){

      total += 3000;

    }

    // HOTEL
    if(needHotel){

      total += days * 2000;

    }

    // BUDGET TYPE
    if(budgetType == "Economy"){

      total += days * 1000;

    }

    else if(budgetType == "Standard"){

      total += days * 2000;

    }

    else if(budgetType == "Luxury"){

      total += days * 5000;

    }

    setState(() {

      estimatedBudget = total;

    });

  }

  // PACKING SUGGESTIONS
  void generatePackingSuggestions() {

    packingSuggestions.clear();

    if(temperature != "N/A"){

      double temp =
          double.parse(temperature);

      if(temp > 30){

        packingSuggestions.add("Cap");

        packingSuggestions.add("Sunglasses");
        packingSuggestions.add("Loose Fitting shirts");
        packingSuggestions.add("Cotton Pants");
        packingSuggestions.add("Umbrella");

      }

      if(temp < 10){

        packingSuggestions.add("Sweater");

        packingSuggestions.add("Thermal Wear");
        packingSuggestions.add("Woolen Cap");
        packingSuggestions.add("Moisturizer");
        packingSuggestions.add("Blankets");


      }

      if(temp >= 15 && temp <= 25){

        packingSuggestions.add(
          "Regular T-Shirts"
    
        );
        packingSuggestions.add(
          "Hoodies"
    
        );
        packingSuggestions.add(
          "Shorts/Trousers"
    
        );
        packingSuggestions.add(
          "Cap"
    
        );
        packingSuggestions.add(
          "Sunglasses"
    
        );

      }

    }

    if(weather.contains("rain")){

      packingSuggestions.add("Umbrella");
      packingSuggestions.add("Raincoat");
      packingSuggestions.add("Waterproof Pouch");
      packingSuggestions.add("Hand Towel");

      
      


    }

    packingSuggestions.add("Water Bottle");

    setState(() {});

  }

  // TOURIST SUGGESTIONS
  void generatedTouristSuggestions(){

    suggestedPlaces.clear();

    String city =
        myController.text.trim();
    city = 
            city[0].toUpperCase()+city.substring(1).toLowerCase();

    if(touristPlaces.containsKey(city)){

      suggestedPlaces =
          touristPlaces[city]!;

    }

    else {

      suggestedPlaces.add(
        "No Suggestions Available"
      );

    }

    setState(() {});

  }

  // AI CHATBOT
  Future<void> askAI() async {
    try{
    var url = Uri.parse(
      "http://127.0.0.1:5000/ask_ai",
    );

    var response = await http.post(

      url,

      headers: {
        "Content-Type":"application/json",
      },

      body: jsonEncode({

        "question": aiController.text,

      }),

    );
    print("STATUS:${response.statusCode}");
    print("BODY:${response.body}");

    var data = jsonDecode(response.body);

    setState(() {

      aiReply = data['reply']?? "AI has no answer";

    });

  }
  catch(e){
    print(e);
    setState((){
      aiReply = "AI Error: $e";
    });
  }
  }

  @override
Widget build(BuildContext context) {

  return Scaffold(

    backgroundColor: const Color(0xffFFE5D9),

    appBar: AppBar(

      elevation: 0,

      centerTitle: true,

      backgroundColor: const Color(0xffE5989B),

      title: const Text(

        "AI Travel Planner",

        style: TextStyle(

          fontWeight: FontWeight.bold,

          color: Colors.white,

        ),

      ),

    ),

    floatingActionButton: FloatingActionButton(

      backgroundColor: const Color(0xffB56576),

      onPressed: () {

        setState(() {

          showChat = !showChat;

        });

      },

      child: const Icon(

        Icons.smart_toy,

        color: Colors.white,

      ),

    ),

    body: SingleChildScrollView(

      padding: const EdgeInsets.all(18),

      child: Column(

        children: [




          // ================= INPUT CARD =================

          Container(

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(25),

              boxShadow: [

                BoxShadow(

                  color: Colors.black.withOpacity(0.08),

                  blurRadius: 10,

                ),

              ],

            ),

            child: Column(

              children: [

                TextField(

                  controller: myController,

                  decoration: InputDecoration(

                    labelText: "Enter City",

                    filled: true,

                    fillColor: Colors.grey[100],

                    border: OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(18),

                    ),

                  ),

                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(

                  value: budgetType,

                  decoration: InputDecoration(

                    filled: true,

                    fillColor: Colors.grey[100],

                    border: OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(18),

                    ),

                  ),

                  items: [

                    "Economy",

                    "Standard",

                    "Luxury",

                  ].map((type){

                    return DropdownMenuItem(

                      value: type,

                      child: Text(type),

                    );

                  }).toList(),

                  onChanged: (value){

                    setState(() {

                      budgetType = value!;

                    });

                  },

                ),

                const SizedBox(height: 20),

                TextField(

                  controller: daysController,

                  keyboardType: TextInputType.number,

                  decoration: InputDecoration(

                    labelText: "Number Of Days",

                    filled: true,

                    fillColor: Colors.grey[100],

                    border: OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(18),

                    ),

                  ),

                ),

              ],

            ),

          ),

          const SizedBox(height: 20),




          // ================= TRANSPORT CARD =================

          Container(

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(25),

            ),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                const Text(

                  "Transport",

                  style: TextStyle(

                    fontSize: 24,

                    fontWeight: FontWeight.bold,

                    color: Color(0xffB56576),

                  ),

                ),

                RadioListTile<String>(

                  activeColor:
                  const Color(0xffB56576),

                  title: const Text("Flight"),

                  value: "Flight",

                  groupValue: mode,

                  onChanged: (value){

                    setState(() {

                      mode = value;

                    });

                  },

                ),

                RadioListTile<String>(

                  activeColor:
                  const Color(0xffB56576),

                  title: const Text("Bus"),

                  value: "Bus",

                  groupValue: mode,

                  onChanged: (value){

                    setState(() {

                      mode = value;

                    });

                  },

                ),

                RadioListTile<String>(

                  activeColor:
                  const Color(0xffB56576),

                  title: const Text("Car"),

                  value: "Car",

                  groupValue: mode,

                  onChanged: (value){

                    setState(() {

                      mode = value;

                    });

                  },

                ),

              ],

            ),

          ),

          const SizedBox(height: 20),




          // ================= ESSENTIALS CARD =================

          Container(

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(25),

            ),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                const Text(

                  "Essentials",

                  style: TextStyle(

                    fontSize: 24,

                    fontWeight: FontWeight.bold,

                    color: Color(0xffB56576),

                  ),

                ),

                CheckboxListTile(

                  activeColor:
                  const Color(0xffB56576),

                  title: const Text("Wallet"),

                  value: wallet,

                  onChanged: (value){

                    setState(() {

                        wallet= value!;

                    });

                  },

                ),

                CheckboxListTile(

                  activeColor:
                  const Color(0xffB56576),

                  title: const Text("Charger"),

                  value: charger,

                  onChanged: (value){

                    setState(() {

                      charger = value!;

                    });

                  },

                ),
                CheckboxListTile(

                  activeColor:
                  const Color(0xffB56576),

                  title: const Text("ID"),

                  value: identity_card,

                  onChanged: (value){

                    setState(() {

                        identity_card = value!;

                    });

                  },

                ),
                CheckboxListTile(

                  activeColor:
                  const Color(0xffB56576),

                  title: const Text("Medications"),

                  value: medications,

                  onChanged: (value){

                    setState(() {

                      medications = value!;

                    });

                  },

                ),
                CheckboxListTile(

                  activeColor:
                  const Color(0xffB56576),

                  title: const Text("Toiletries"),

                  value: toiletries,

                  onChanged: (value){

                    setState(() {

                      toiletries = value!;

                    });

                  },

                ),
                CheckboxListTile(

                  activeColor:
                  const Color(0xffB56576),

                  title: const Text("Cash/Card"),

                  value: cash,

                  onChanged: (value){

                    setState(() {

                      cash = value!;

                    });

                  },

                ),

                SwitchListTile(

                  activeColor:
                  const Color(0xffB56576),

                  title: const Text(

                    "Need Hotel Booking?",

                  ),

                  value: needHotel,

                  onChanged: (value){

                    setState(() {

                      needHotel = value;

                    });

                  },

                ),

              ],

            ),

          ),

          const SizedBox(height: 25),




          // ================= BUTTON =================

          SizedBox(

            width: double.infinity,

            height: 60,

            child: ElevatedButton(

              style:
              ElevatedButton.styleFrom(

                backgroundColor:
                const Color(0xffE5989B),

                shape:
                RoundedRectangleBorder(

                  borderRadius:
                  BorderRadius.circular(20),

                ),

              ),

              onPressed: () async {
                try{
                await sendTripData();

                await fetchWeather();

                calculateBudget();

                generatePackingSuggestions();

                generatedTouristSuggestions();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Trip Plan Generated"),),
                );       
              }
              catch(e){
                print(e);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar( content:Text("Error: $e"),),);
              }},
              child: const Text(

                "Generate Trip Plan",

                style: TextStyle(

                  fontSize: 22,

                  fontWeight: FontWeight.bold,

                  color: Colors.white,

                ),

              ),

            ),

          ),

          const SizedBox(height: 25),




          // ================= WEATHER CARD =================

          infoCard(

            title: "Weather",

            child: Column(

              children: [

                Text(

                  "Temperature: $temperature °C",

                  style: const TextStyle(

                    fontSize: 20,

                  ),

                ),

                const SizedBox(height: 10),

                Text(

                  "Condition: $weather",

                  style: const TextStyle(

                    fontSize: 20,

                  ),

                ),

              ],

            ),

          ),

          const SizedBox(height: 20),




          // ================= BUDGET CARD =================

          infoCard(

            title: "Estimated Budget",

            child: Text(

              "₹$estimatedBudget",

              style: const TextStyle(

                fontSize: 34,

                fontWeight: FontWeight.bold,

                color: Color(0xffB56576),

              ),

            ),

          ),

          const SizedBox(height: 20),




          // ================= PACKING CARD =================

          infoCard(

            title: "Packing Suggestions",

            child: Column(

              children:
              packingSuggestions.map((item){

                return Card(

                  elevation: 0,

                  color: Colors.grey[100],

                  child: ListTile(

                    leading:
                    const Icon(Icons.check),

                    title: Text(item),

                  ),

                );

              }).toList(),

            ),

          ),

          const SizedBox(height: 20),




          // ================= TOURIST PLACES =================

          infoCard(

            title: "Tourist Places",

            child: Column(

              children:
              suggestedPlaces.map((place){

                return Card(

                  shape:
                  RoundedRectangleBorder(

                    borderRadius:
                    BorderRadius.circular(18),

                  ),

                  child: ListTile(

                    leading: CircleAvatar(

                      backgroundColor:
                      const Color(0xffE5989B),

                      child: const Icon(

                        Icons.place,

                        color: Colors.white,

                      ),

                    ),

                    title: Text(place),

                  ),

                );

              }).toList(),

            ),

          ),

          const SizedBox(height: 20),




          // ================= AI CHAT =================

          if(showChat)

          Container(

            padding: const EdgeInsets.all(20),

            decoration: BoxDecoration(

              color: Colors.white,

              borderRadius: BorderRadius.circular(25),

            ),

            child: Column(

              children: [

                const Text(

                  "AI Travel Assistant",

                  style: TextStyle(

                    fontSize: 24,

                    fontWeight: FontWeight.bold,

                    color: Color(0xffB56576),

                  ),

                ),

                const SizedBox(height: 20),

                TextField(

                  controller: aiController,

                  decoration: InputDecoration(

                    hintText:
                    "Ask travel questions...",

                    filled: true,

                    fillColor: Colors.grey[100],

                    border: OutlineInputBorder(

                      borderRadius:
                      BorderRadius.circular(18),

                    ),

                  ),

                ),

                const SizedBox(height: 20),

                SizedBox(

                  width: double.infinity,

                  height: 55,

                  child: ElevatedButton(

                    style:
                    ElevatedButton.styleFrom(

                      backgroundColor:
                      const Color(0xffE5989B),

                    ),

                    onPressed: askAI,

                    child: const Text(

                      "Ask AI",

                      style: TextStyle(

                        fontSize: 20,

                        color: Colors.white,

                      ),

                    ),

                  ),

                ),

                const SizedBox(height: 20),

                Container(

                  width: double.infinity,

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(

                    color: Colors.grey[100],

                    borderRadius:
                    BorderRadius.circular(18),

                  ),

                  child: Text(

                    aiReply,

                    style: const TextStyle(

                      fontSize: 18,

                    ),

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    ),

  );

}





Widget infoCard({

  required String title,

  required Widget child,

}) {

  return Container(

    width: double.infinity,

    padding: const EdgeInsets.all(20),

    decoration: BoxDecoration(

      color: Colors.white,

      borderRadius: BorderRadius.circular(25),

      boxShadow: [

        BoxShadow(

          color: Colors.black.withOpacity(0.08),

          blurRadius: 10,

        ),

      ],

    ),

    child: Column(

      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [

        Text(

          title,

          style: const TextStyle(

            fontSize: 24,

            fontWeight: FontWeight.bold,

            color: Color(0xffB56576),

          ),

        ),

        const SizedBox(height: 15),

        child,

      ],

    ),

  );

}
}


