import 'package:ai_base_cultural_heritage_preservation_platform/Details.dart';
import 'package:ai_base_cultural_heritage_preservation_platform/LoginScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Map<String, bool> likedSites = {};

  TextEditingController searchController = TextEditingController();
  String searchKeyword = "";

  @override
  Widget build(BuildContext context) {
    final userEmail = _auth.currentUser?.email ?? "User";

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        title: const Text(
          "Cultural Heritage AR",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) async {
              if (value == 'logout') {
                await _auth.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                }
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem<String>(
                    value: 'user',
                    enabled: false,
                    child: Text(
                      "Logged in as: $userEmail",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 23, 25, 26),
                      ),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem<String>(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red),
                        SizedBox(width: 10),
                        Text("Logout"),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search heritage sites...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchKeyword = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('heritage_sites').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final sites =
                    snapshot.data!.docs.where((site) {
                      final name = site['name'].toString().toLowerCase();
                      return name.contains(searchKeyword);
                    }).toList();

                if (sites.isEmpty) {
                  return const Center(child: Text("No matching sites found"));
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        for (var site in sites)
                          _buildBeautifulCard(
                            site.id,
                            site['name'],
                            site['image'],
                            site['description'],
                            site['model_url'],
                            site['likes'] ?? 0,
                            site['visited_count'] ?? 0,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBeautifulCard(
    String docId,
    String name,
    String image,
    String description,
    String modelUrl,
    int likeCount,
    int visitedCount,
  ) {
    bool isLiked = likedSites[docId] ?? false;

    return InkWell(
      onTap: () async {
        await _firestore.collection('heritage_sites').doc(docId).update({
          "visited_count": FieldValue.increment(1),
        });

        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => Details(
                  name: name,
                  description: description,
                  modelUrl: modelUrl,
                ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        height: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.deepPurple.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                image,
                height: 230,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Visited: $visitedCount",
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              bool newLikeStatus = !isLiked;

                              setState(() {
                                likedSites[docId] = newLikeStatus;
                              });

                              int updateCount =
                                  likeCount + (newLikeStatus ? 1 : -1);

                              await _firestore
                                  .collection('heritage_sites')
                                  .doc(docId)
                                  .update({"likes": updateCount});
                            },
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked ? Colors.red : Colors.white,
                              size: 28,
                            ),
                          ),
                          Text(
                            "$likeCount",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(width: 15),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.explore, color: Colors.white, size: 18),
                            SizedBox(width: 5),
                            Text(
                              "View",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
