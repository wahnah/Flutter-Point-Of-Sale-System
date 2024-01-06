import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tabpos/screens/More.dart';

class PinEntryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PIN Entry'),
        
        backgroundColor: Color.fromARGB(
                          255, 65, 84, 146),
      ),
      body: PasswordView(),
    );
  }
}

class PasswordView extends StatefulWidget {
  @override
  _PasswordViewState createState() => _PasswordViewState();
}

class _PasswordViewState extends State<PasswordView> {
  String enteredPin = '';

  @override
  void initState() {
    super.initState();
    checkAndSetAdminPin(context); // Check if the admin pin is set when the page is opened
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
               SizedBox(
                height: height * 0.07,
              ),
              //Text(
              //  'Verification Code',
              //  style: GoogleFonts.urbanist(
              //    fontWeight: FontWeight.w700,
             //     color: Colors.black,
             //     fontSize: 32.0,
              //  ),
             // ),
              //const SizedBox(
                //height: 8.0,
             // ),
              //RichText(
                //text: TextSpan(
                  //children: [
                    //TextSpan(
                      //text:
                       //   'Please enter the verification code that we have sent to your email ',
                     // style: GoogleFonts.urbanist(
                        //fontSize: 14.0,
                        //color: const Color(0xff808d9e),
                        //fontWeight: FontWeight.w400,
                      //  height: 1.5,
                    //  ),
                    //),
                    //TextSpan(
                      //text: 'abcd@gmail.com ',
                      //style: GoogleFonts.urbanist(
                        //fontSize: 14.0,
                        //color: const Color(0xff005BE0),
                        //fontWeight: FontWeight.w400,
                        //height: 1.5,
                      //),
                    //),
                  //],
                //),
              //),
              //SizedBox(
                //height: height * 0.1,
              //),

              /// pinput package we will use here
              
              Center(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20.0),
    child: SizedBox(
      width: width / 2,
      child: Pinput(
        length: 4,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        onChanged: (value) {
          setState(() {
            enteredPin = value;
          });
        },
        defaultPinTheme: PinTheme(
          height: 60.0,
          width: 60.0,
          textStyle: GoogleFonts.urbanist(
            fontSize: 24.0,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: Colors.black.withOpacity(0.5),
              width: 1.0,
            ),
          ),
        ),
        focusedPinTheme: PinTheme(
          height: 60.0,
          width: 60.0,
          textStyle: GoogleFonts.urbanist(
            fontSize: 24.0,
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: Colors.black,
              width: 1.0,
            ),
          ),
        ),
      ),
    ),
  ),
),

              const SizedBox(
                height: 16.0,
              ),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgotten Pin',
                    style: GoogleFonts.urbanist(
                      fontSize: 14.0,
                      color: Color.fromARGB(
                          255, 65, 84, 146),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              /// Continue Button
              const Expanded(child: SizedBox()),
              
              Center(
  child: InkWell(
    onTap: () {
      comparePinWithFirestore();
    },
    borderRadius: BorderRadius.circular(30.0),
    child: Ink(
      height: 55.0,
      width: width / 3,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: Color.fromARGB(255, 65, 84, 146),
      ),
      child: Center(
        child: Text(
          'Continue',
          style: GoogleFonts.urbanist(
            fontSize: 15.0,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    ),
  ),
),
 const SizedBox(
                height: 355.0,),
              // Your existing widgets ...
            ],
          ),
        ),
      ),
    );
  }

 void comparePinWithFirestore() {
  final CollectionReference adminCollection =
      FirebaseFirestore.instance.collection('admin');
  adminCollection.doc('pin').get().then((DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      String? firestorePin = (snapshot.data() as Map<String, dynamic>?)?['pin'] as String?;
      if (firestorePin == enteredPin) {
        print('Success: PIN matched!');
        Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MoreOptionsListView()),
              );
      } else {
        print('Error: PIN did not match!');
      }
    } else {
      print('Error: Firestore document not found!');
    }
  }).catchError((error) {
    print('Error getting Firestore document: $error');
  });
}



// Function to check if the admin pin is set in the Firestore collection
// 'admin' and open a dialogue to set the pin if it isn't set.
void checkAndSetAdminPin(BuildContext context) async {
  final CollectionReference adminCollection =
      FirebaseFirestore.instance.collection('admin');
   // Retrieve the document from Firestore. We assume the document ID is 'pin'.
  DocumentSnapshot doc = await adminCollection.doc('pin').get();
   // Check if the document exists and contains the 'pin' field.
  if (doc.exists && doc.data() != null && (doc.data() as Map<String, dynamic>)['pin'] != null) {
    // Admin pin is already set, don't open dialogue.
    print('Admin pin is already set.');
  } else {
    // Admin pin is not set, open dialogue to set the pin.
    await showDialog(
      context: context,
      builder: (BuildContext context) => SetAdminPinDialog(),
    );
  }
}
}

// Sample dialogue widget to set the admin pin
class SetAdminPinDialog extends StatefulWidget {
  @override
  _SetAdminPinDialogState createState() => _SetAdminPinDialogState();
}

class _SetAdminPinDialogState extends State<SetAdminPinDialog> {
  String newPin = '';
  String emailAddress = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Set Credentials'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          TextField(
            onChanged: (value) {
              setState(() {
                emailAddress = value;
              });
            },
            decoration: InputDecoration(labelText: 'Enter email address'),
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 10),
          TextField(
            onChanged: (value) {
              setState(() {
                newPin = value;
              });
            },
            decoration: InputDecoration(labelText: 'Enter new admin pin'),
            keyboardType: TextInputType.number,
          ),
          
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            // Save the new pin to Firestore collection 'admin'.
            final CollectionReference adminCollection =
                FirebaseFirestore.instance.collection('admin');
            adminCollection.doc('pin').set({
              'pin': newPin,
              'email': emailAddress,
            }).then((value) {
              print('Admin pin set successfully: $newPin');
              print('Email address set successfully: $emailAddress');
            }).catchError((error) {
              print('Error setting admin pin: $error');
            });
            Navigator.of(context).pop();
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}
