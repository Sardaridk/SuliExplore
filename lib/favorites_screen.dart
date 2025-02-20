import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Places'),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          _buildFavoritePlace('Azmar Mountain', '12 km', 'assets/azmar.jpg'),
          _buildFavoritePlace('ChaviLand', '45 km', 'assets/chaviland.jpg'),
        ],
      ),
    );
  }

  Widget _buildFavoritePlace(String name, String distance, String imagePath) {
    return ListTile(
      leading: Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.cover),
      title: Text(name),
      subtitle: Text('Distance: $distance'),
      trailing: const Icon(Icons.arrow_forward),
      onTap: () {
        // krdnaway shwenakan lagal tapkrdn
      },
    );
  }
}
