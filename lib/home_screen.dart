import 'package:flutter/material.dart';
import 'place_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final List<Map<String, dynamic>> _places = [
    {
      'name': 'Amna Suraka',
      'image': 'assets/amna_suraka.jpg',
      'description': 'A museum in Sulaymaniyah.',
      'location': 'Sulaymaniyah, Iraq',
      'price': '\$50/night',
      'latitude': 35.5543,
      'longitude': 45.4360,
    },
    {
      'name': 'Azmar Mountain',
      'image': 'assets/azmar.jpg',
      'description': 'A beautiful mountain range.',
      'location': 'Sulaymaniyah, Iraq',
      'price': 'Free',
      'latitude': 35.5332,
      'longitude': 45.4485,
    },
    {
      'name': 'Millennium Park',
      'image': 'assets/millennium.jpg',
      'description': 'A large city park.',
      'location': 'Sulaymaniyah, Iraq',
      'price': '\$10/night',
      'latitude': 35.57193745484978,
      'longitude': 45.40664268274365,
    },
    {
      'name': 'Chavi Land',
      'image': 'assets/chaviland.jpg',
      'description': 'An amusement park.',
      'location': 'Sulaymaniyah, Iraq',
      'price': '\$30/night',
      'latitude': 35.5817149753599,
      'longitude': 45.46737539046247,
    },
    {
      'name': 'Sulaymaniyah\nMuseum',
      'image': 'assets/museum.jpg',
      'description': 'A museum of Kurdish history.',
      'location': 'Sulaymaniyah, Iraq',
      'price': '\$20/night'
    }
  ];

  String _searchText = '';
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlaces = _places
        .where((place) =>
            place['name']!.toLowerCase().contains(_searchText.toLowerCase()))
        .toList();

    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'E.g: ChaviLand',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // Horizontal cards with images and names
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredPlaces.length,
              itemBuilder: (context, index) {
                final place = filteredPlaces[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PlaceDetailsScreen(
                                name: place['name']!,
                                image: place['image']!,
                                description: place['description']!,
                                latitude: place['latitude'],
                                longitude: place['longitude'],
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Image.asset(
                            place['image']!,
                            width: 130,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        place['name']!,
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // Tabs: Top Hotels, Top Tourist Places, Recent Activities
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.teal,
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.grey,
            tabs: const [
              Tab(text: "Top Hotels"),
              Tab(text: "Top Tourist Places"),
              Tab(text: "Recent Activities"),
            ],
          ),
          // Tab Bar View
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlaceList(_places), // Top Hotels
                _buildPlaceList(_places), // Top Tourist Places
                _buildPlaceList(_places), // Recent Activities
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceList(List<Map<String, dynamic>> places) {
    return ListView.builder(
      itemCount: places.length,
      itemBuilder: (context, index) {
        final place = places[index];
        return ListTile(
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              place['image']!,
              fit: BoxFit.cover,
              width: 60,
              height: 60,
            ),
          ),
          title: Text(
            place['name']!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(place['location']!),
          trailing: Text(
            place['price']!,
            style: const TextStyle(
              color: Colors.teal,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlaceDetailsScreen(
                  name: place['name']!,
                  image: place['image']!,
                  description: place['description']!,
                  latitude: place['latitude'],
                  longitude: place['longitude'],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
