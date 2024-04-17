import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'add_movies.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final List<Movie> movieList = [];

  @override
  void initState() {
    super.initState();
    _getMoviesList();
  }

  void _getMoviesList() {
    _firebaseFirestore.collection('movies').get().then((value) {
      movieList.clear();
      for (QueryDocumentSnapshot doc in value.docs) {
        movieList.add(
          Movie.fromJson(doc.id, doc.data() as Map<String, dynamic>),
        );
      }
      setState(() {});
    });
  }

  void _addMovie(String name, String year, String language, File? imageFile) async {
    if (imageFile != null) {
      final Reference storageRef = FirebaseStorage.instance.ref().child('movie_images/${DateTime.now().millisecondsSinceEpoch}');
      final UploadTask uploadTask = storageRef.putFile(imageFile);

      TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete(() {});
      String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
      _firebaseFirestore.collection('movies').add({
        'name': name,
        'year': year,
        'language': language,
        'imageUrl': imageUrl,
      }).then((value) {
        _getMoviesList();
      }).catchError((error) {
        // Handle any errors
      });
    } else {
      _firebaseFirestore.collection('movies').add({
        'name': name,
        'year': year,
        'language': language,
      }).then((value) {
        _getMoviesList();
      }).catchError((error) {
      });
    }
  }

  void _deleteMovie(String id) {
    _firebaseFirestore.collection('movies').doc(id).delete().then((value) {
      _getMoviesList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Project'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: .5,
          ),
          itemCount: movieList.length,
          itemBuilder: (BuildContext context, index) {
            return Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        image: DecorationImage(
                          image: NetworkImage(
                            movieList[index].imageUrl,
                          ),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(movieList[index].name),
                          Text(movieList[index].year),
                          Text(movieList[index].languages),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      _deleteMovie(movieList[index].id);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMovieScreen(addMovieCallback: _addMovie)),
          );
        },
        tooltip: 'Add Movie',
        child: Icon(Icons.add),
      ),
    );
  }
}

class Movie {
  final String id, name, languages, year, imageUrl;

  Movie({
    required this.id,
    required this.name,
    required this.languages,
    required this.year,
    required this.imageUrl,
  });

  factory Movie.fromJson(String id, Map<String, dynamic> json) {
    return Movie(
      id: id,
      name: json['name'] ?? '',
      year: json['year'] ?? '',
      languages: json['language'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}
