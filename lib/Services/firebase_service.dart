import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<File>> fetchParkingImages() async {
    final snapshot = await _firestore.collection('parking_images').get();
    List<File> imageFiles = [];

    for (var doc in snapshot.docs) {
      final String imageUrl = doc['url'];
      final response = await http.get(Uri.parse(imageUrl));

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/${doc.id}.jpg';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      imageFiles.add(file);
    }

    return imageFiles;
  }
}
