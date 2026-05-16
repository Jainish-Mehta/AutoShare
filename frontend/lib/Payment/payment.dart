import 'package:autoshare/Payment/payment_success.dart';
import 'package:autoshare/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class Payment extends StatefulWidget {
  final String fare;
  final String driverName;
  final String vehicalNo;
  final String rideId;

  const Payment({
    required this.fare,
    required this.driverName,
    required this.vehicalNo,
    required this.rideId,
    super.key,
  });

  @override
  PaymentState createState() => PaymentState();
}

class PaymentState extends State<Payment> {
  int selectedIndex = -1;
  bool isLoading = false;

  // Razorpay instance — handles payment sheet
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();

    // Initialize Razorpay and set callbacks
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void dispose() {
    // Always clear Razorpay listeners when screen closes
    _razorpay.clear();
    super.dispose();
  }

  // ── Payment Success ──────────────────────────────────────────────────────
  // Called by Razorpay SDK after successful payment
  // We get 3 IDs — send them to backend for verification
  void _onPaymentSuccess(PaymentSuccessResponse response) async {
    try {
      setState(() => isLoading = true);

      // Verify payment on backend
      await ApiService.verifyPayment(
        rideId: widget.rideId,
        orderId: response.orderId ?? '',
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '',
      );

      if (!mounted) return;
      setState(() => isLoading = false);

      // Navigate to success screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Paymentsuccess(
            driverName: widget.driverName,
            vehicalNo: widget.vehicalNo,
            rideId: widget.rideId,
          ),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment verification failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Payment Error ────────────────────────────────────────────────────────
  // Called when payment fails or user cancels
  void _onPaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${response.message}'),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ── External Wallet ──────────────────────────────────────────────────────
  // Called when user selects external wallet like PayTM
  void _onExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet: ${response.walletName}'),
      ),
    );
  }

  // ── Open Razorpay Payment Sheet ──────────────────────────────────────────
  // Creates order on backend then opens Razorpay checkout
  Future<void> _openRazorpay() async {
    try {
      setState(() => isLoading = true);

      // Step 1 — Create order on backend
      final orderData = await ApiService.createPaymentOrder(
        rideId: widget.rideId,
        amount: double.parse(widget.fare),
      );

      setState(() => isLoading = false);

      // Step 2 — Open Razorpay payment sheet
      var options = {
        'key': orderData['key_id'],           // your Razorpay key
        'amount': orderData['amount'],         // in paise
        'currency': orderData['currency'],
        'order_id': orderData['order_id'],
        'name': 'AutoShare',
        'description': 'Auto Rickshaw Fare',
        'prefill': {
          'contact': '',                       // pre-fill customer phone
          'email': '',                         // pre-fill customer email
        },
        'theme': {
          'color': '#FEBB26',                  // your app's yellow color
        }
      };

      _razorpay.open(options);

    } catch (e) {
      setState(() => isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ── Cash Payment ─────────────────────────────────────────────────────────
  Future<void> _payCash() async {
    try {
      setState(() => isLoading = true);
      await ApiService.recordCashPayment(rideId: widget.rideId);
      setState(() => isLoading = false);

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => Paymentsuccess(
            driverName: widget.driverName,
            vehicalNo: widget.vehicalNo,
            rideId: widget.rideId,
          ),
        ),
      );
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            "Payment",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color.fromARGB(255, 254, 187, 38),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // ── Fare display ──────────────────────────────
                      Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Column(
                          children: [
                            const Text("Charge",
                                style: TextStyle(
                                    fontSize: 56,
                                    color: Color.fromARGB(185, 0, 0, 0))),
                            const SizedBox(height: 10),
                            const Text("Amount",
                                style: TextStyle(
                                    fontSize: 21,
                                    color: Color.fromARGB(185, 0, 0, 0))),
                            const SizedBox(height: 10),
                            Text('₹${widget.fare}',
                                style: const TextStyle(
                                    fontSize: 21,
                                    color: Color.fromARGB(185, 0, 0, 0))),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Divider(color: Colors.grey),
                      ),

                      // ── Payment methods ───────────────────────────
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 35, left: 16, right: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Select payment method',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500)),
                              const SizedBox(height: 5),

                              // Razorpay — handles UPI, cards, wallets
                              _paymentOption(
                                index: 0,
                                icon: Icons.payment,
                                label: 'Pay Online',
                                subtitle: 'UPI, Cards, Wallets via Razorpay',
                              ),
                              const SizedBox(height: 5),

                              // Cash
                              _paymentOption(
                                index: 1,
                                imgPath: 'assets/Images/Cash.png',
                                label: 'Cash Payment',
                                subtitle: 'Pay driver directly',
                              ),
                              const SizedBox(height: 80),

                              // Pay button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 254, 187, 38),
                                  minimumSize:
                                      const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: selectedIndex == -1
                                    ? null
                                    : () {
                                        if (selectedIndex == 0) {
                                          // Online payment via Razorpay
                                          _openRazorpay();
                                        } else {
                                          // Cash payment
                                          _payCash();
                                        }
                                      },
                                child: const Text(
                                  "Proceed to Pay",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // ── Payment option widget ──────────────────────────────────────────────
  Widget _paymentOption({
    required int index,
    required String label,
    required String subtitle,
    IconData? icon,
    String? imgPath,
  }) {
    return GestureDetector(
      onTap: () => setState(() => selectedIndex = index),
      child: Container(
        decoration: BoxDecoration(
          color: selectedIndex == index
              ? const Color.fromARGB(255, 254, 248, 195)
              : const Color.fromARGB(140, 254, 248, 195),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedIndex == index
                ? const Color.fromARGB(255, 233, 174, 46)
                : const Color.fromARGB(145, 232, 210, 45),
            width: 2,
          ),
        ),
        width: double.infinity,
        child: ListTile(
          leading: imgPath != null
              ? Image.asset(imgPath, width: 40, height: 40)
              : Icon(icon, size: 40,
                  color: selectedIndex == index
                      ? Colors.black
                      : Colors.grey),
          title: Text(label,
              style: TextStyle(
                  color: selectedIndex == index
                      ? Colors.black
                      : Colors.grey,
                  fontWeight: FontWeight.w500)),
          subtitle: Text(subtitle,
              style: TextStyle(
                  color: selectedIndex == index
                      ? Colors.black54
                      : Colors.grey)),
        ),
      ),
    );
  }
}