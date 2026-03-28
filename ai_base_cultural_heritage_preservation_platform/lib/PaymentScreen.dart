import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
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
    razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout() {
    var options = {
      "key": "rzp_live_RFyPRITKWrAzCt",
      "amount": 100 * 100,
      "name": "Cultural Heritage App",
      "description": "Ticket Payment",
      "prefill": {"contact": "9999999999", "email": "test@example.com"},
    };

    razorpay.open(options);
  }

  void _handleSuccess(PaymentSuccessResponse response) {
    print("Payment Success: ${response.paymentId}");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Payment Done")));
  }

  void _handleError(PaymentFailureResponse response) {
    print("Payment Error: ${response.message}");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Payment Failed")));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet Selected: ${response.walletName}");
  }

  @override
  void dispose() {
    razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Payment")),
      body: Center(
        child: ElevatedButton(onPressed: openCheckout, child: Text("Pay ₹100")),
      ),
    );
  }
}
