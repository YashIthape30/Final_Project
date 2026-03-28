// index.js (Firebase functions v2 / v7+ compatible)
const functions = require("firebase-functions/v2");
const Razorpay = require("razorpay");
const cors = require("cors")({ origin: true });

// Razorpay keys using environment variables
const razorpay = new Razorpay({
  key_id: process.env.RAZORPAY_KEY_ID,
  key_secret: process.env.RAZORPAY_KEY_SECRET,
});

exports.createOrder = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    try {
      const { amount } = req.body;

      if (!amount) {
        return res.status(400).json({ error: "Amount is required" });
      }

      const options = {
        amount: amount * 100, // amount in paise
        currency: "INR",
        receipt: `receipt_${Date.now()}`,
      };

      const order = await razorpay.orders.create(options);
      res.status(200).json(order);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: error.message });
    }
  });
});
