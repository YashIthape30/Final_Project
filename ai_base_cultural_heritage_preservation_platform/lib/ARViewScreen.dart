

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:model_viewer_plus/model_viewer_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';

// class ARViewScreen extends StatefulWidget {
//   final String modelUrl;

//   const ARViewScreen({super.key, required this.modelUrl});

//   @override
//   State<ARViewScreen> createState() => _ARViewScreenState();
// }

// class _ARViewScreenState extends State<ARViewScreen> {
//   final TextEditingController feedbackController = TextEditingController();
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   bool isSubmitting = false;

//   double selectedRating = 0;
//   double avgRating = 0;

//   String? docId;
//   Map<String, dynamic> userRatings = {};

//   @override
//   void initState() {
//     super.initState();
//     fetchData();
//   }

//   // 🔥 FETCH ALL DATA
//   Future<void> fetchData() async {
//     final snapshot = await _firestore
//         .collection("heritage_sites")
//         .where("model_url", isEqualTo: widget.modelUrl)
//         .limit(1)
//         .get();

//     if (snapshot.docs.isNotEmpty) {
//       final doc = snapshot.docs.first;
//       docId = doc.id;

//       final data = doc.data();

//       List ratings = data['ratings'] ?? [];
//       userRatings = data['userRatings'] ?? {};

//       // avg calc
//       if (ratings.isNotEmpty) {
//         double sum = 0;
//         for (var r in ratings) {
//           sum += (r as num).toDouble();
//         }
//         avgRating = sum / ratings.length;
//       }

//       // current user rating
//       final userId = FirebaseAuth.instance.currentUser!.uid;
//       if (userRatings.containsKey(userId)) {
//         selectedRating = (userRatings[userId] as num).toDouble();
//       }

//       setState(() {});
//     }
//   }

//   // 🔥 ⭐ RATE FUNCTION (ONLY ONE RATING PER USER)
//   Future<void> rate(double rating) async {
//     final userId = FirebaseAuth.instance.currentUser!.uid;

//     try {
//       final docRef =
//           _firestore.collection("heritage_sites").doc(docId);

//       // if already rated → remove old rating from array
//       if (userRatings.containsKey(userId)) {
//         double oldRating =
//             (userRatings[userId] as num).toDouble();

//         await docRef.update({
//           "ratings": FieldValue.arrayRemove([oldRating])
//         });
//       }

//       // add new rating
//       await docRef.update({
//         "ratings": FieldValue.arrayUnion([rating]),
//         "userRatings.$userId": rating
//       });

//       selectedRating = rating;

//       await fetchData();

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Rated $rating ⭐")),
//       );
//     } catch (e) {
//       debugPrint("Rating Error: $e");
//     }
//   }

//   // 🔥 FEEDBACK (unchanged logic)
//   Future<void> submitFeedback() async {
//     final feedbackText = feedbackController.text.trim();

//     if (feedbackText.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Feedback cannot be empty")),
//       );
//       return;
//     }

//     setState(() => isSubmitting = true);

//     try {
//       await _firestore.collection("heritage_sites").doc(docId).update({
//         "feedback": FieldValue.arrayUnion([feedbackText]),
//       });

//       feedbackController.clear();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Feedback Submitted")),
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("Failed: $e")),
//       );
//     }

//     setState(() => isSubmitting = false);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("3D Model Viewer"),
//         backgroundColor: Colors.deepPurple,
//         centerTitle: true,
//       ),

//       body: Column(
//         children: [
//           SizedBox(
//             height: MediaQuery.of(context).size.height * 0.45,
//             child: ModelViewer(
//               src: widget.modelUrl,
//               autoRotate: true,
//               cameraControls: true,
//               backgroundColor: Colors.white,
//             ),
//           ),

//           const SizedBox(height: 10),

//           Expanded(
//             child: SingleChildScrollView(
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [

//                     const Text(
//                       "Rate this Experience",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.deepPurple,
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     // ⭐⭐⭐⭐⭐ STARS
//                     Row(
//                       children: List.generate(5, (index) {
//                         return IconButton(
//                           onPressed: () => rate(index + 1.0),
//                           icon: Icon(
//                             index < selectedRating
//                                 ? Icons.star
//                                 : Icons.star_border,
//                             color: Colors.amber,
//                             size: 30,
//                           ),
//                         );
//                       }),
//                     ),

//                     // ⭐ AVG
//                     Center(
//                       child: Text(
//                         avgRating == 0
//                             ? "No ratings yet"
//                             : "⭐ ${avgRating.toStringAsFixed(1)}",
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 15),

//                     const Text(
//                       "Share Your Feedback",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.deepPurple,
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     TextField(
//                       controller: feedbackController,
//                       maxLines: 4,
//                       decoration: InputDecoration(
//                         hintText: "Type your feedback here...",
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                     ),

//                     const SizedBox(height: 15),

//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: isSubmitting ? null : submitFeedback,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.deepPurple,
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                         ),
//                         child: isSubmitting
//                             ? const CircularProgressIndicator(color: Colors.white)
//                             : const Text("Submit"),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }


import 'package:ai_base_cultural_heritage_preservation_platform/GuideScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ARViewScreen extends StatefulWidget {
  final String modelUrl;
  final String name;

  const ARViewScreen({super.key, required this.modelUrl, required this.name});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  final TextEditingController feedbackController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isSubmitting = false;

  double selectedRating = 0;
  double avgRating = 0;

  String? docId;
  Map<String, dynamic> userRatings = {};

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // 🔥 FETCH DATA
  Future<void> fetchData() async {
    final snapshot = await _firestore
        .collection("heritage_sites")
        .where("model_url", isEqualTo: widget.modelUrl)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final doc = snapshot.docs.first;
      docId = doc.id;

      final data = doc.data();

      List ratings = data['ratings'] ?? [];
      userRatings = data['userRatings'] ?? {};

      // avg calc
      if (ratings.isNotEmpty) {
        double sum = 0;
        for (var r in ratings) {
          sum += (r as num).toDouble();
        }
        avgRating = sum / ratings.length;
      }

      // current user rating
      final userId = FirebaseAuth.instance.currentUser!.uid;
      if (userRatings.containsKey(userId)) {
        selectedRating = (userRatings[userId] as num).toDouble();
      }

      setState(() {});
    }
  }

  // ⭐ RATE (1 USER = 1 RATING)
  Future<void> rate(double rating) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      final docRef =
          _firestore.collection("heritage_sites").doc(docId);

      // remove old rating
      if (userRatings.containsKey(userId)) {
        double oldRating =
            (userRatings[userId] as num).toDouble();

        await docRef.update({
          "ratings": FieldValue.arrayRemove([oldRating])
        });
      }

      // add new rating
      await docRef.update({
        "ratings": FieldValue.arrayUnion([rating]),
        "userRatings.$userId": rating
      });

      selectedRating = rating;

      await fetchData();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Rated $rating ⭐")),
      );
    } catch (e) {
      debugPrint("Rating Error: $e");
    }
  }

  // 🔥 UPDATED FEEDBACK (NAME + TEXT)
  Future<void> submitFeedback() async {
    final feedbackText = feedbackController.text.trim();

    if (feedbackText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback cannot be empty")),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      // 🔥 name before @
      String name = user!.email!.split('@')[0];

      await _firestore.collection("heritage_sites").doc(docId).update({
        "feedback": FieldValue.arrayUnion([
          {
            "name": name,
            "text": feedbackText,
          }
        ]),
      });

      feedbackController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback Submitted")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e")),
      );
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("3D Model Viewer"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),

      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: ModelViewer(
              src: widget.modelUrl,
              autoRotate: true,
              cameraControls: true,
              backgroundColor: Colors.white,
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text(
                      "Rate this Experience",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.deepPurple,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ⭐ STARS
                    Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          onPressed: () => rate(index + 1.0),
                          icon: Icon(
                            index < selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 30,
                          ),
                        );
                      }),
                    ),

                    // ⭐ AVG
                    Center(
                      child: Text(
                        avgRating == 0
                            ? "No ratings yet"
                            : "⭐ ${avgRating.toStringAsFixed(1)} / 5",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Share Your Feedback",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.deepPurple,
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      controller: feedbackController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Type your feedback here...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : submitFeedback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Submit"),
                      ),
                    ),

                    ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GuideScreen(siteName: widget.name),
      ),
    );
  },
  icon: Icon(Icons.person),
  label: Text("Book Guide"),
),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}