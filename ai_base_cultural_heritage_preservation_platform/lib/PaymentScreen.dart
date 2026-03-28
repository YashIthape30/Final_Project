// import 'package:flutter/material.dart';
// import 'package:razorpay_flutter/razorpay_flutter.dart';

// class PaymentScreen extends StatefulWidget {
//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   late Razorpay razorpay;

//   @override
//   void initState() {
//     super.initState();

//     razorpay = Razorpay();

//     razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
//     razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
//     razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
//   }

//   void openCheckout() {
//     var options = {
//       "key": "rzp_live_RFyPRITKWrAzCt",
//       "amount": 1 * 100,
//       "name": "Cultural Heritage App",
//       "description": "Ticket Payment",
//       "prefill": {"contact": "9999999999", "email": "test@example.com"},
//     };

//     razorpay.open(options);
//   }

//   void _handleSuccess(PaymentSuccessResponse response) {
//     print("Payment Success: ${response.paymentId}");
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text("Payment Done")));
//   }

//   void _handleError(PaymentFailureResponse response) {
//     print("Payment Error: ${response.message}");
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(SnackBar(content: Text("Payment Failed")));
//   }

//   void _handleExternalWallet(ExternalWalletResponse response) {
//     print("External Wallet Selected: ${response.walletName}");
//   }

//   @override
//   void dispose() {
//     razorpay.clear();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Payment")),
//       body: Center(
//         child: ElevatedButton(onPressed: openCheckout, child: Text("Pay ₹100")),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ARViewScreen.dart';

class PaymentScreen extends StatefulWidget {
  final String docId;
  final String modelUrl;
  final String name;

  const PaymentScreen({
    super.key,
    required this.docId,
    required this.modelUrl,
    required this.name,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay razorpay;

  @override
  void initState() {
    super.initState();
    razorpay = Razorpay();

    razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleSuccess);
    razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handleError);
  }

  void openCheckout() {
    razorpay.open({
      "key": "rzp_live_RFyPRITKWrAzCt", // use test key
      "amount": 1,
      "name": "Cultural Heritage App",
    });
  }

  void _handleSuccess(PaymentSuccessResponse response) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('heritage_sites')
        .doc(widget.docId)
        .update({
      "purchased_user_ids": FieldValue.arrayUnion([userId])
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Payment Done")));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ARViewScreen(modelUrl: widget.modelUrl , name: widget.name,),
      ),
    );
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
      appBar: AppBar(title: const Text("Payment")),
      body: Center(
        child: ElevatedButton(
          onPressed: openCheckout,
          child: const Text("Pay ₹100"),
        ),
      ),
    );
  }
}