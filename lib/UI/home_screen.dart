import 'dart:io';
import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../services/gemini_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService firebaseService = FirebaseService();
  final GeminiService geminiService = GeminiService();

  String _recommendation = '';
  bool _isLoading = false;
  bool _showImages = false;
  List<File> _parkingImages = [];

  Future<void> _analyzeParkingImages() async {
    setState(() {
      _isLoading = true;
      _recommendation = '';
      _parkingImages = [];
    });

    try {
      List<File> images = await firebaseService.fetchParkingImages();
      String result = await geminiService.analyzeImages(images);

      setState(() {
        _recommendation = result.trim();
        _parkingImages = images;
      });
    } catch (e) {
      setState(() {
        _recommendation = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildAnalyzeButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _analyzeParkingImages,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      child: const Text('Analyze Parking'),
    );
  }

  Widget _buildToggleImagesButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          _showImages = !_showImages;
        });
      },
      child: Text(
        _showImages ? 'Hide Parking Images' : 'Show Parking Images',
        style: const TextStyle(color: Colors.tealAccent, fontSize: 16),
      ),
    );
  }

 Widget _buildImagesGallery() {
  if (!_showImages || _parkingImages.isEmpty) return const SizedBox.shrink();

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _parkingImages.map((imageFile) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.tealAccent.withOpacity(0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(2, 2),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ),
  );
}



  Widget _buildRecommendationCard() {
    if (_recommendation.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        const Text(
          'Recommended Slot',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 10),
        Card(
          color: const Color(0xFF2C2F48),
          elevation: 12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 36),
            child: Text(
              _recommendation,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.tealAccent,
                letterSpacing: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text(
          'Smart Parking Assistant',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF262837),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAnalyzeButton(),
                const SizedBox(height: 20),
                _buildToggleImagesButton(),
                const SizedBox(height: 10),
                _buildImagesGallery(),
                const SizedBox(height: 30),
                if (_isLoading)
                  const CircularProgressIndicator(
                    color: Colors.tealAccent,
                  )
                else
                  _buildRecommendationCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
