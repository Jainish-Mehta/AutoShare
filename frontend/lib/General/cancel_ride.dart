import 'package:autoshare/Customer/customer_home_page.dart';
//import 'package:autoshare/maps.dart';
import 'package:flutter/material.dart';

class CancelRide extends StatefulWidget {
  const CancelRide({super.key});
  @override
  State<CancelRide> createState() => CancelRideState();
}

class CancelRideState extends State<CancelRide> {
  bool longWait = false;
  bool contactDriver = false;
  bool destinationDenied = false;
  bool payment = false;
  bool driverConduct = false;
  bool bookMistakenly = false;
  bool safety = false;
  bool changedMind = false;

  final TextEditingController otherController = TextEditingController();

  @override
  void initState() {
    super.initState();
    otherController.addListener(() {
      setState(() {});
    });
  }

  bool get isFormValid {
    return longWait ||
        contactDriver ||
        destinationDenied ||
        payment ||
        driverConduct ||
        bookMistakenly ||
        safety ||
        changedMind ||
        otherController.text.trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cancel Ride")),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please select reason for cancellation'),
                  const SizedBox(height: 5),
                  buildReason('Waiting for long time', longWait, (val) {
                    setState(() => longWait = val ?? false);
                  }),
                  buildReason('Unable to contact driver', contactDriver, (val) {
                    setState(() => contactDriver = val ?? false);
                  }),
                  buildReason(
                      'Driver denied to goto destination', destinationDenied,
                      (val) {
                    setState(() => destinationDenied = val ?? false);
                  }),
                  buildReason('Payment method mismatched', payment, (val) {
                    setState(() => payment = val ?? false);
                  }),
                  buildReason('Driver behavior', driverConduct, (val) {
                    setState(() => driverConduct = val ?? false);
                  }),
                  buildReason('Booked mistakenly', bookMistakenly, (val) {
                    setState(() => bookMistakenly = val ?? false);
                  }),
                  buildReason('Safety concerns', safety, (val) {
                    setState(() => safety = val ?? false);
                  }),
                  buildReason('Changed my mind', changedMind, (val) {
                    setState(() => changedMind = val ?? false);
                  }),
                  const SizedBox(height: 10),
                  const Text(
                    'Other',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextField(
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    controller: otherController,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(255, 255, 250, 250),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 104, 104, 104),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 104, 104, 104),
                        ),
                      ),
                      hintText: 'Other Reason',
                      hintStyle: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.w200),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isFormValid
                    ? () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CustomerHomePage()),
                          (Route<dynamic> route) => false,
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 254, 187, 38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Submit',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildReason(String txt, bool value, ValueChanged<bool?> onChanged) {
    return Card(
      child: CheckboxListTile(
        title: Text(
          txt,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: const Color.fromARGB(255, 254, 187, 38),
        checkColor: Colors.white,
        side: const BorderSide(
          color: Color.fromARGB(255, 254, 187, 38),
          width: 2,
        ),
      ),
    );
  }
}
