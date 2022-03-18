import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:mobile_app/includes/constants.dart';
import 'package:mobile_app/includes/helpers.dart';
import 'package:mobile_app/models/place.dart';

class SearchPlaceScreen extends StatefulWidget {
  const SearchPlaceScreen({Key? key}) : super(key: key);

  @override
  State<SearchPlaceScreen> createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();

  final GooglePlace googlePlace = GooglePlace(Constants.GOOGLE_API_KEY);

  List<Place> _places = [];
  bool isLoading = false;

  @override
  void dispose() {
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  void onSearch() async {
    setState(() {
      _places = [];
      isLoading = true;
    });

    var result = await googlePlace.search.getTextSearch(
      _inputController.value.text,
      language: "fr",
    );

    if (result == null || result.results == null) return;

    for (var element in result.results!) {
      _places.add(
        Place(
          info: DetailsResult(
            name: element.name,
            placeId: element.placeId,
            geometry: element.geometry,
          ),
        ),
      );

      setState(() {
        isLoading = false;
      });
    }

    for (var i = 0; i < _places.length; i++) {
      var place = _places.elementAt(i);
      _places[i].directions.walking = await Helpers.getDirections(destination: place);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chercher un endroit")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: TextField(
              controller: _inputController,
              textInputAction: TextInputAction.search,
              onEditingComplete: () {
                onSearch();
                _inputFocusNode.unfocus();
              },
              // maxLines: 1,
              focusNode: _inputFocusNode,
              decoration: InputDecoration(
                hintText: "Taper l'endroit que vous voulez chercher ...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: onSearch,
                ),
              ),
            ),
          ),
          Flexible(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemBuilder: _placeEntryBuilder,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      color: Colors.white30,
                    ),
                    itemCount: _places.length,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _placeEntryBuilder(context, index) {
    var place = _places.elementAt(index);
    var distanceInKm = place.directions.walking?.first.overviewPath != null
        ? Helpers.calculateRouteDistance(place.directions.walking!.first.overviewPath!)
        : null;

    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          "/places/info",
          arguments: {"placeId": place.info.placeId},
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                place.info.name ?? "Unnamed",
                style: const TextStyle(height: 1.2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              distanceInKm != null ? Helpers.formatDistanceString(distanceInKm, short: true) : "-",
              semanticsLabel: distanceInKm != null
                  ? "Distance à ${place.info.name} est ${Helpers.formatDistanceString(distanceInKm)}"
                  : "La distance vers ${place.info.name} est en train d'être calculer",
            ),
          ],
        ),
      ),
    );
  }
}
