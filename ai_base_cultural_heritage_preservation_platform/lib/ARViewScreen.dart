import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class ARViewScreen extends StatefulWidget {
  final String modelUrl ;
  
  const ARViewScreen({super.key, required this.modelUrl});

  @override
  State<ARViewScreen> createState() => _ARViewScreenState();
}

class _ARViewScreenState extends State<ARViewScreen> {
  final TextEditingController feedbackController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  bool isSubmitting = false;

  Future<void> submitFeedback() async {
    final feedbackText = feedbackController.text.trim();
    if (feedbackText.isEmpty) return;

    setState(() => isSubmitting = true);

    try {
      await _firestore
          .collection("heritage_sites")
          .where("model_url", isEqualTo: widget.modelUrl)
          .limit(1)
          .get()
          .then((snapshot) {
            if (snapshot.docs.isNotEmpty) {
              final docId = snapshot.docs.first.id;
              _firestore.collection("heritage_sites").doc(docId).update({
                "feedback": FieldValue.arrayUnion([feedbackText]),
              });
            }
          });

      feedbackController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Feedback submitted"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: $e"), backgroundColor: Colors.red),
      );
    }

    setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "3D Model Viewer",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),

      body: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.45,
            child: Stack(
              children: [
                ModelViewer(
                  // src: "https://raw.githubusercontent.com/YashIthape30/TajMahal/main/cvjxb8n6buo0-tajmahal.glb",
                  src: widget.modelUrl,
                  // src: "https://modelviewer.dev/shared-assets/models/Astronaut.glb",
                  alt: "Heritage 3D Model",
                  autoRotate: true,
                  cameraControls: true,
                  disableZoom: false,
                  backgroundColor: Colors.white,
                  // loading: Loading.auto,
                ),

                // const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    style: const TextStyle(fontSize: 18, height: 1.5),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(18),
                      hintText: "Type your feedback here...",
                      hintStyle: const TextStyle(fontSize: 16),
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
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          isSubmitting
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                "Submit Feedback",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
