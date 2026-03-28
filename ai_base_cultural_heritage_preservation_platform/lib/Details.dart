
// import 'package:ai_base_cultural_heritage_preservation_platform/PaymentScreen.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_tts/flutter_tts.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'ARViewScreen.dart';

// class Details extends StatefulWidget {
//   final String name;
//   final String description;
//   final String modelUrl;

//   const Details({
//     super.key,
//     required this.name,
//     required this.description,
//     required this.modelUrl,
//   });

//   @override
//   State<Details> createState() => _DetailsState();
// }

// class _DetailsState extends State<Details> {
//   final FlutterTts flutterTts = FlutterTts();
//   bool isSpeaking = false;
//   List<dynamic> imageList = [];
//   bool isLoading = true;

//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   @override
//   void initState() {
//     super.initState();
//     fetchImagesFromFirebase();
//   }

//   Future<void> fetchImagesFromFirebase() async {
//     try {
//       final snapshot =
//           await _firestore
//               .collection('heritage_sites')
//               .where('name', isEqualTo: widget.name)
//               .limit(1)
//               .get();

//       if (snapshot.docs.isNotEmpty) {
//         setState(() {
//           imageList = snapshot.docs.first['images'] ?? [];
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           imageList = [];
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching images: $e");
//       setState(() {
//         imageList = [];
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _speak() async {
//     await flutterTts.setLanguage("en-IN");
//     await flutterTts.setPitch(1.0);
//     await flutterTts.speak(widget.description);
//     setState(() {
//       isSpeaking = true;
//     });
//   }

//   Future<void> _stop() async {
//     await flutterTts.stop();
//     setState(() {
//       isSpeaking = false;
//     });
//   }

//   @override
//   void dispose() {
//     flutterTts.stop();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         title: Text(
//           widget.name,
//           style: const TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.deepPurple,
//       ),

//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               physics: const BouncingScrollPhysics(),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),

//                   // 🔥 IMAGE SECTION FIXED
//                   if (imageList.isNotEmpty)
//                     SizedBox(
//                       height: 250,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: imageList.length,
//                         itemBuilder: (context, index) {
//                           final imageUrl = imageList[index];

//                           return Padding(
//                             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//                             child: ClipRRect(
//                               borderRadius: BorderRadius.circular(15),
//                               child: imageUrl.toString().startsWith("http")
//                                   ? Image.network(
//                                       imageUrl,
//                                       height: 250,
//                                       width: 330,
//                                       fit: BoxFit.cover,
//                                       errorBuilder:
//                                           (context, error, stackTrace) =>
//                                               const Center(
//                                         child: Icon(
//                                           Icons.broken_image,
//                                           size: 80,
//                                         ),
//                                       ),
//                                       loadingBuilder:
//                                           (context, child, loadingProgress) {
//                                         if (loadingProgress == null) return child;
//                                         return const Center(
//                                           child: CircularProgressIndicator(),
//                                         );
//                                       },
//                                     )
//                                   : Image.asset(
//                                       imageUrl
//                                           .toString()
//                                           .replaceAll("file:///", ""),
//                                       height: 250,
//                                       width: 330,
//                                       fit: BoxFit.cover,
//                                       errorBuilder:
//                                           (context, error, stackTrace) =>
//                                               const Center(
//                                         child: Icon(
//                                           Icons.broken_image,
//                                           size: 80,
//                                         ),
//                                       ),
//                                     ),
//                             ),
//                           );
//                         },
//                       ),
//                     )
//                   else
//                     const Padding(
//                       padding: EdgeInsets.all(16.0),
//                       child: Center(
//                         child: Text(
//                           "No Images Available",
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.black54,
//                           ),
//                         ),
//                       ),
//                     ),

//                   const SizedBox(height: 20),

//                   Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 16),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           "About the Monument",
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.w700,
//                             color: Colors.deepPurple,
//                           ),
//                         ),
//                         const SizedBox(height: 10),
//                         Text(
//                           widget.description,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             height: 1.5,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 30),

//                         Center(
//                           child: isSpeaking
//                               ? ElevatedButton.icon(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.redAccent,
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 14),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                   onPressed: _stop,
//                                   icon: const Icon(Icons.stop, color: Colors.white),
//                                   label: const Text(
//                                     "Stop",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 )
//                               : ElevatedButton.icon(
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: Colors.deepPurple,
//                                     padding: const EdgeInsets.symmetric(
//                                         horizontal: 20, vertical: 14),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(12),
//                                     ),
//                                   ),
//                                   onPressed: _speak,
//                                   icon: const Icon(Icons.volume_up,
//                                       color: Colors.white),
//                                   label: const Text(
//                                     "Listen to Story",
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w600,
//                                     ),
//                                   ),
//                                 ),
//                         ),

//                         const SizedBox(height: 20),

//                         Center(
//                           child: ElevatedButton.icon(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.orangeAccent,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             onPressed: () {
//                               flutterTts.stop();
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => ARViewScreen(
//                                     modelUrl: widget.modelUrl,
//                                   ),
//                                 ),
//                               );
//                             },
//                             icon: const Icon(Icons.view_in_ar,
//                                 color: Colors.white),
//                             label: const Text(
//                               "View in AR",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),

//                         const SizedBox(height: 30),
//                         Center(
//                           child: ElevatedButton.icon(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.orangeAccent,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 14),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                               ),
//                             ),
//                             onPressed: () {
//                               Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => PaymentScreen(),
//                                 ),
//                               );
//                             },
//                             icon: const Icon(Icons.payment,
//                                 color: Colors.white),
//                             label: const Text(
//                               "Pay & View AR",
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//     );
//   }
// }





import 'package:ai_base_cultural_heritage_preservation_platform/AllFeedbackScreen.dart';
import 'package:ai_base_cultural_heritage_preservation_platform/PaymentScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ARViewScreen.dart';

class Details extends StatefulWidget {
  final String name;
  final String description;
  final String modelUrl;

  const Details({
    super.key,
    required this.name,
    required this.description,
    required this.modelUrl,
  });

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;
  List<dynamic> imageList = [];
  bool isLoading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    fetchImagesFromFirebase();
  }

  Future<void> fetchImagesFromFirebase() async {
    final snapshot = await _firestore
        .collection('heritage_sites')
        .where('name', isEqualTo: widget.name)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        imageList = snapshot.docs.first['images'] ?? [];
        isLoading = false;
      });
    }
  }

  Future<void> _speak() async {
    await flutterTts.setLanguage("en-IN");
    await flutterTts.speak(widget.description);
    setState(() => isSpeaking = true);
  }

  Future<void> _stop() async {
    await flutterTts.stop();
    setState(() => isSpeaking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.name)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Images
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: imageList.length,
                    itemBuilder: (context, index) {
                      final img = imageList[index];

                      return img.toString().startsWith("http")
                          ? Image.network(img)
                          : Image.asset(
                              img.toString().replaceAll("file:///", ""));
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(widget.description),
                ),

                // TTS
                ElevatedButton(
                  onPressed: isSpeaking ? _stop : _speak,
                  child: Text(isSpeaking ? "Stop" : "Listen"),
                ),

                const SizedBox(height: 20),

                // 🔥 AR BUTTON WITH PAYMENT CHECK
                ElevatedButton(
                  onPressed: () async {
                    final userId =
                        FirebaseAuth.instance.currentUser!.uid;

                    final snapshot = await _firestore
                        .collection('heritage_sites')
                        .where('name', isEqualTo: widget.name)
                        .limit(1)
                        .get();

                    if (snapshot.docs.isNotEmpty) {
                      final doc = snapshot.docs.first;

                      List users =
                          doc['purchased_user_ids'] ?? [];

                      if (users.contains(userId)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ARViewScreen(modelUrl: widget.modelUrl , name :widget.name),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(
                              docId: doc.id,
                              modelUrl: widget.modelUrl,
                              name: widget.name,
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text("View in AR"),
                ),

                ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                AllFeedbackScreen(modelUrl: widget.modelUrl),
          ),
        );
      },
      child: const Text(
        "View All Feedback",
        style: TextStyle(color: Colors.white),
      ),
    ),
              ],
            ),
    );
  }
}
