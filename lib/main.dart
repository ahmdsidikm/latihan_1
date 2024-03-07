// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark, // Set tema menjadi gelap
        scaffoldBackgroundColor:
            const Color(0xFF1E1E1E), // Atur warna latar belakang
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late Future<List<PostList>> _futurePostList;
  late TextEditingController _searchController;
  late TabController _tabController;
  var _currentIndex = 0;
  final double _appBarHeight = 180.0; // Default height

  @override
  void initState() {
    super.initState();
    _futurePostList = getProductData();
    _searchController = TextEditingController();
    _tabController = TabController(
        length: 4, vsync: this); // Updated length to 4 for additional tab
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  List<PostList> _searchPosts(List<PostList> posts, String query) {
    return posts.where((post) {
      final titleLower = post.title.toLowerCase();
      final queryLower = query.toLowerCase();
      return titleLower.contains(queryLower);
    }).toList();
  }

  List<PostList> _filterPostsByCategory(List<PostList> posts, String category) {
    if (category == 'All') {
      return posts;
    } else {
      return posts
          .where((post) =>
              post.title.toLowerCase().contains(category.toLowerCase()))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(_appBarHeight),
        child: AppBar(
          title: const Text(
            "REST API DEMO",
            style: TextStyle(
              fontSize: 35, // Sesuaikan ukuran yang diinginkan
              fontWeight: FontWeight.bold, // Jika diperlukan
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                });
              },
              icon: const Icon(Icons.clear),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(120.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color.fromARGB(0, 232, 220, 220),
                            hintText: 'Search',
                            hintStyle: const TextStyle(
                              color: Color.fromARGB(255, 185, 185, 185),
                            ),
                            prefixIcon: null,
                            suffixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                  color: Color.fromARGB(255, 46, 46, 46)),
                            ),
                          ),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                Wrap(
                  children: [
                    _buildTab('All'),
                    _buildTab('Sport'),
                    _buildTab('Politic'),
                    _buildTab('Education')
                  ],
                ),
                const Divider(
                  color: Colors.grey,
                  height: 1,
                  thickness: 1,
                ),
              ],
            ),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _futurePostList,
        builder: (context, AsyncSnapshot<List<PostList>> postSnapshot) {
          if (postSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (postSnapshot.hasError) {
            return Center(
              child: Text('Error: ${postSnapshot.error}'),
            );
          } else if (postSnapshot.hasData) {
            List<PostList> filteredPosts = _searchController.text.isEmpty
                ? postSnapshot.data!
                : _searchPosts(postSnapshot.data!, _searchController.text);

            if (_tabController.index == 1) {
              filteredPosts = _filterPostsByCategory(filteredPosts, 'Sport');
            } else if (_tabController.index == 2) {
              filteredPosts = _filterPostsByCategory(filteredPosts, 'Politic');
            } else if (_tabController.index == 3) {
              filteredPosts =
                  _filterPostsByCategory(filteredPosts, 'Education');
            }

            if (filteredPosts.isEmpty) {
              return const Center(
                child: Text('No posts found.'),
              );
            }

            return AnimatedOpacity(
              opacity: 1.0,
              duration: const Duration(milliseconds: 500),
              child: ListView.builder(
                itemCount: filteredPosts.length,
                itemBuilder: (context, index) {
                  String postNumber = (index + 1).toString().padLeft(2, '0');
                  return Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              post: filteredPosts[index],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              margin: const EdgeInsets.only(right: 16.0),
                              child: Text(
                                postNumber,
                                style: const TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(70, 153, 156, 167),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filteredPosts[index].title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Text(filteredPosts[index].body),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          /// Home
          SalomonBottomBarItem(
            icon: const Icon(Icons.home),
            title: const Text("Home"),
            selectedColor: const Color.fromARGB(2248, 84, 68, 243),
          ),

          /// Likes
          SalomonBottomBarItem(
            icon: const Icon(Icons.explore),
            title: const Text("Explore"),
            selectedColor: const Color.fromARGB(248, 84, 68, 243),
          ),

          /// Search
          SalomonBottomBarItem(
            icon: const Icon(Icons.bookmark_add),
            title: const Text("Search"),
            selectedColor: const Color.fromARGB(248, 84, 68, 243),
          ),

          /// Profile
          SalomonBottomBarItem(
            icon: const Icon(Icons.person),
            title: const Text("Profile"),
            selectedColor: const Color.fromARGB(248, 84, 68, 243),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    return GestureDetector(
      onTap: () {
        int index = ['All', 'Sport', 'Politic', 'Education'].indexOf(title);
        _tabController.animateTo(index);

        // Update filtered posts based on selected category
        setState(() {
          if (title == 'Sport') {
            _currentIndex = 1; // Update bottom navigation bar index
          } else if (title == 'Politic') {
            _currentIndex = 2; // Update bottom navigation bar index
          } else if (title == 'Education') {
            _currentIndex = 3; // Update bottom navigation bar index
          } else {
            _currentIndex = 0; // Update bottom navigation bar index for 'All'
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 9),
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: _tabController.index ==
                  ['All', 'Sport', 'Politic', 'Education'].indexOf(title)
              ? const Color.fromARGB(
                  248, 84, 68, 243) // Warna teks saat tab navigasi atas aktif
              : const Color.fromARGB(
                  255, 39, 41, 44), // Warna saat tab navigasi tidak aktif,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: _tabController.index ==
                    ['All', 'Sport', 'Politic', 'Education'].indexOf(title)
                ? Colors.white // Warna teks saat tab navigasi  aktif
                : const Color.fromARGB(255, 89, 88,
                    88), // Warna teks saat tab navigasi tidak aktif
          ),
        ),
      ),
    );
  }
}

class PostList {
  int userId;
  int id;
  String title;
  String body;

  PostList({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
  });

  factory PostList.fromJson(dynamic json) => PostList(
        id: json["id"],
        userId: json["userId"],
        title: json["title"],
        body: json["body"],
      );
}

class DetailPage extends StatelessWidget {
  final PostList post;

  const DetailPage({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                ),
              ),
              Text(post.body),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<PostList>> getProductData() async {
  http.Response response =
      await http.get(Uri.parse("https://jsonplaceholder.typicode.com/posts"));
  if (response.statusCode == 200) {
    try {
      var data = jsonDecode(response.body) as List;
      return data.map((e) => PostList.fromJson(e)).toList();
    } catch (e) {
      log("message", error: e.toString());
      throw Exception('Failed to load data');
    }
  } else {
    throw Exception('Failed to load data');
  }
}


//KODE BACKUP