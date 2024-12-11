import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/image_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _selectedImage;
  final ImageService _imageService = ImageService();

  Future<void> _selectImage() async {
    final File? image = await _imageService.pickImage(ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });

      Navigator.pushNamed(
        context,
        '/recipeDetails',
        arguments: {'imageFile': image},
      );
    }
  }

  Future<void> _takePhoto() async {
    final File? image = await _imageService.pickImage(ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });

      Navigator.pushNamed(
        context,
        '/recipeDetails',
        arguments: {'imageFile': image},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DishAI', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search for a dish',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    // Handle search logic
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text('OR', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _selectImage();
                },
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload a Photo'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: () async {
                  await _takePhoto();
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take a Photo'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: Colors.lightBlue,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/favorites');
          }
        },
      ),
    );
  }
}
