import 'package:autoshare/Customer/customer_home_page.dart';
import 'package:autoshare/services/api_service.dart';
import 'package:flutter/material.dart';

class Paymentsuccess extends StatefulWidget {
  final String driverName;
  final String vehicalNo;
  final String rideId;

  const Paymentsuccess({
    required this.driverName,
    required this.vehicalNo,
    required this.rideId,
    super.key,
  });

  @override
  PaymentSuccessState createState() => PaymentSuccessState();
}

class PaymentSuccessState extends State<Paymentsuccess> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 128, 0),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 100,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Payment Successful!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: DraggableScrollableSheet(
              initialChildSize: 1,
              minChildSize: 0.1,
              maxChildSize: 1,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(15),
                    ),
                    boxShadow: const [
                      BoxShadow(color: Colors.black, blurRadius: 6),
                    ],
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Center(
                            child: Container(
                              height: 5,
                              width: 40,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Text(
                            'Rate Driver',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Divider(
                            color: Colors.grey,
                          ),
                          Align(
                            alignment: AlignmentGeometry.topLeft,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 60,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.driverName,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        'Normal Auto',
                                      )
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '⭐ 4.8',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        widget.vehicalNo,
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Column(
                            children: [
                              Text(
                                'How is your Driver?',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              Text('Please rate your driver.')
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(5, (n) {
                              return IconButton(
                                icon: Icon(
                                  n < _rating ? Icons.star : Icons.star_border,
                                  color: Colors.amber,
                                  size: 32,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _rating = n + 1;
                                  });
                                },
                              );
                            }),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 254, 187, 38),
                                ),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => CustomerHomePage()),
                                      (Route<dynamic> route) => false);
                                },
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                              SizedBox(
                                width: 50,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Color.fromARGB(255, 254, 187, 38),
                                ),
                                onPressed: _rating == 0
                                  ? null
                                  : () async {
                                      // Save rating to database
                                      try {
                                        await ApiService.submitRating(
                                          rideId: widget.rideId,
                                          rating: _rating,
                                        );
                                      } catch (e) {
                                        // Rating save failed — still navigate home
                                      }

                                      if (!context.mounted) return;
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(builder: (_) => const CustomerHomePage()),
                                        (route) => false,
                                      );
                                    },
                                child: Text(
                                  'Submit',
                                  style: TextStyle(color: Colors.black),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
