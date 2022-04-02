import 'package:flutter/material.dart';
import 'package:mobile_app/includes/navigation.dart';
import 'package:mobile_app/models/explore_location.dart';
import 'package:mobile_app/services/navigatables.dart';
import 'package:mobile_app/widgets/navigatable_element.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({Key? key}) : super(key: key);

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final List<ExploreLocationType> _locationsTypes = [
    ExploreLocationType(label: ""),
    ExploreLocationType(label: "All"),
    ExploreLocationType(label: "Cafes and Restaurants", types: ["cafe", "restaurant"]),
    ExploreLocationType(label: "Mosques", types: ["mosque"]),
    ExploreLocationType(
      label: "Shops and services",
      types: [
        "bakery",
        "store",
        "supermarket",
        "hair_care",
        "hardware_store",
        "home_goods_store",
        "travel_agency",
        "gas_station",
        "shoe_store"
      ],
    ),
    ExploreLocationType(
      label: "Arts and hobbies",
      types: ["museum", "park", "night_club", "movie_theater"],
    ),
    ExploreLocationType(label: "Police", types: ["police"]),
    ExploreLocationType(
      label: "Doctors, Hospitals and Pharmacies",
      types: ["hospital", "doctor", "pharmacy", "dentist"],
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore"),
      ),
      body: ListView.separated(
        itemBuilder: (context, index) {
          var locationType = _locationsTypes.elementAt(index);
          return SizedBox(
            height: index == 0 ? 0 : 56,
            child: NavigatableElement(
              child: OutlinedButton(
                child: Text(locationType.label),
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    "/places/findByType",
                    arguments: {
                      "type": locationType,
                    },
                  );
                },
              ),
              index: index,
            ),
          );
        },
        separatorBuilder: (context, index) => SizedBox(height: index == 0 ? 0 : 16),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        itemCount: _locationsTypes.length,
      ),
    );
  }
}
