import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:intl/intl.dart';

class GuideBookingScreen extends StatefulWidget {
  final Map guide;
  final String siteName;

  const GuideBookingScreen({
    super.key,
    required this.guide,
    required this.siteName,
  });

  @override
  State<GuideBookingScreen> createState() => _GuideBookingScreenState();
}

class _GuideBookingScreenState extends State<GuideBookingScreen> {
  DateTime? selectedDate;
  int selectedHours = 1;
  int startTime = 9;

  late Razorpay razorpay;

  @override
  void initState() {
    super.initState();

    razorpay = Razorpay();
    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
  }

  int get totalPrice =>
      selectedHours * (widget.guide['price_per_hour'] as int);

  String get selectedDateString =>
      "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}";

  // 📅 date picker
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  // 🔥 availability check
  Future<bool> isGuideAvailable() async {
    final snapshot = await FirebaseFirestore.instance
        .collection("guide_bookings")
        .where("guide_id", isEqualTo: widget.guide['id'])
        .where("date", isEqualTo: selectedDateString)
        .get();

    for (var doc in snapshot.docs) {
  int bookedStart = (doc['start_time'] as num).toInt();
  int bookedEnd = bookedStart + (doc['hours'] as num).toInt();

  int newStart = startTime;
  int newEnd = startTime + selectedHours;

  if (newStart < bookedEnd && newEnd > bookedStart) {
    return false;
  }
}

return true;
  }

  // 💳 payment
  void openPayment() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Select date")));
      return;
    }

    bool available = await isGuideAvailable();

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Guide already booked")),
      );
      return;
    }

    razorpay.open({
      "key": "rzp_live_RFyPRITKWrAzCt",
      "amount": totalPrice * 100,
      "name": widget.guide['name'],
    });
  }

  // ✅ success
  void _handleSuccess(PaymentSuccessResponse response) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection("guide_bookings").add({
      "user_id": userId,
      "site_name": widget.siteName,
      "guide_id": widget.guide['id'],
      "guide_name": widget.guide['name'],
      "phone": widget.guide['phone'],
      "date": selectedDateString,
      "start_time": startTime,
      "hours": selectedHours,
      "total_price": totalPrice,
      "payment_status": "paid",
      "created_at": Timestamp.now(),
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Booking Confirmed")));

    Navigator.pop(context);
  }

  void _handleError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Payment Failed")));
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.guide['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Text("₹${widget.guide['price_per_hour']} / hour"),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: pickDate,
              child: Text(
                selectedDate == null
                    ? "Select Date"
                    : DateFormat('dd MMM yyyy').format(selectedDate!),
              ),
            ),

            const SizedBox(height: 20),

            DropdownButton<int>(
              value: startTime,
              items: List.generate(10, (i) {
                int hour = i + 8;
                return DropdownMenuItem(
                  value: hour,
                  child: Text("$hour:00"),
                );
              }),
              onChanged: (val) {
                setState(() => startTime = val!);
              },
            ),

            const SizedBox(height: 20),

            DropdownButton<int>(
              value: selectedHours,
              items: [1, 2, 3, 4, 5]
                  .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text("$e Hours"),
                      ))
                  .toList(),
              onChanged: (val) {
                setState(() => selectedHours = val!);
              },
            ),

            const SizedBox(height: 20),

            Text("Total: ₹$totalPrice"),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: openPayment,
              child: const Text("Pay & Book"),
            ),
          ],
        ),
      ),
    );
  }
}