import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddMovieScreen extends StatefulWidget {
  final Function(String, String, String, File?) addMovieCallback;

  const AddMovieScreen({Key? key, required this.addMovieCallback}) : super(key: key);

  @override
  _AddMovieScreenState createState() => _AddMovieScreenState();
}

class _AddMovieScreenState extends State<AddMovieScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _getImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Movie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _getImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: _imageFile != null
                      ? Image.file(_imageFile!, fit: BoxFit.cover)
                      : const Icon(Icons.add_photo_alternate, size: 50),
                ),
              ),

              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
              ),
              TextField(
                controller: _languageController,
                decoration: const InputDecoration(labelText: 'Language'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String name = _nameController.text.trim();
                  String year = _yearController.text.trim();
                  String language = _languageController.text.trim();
                  if (name.isNotEmpty && year.isNotEmpty && language.isNotEmpty) {
                    widget.addMovieCallback(name, year, language, _imageFile);
                    Navigator.pop(context);
                  } else {
                    // Show error message or handle empty fields
                  }
                },
                child: const Text('Add Movie'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _languageController.dispose();
    super.dispose();
  }
}
