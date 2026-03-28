import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllFeedbackScreen extends StatefulWidget {
  final String modelUrl;

  const AllFeedbackScreen({super.key, required this.modelUrl});

  @override
  State<AllFeedbackScreen> createState() => _AllFeedbackScreenState();
}

class _AllFeedbackScreenState extends State<AllFeedbackScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> feedbackList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFeedback();
  }

  Future<void> fetchFeedback() async {
    try {
      final snapshot = await _firestore
          .collection("heritage_sites")
          .where("model_url", isEqualTo: widget.modelUrl)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();

        setState(() {
          feedbackList =
              List<Map<String, dynamic>>.from(data['feedback'] ?? []);
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Feedback"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : feedbackList.isEmpty
              ? const Center(child: Text("No feedback yet"))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: feedbackList.length,
                  itemBuilder: (context, index) {
                    final item = feedbackList[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 5,
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔥 USER NAME
                          Text(
                            item['name'] ?? "User",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 5),

                          // 🔥 FEEDBACK TEXT
                          Text(
                            item['text'] ?? "",
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}