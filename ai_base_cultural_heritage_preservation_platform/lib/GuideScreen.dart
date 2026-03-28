

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'GuideBookingScreen.dart';

class GuideScreen extends StatefulWidget {
  final String siteName;

  const GuideScreen({super.key, required this.siteName});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List guides = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGuides();
  }

  Future<void> fetchGuides() async {
    final snapshot = await _firestore
        .collection("heritage_sites")
        .where("name", isEqualTo: widget.siteName)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      setState(() {
        guides = snapshot.docs.first['guides'] ?? [];
        isLoading = false;
      });
    }
  }

  Future<void> makeCall(String phone) async {
    final Uri callUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(callUri)) {
      await launchUrl(callUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot launch call")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Available Guides")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: guides.length,
              itemBuilder: (context, index) {
                final guide = guides[index];

                return Card(
                  child: ListTile(
                    title: Text(guide['name']),
                    subtitle: Text("₹${guide['price_per_hour']} / hour"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.call),
                          color: Colors.green,
                          onPressed: () {
                            makeCall(guide['phone']);
                          },
                        ),
                        const Icon(Icons.arrow_forward),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GuideBookingScreen(
                            guide: guide,
                            siteName: widget.siteName,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}



