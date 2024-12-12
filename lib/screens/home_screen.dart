import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ai_service.dart';

class HomeScreen extends StatefulWidget {
  final void Function(List<Map<String, dynamic>>) onNavigateToRecipeDetails;

  const HomeScreen({super.key, required this.onNavigateToRecipeDetails});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AIService _aiService = AIService();
  final ImagePicker _imagePicker = ImagePicker();
  bool _isLoading = false;

  Future<void> _searchDish() async {
    if (_searchController.text.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });

      final results = await _aiService.searchByName(_searchController.text);
      _searchController.clear();
      widget.onNavigateToRecipeDetails(results);

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadPhoto() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      setState(() {
        _isLoading = true;
      });

      final results = await _aiService.searchByImage(image);
      widget.onNavigateToRecipeDetails(results);

      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null && mounted) {
      setState(() {
        _isLoading = true;
      });

      final results = await _aiService.searchByImage(image);
      widget.onNavigateToRecipeDetails(results);

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DishAI', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a dish',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchDish,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'OR',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                onPressed: _uploadPhoto,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload a Photo'),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton.icon(
                onPressed: _takePhoto,
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
