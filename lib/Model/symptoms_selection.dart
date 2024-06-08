import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sklite/ensemble/forest.dart';

import 'package:disease_predictor/auth/login_screen.dart';
import 'symptoms.dart';

class SymptomSelection extends StatefulWidget {
  @override
  _SymptomSelectionState createState() => _SymptomSelectionState();
}

class _SymptomSelectionState extends State<SymptomSelection> {
  String diseaseName = "Some Disease";
  List<int> symptomValues = List.filled(34, 0);
  int prediction = 0;
  // Declare the prediction variable at the class level

  @override
  void initState() {
    super.initState();
  }

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orange.shade600,
        title: Text(
          'Disease Predictor',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _showLogoutConfirmationDialog,
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              "*Select the symptoms that apply.",
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: 34,
                itemBuilder: (context, index) {
                  String symptomDescription = Symptoms().symptoms[index];

                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ListTile(
                      title: Text(
                        symptomDescription,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      leading: Checkbox(
                        value: symptomValues[index] == 1,
                        onChanged: (value) {
                          setState(() {
                            symptomValues[index] = value! ? 1 : 0;
                            print("Updated symptomValues: $symptomValues");
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isLoading
          ? const SizedBox()
          : FloatingActionButton(
        backgroundColor: Colors.orange.shade600,
        onPressed: () async {
          if (!isMinimumSymptomsSelected()) {
            // If the minimum number of symptoms is not selected, show an error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Please select at least 5 symptoms."),
              ),
            );
            return;
          }

          // Proceed with the prediction if the minimum symptoms are selected
          setState(() {
            symptomValues = List.filled(34, 0);
            isLoading = true;
          });

          var params = await loadModel();
          print("Classes: ${params["classes"]}");
          print("Decision Trees: ${params["dtrees"]}");
          try {
            if (params == null) {
              print("Error: Invalid model data.");
              return;
            }
            RandomForestClassifier r =
            RandomForestClassifier.fromMap(params);

            // Prepare the symptom values in a format suitable for the classifier
            List<double> args = [];
            for (int i = 0; i < symptomValues.length; i++) {
              args.add(symptomValues[i].toDouble());
            }
            print("Args: $args");

            prediction = r.predict(args);

            // Perform further actions with the prediction
            // For demonstration purposes, print the prediction
            print("Prediction: $prediction");


            setState(() {
              isLoading = false;

            });

            // Show the prediction dialog
            _showPredictionDialog();
          } catch (e) {
            print("Error: $e");
          }
        },
        child: Icon(
          Icons.upload_file_rounded,
          size: 30,
        ),
      ),
    );
  }

  Future<void> showPredictionToast(int prediction) async {
    // Display the toast message with the predicted value
    String predictionMessage = "Predicted Value: $prediction";
    // Toast.show(
    //   predictionMessage,
    //   duration: 3,
    //   gravity: 0,
    //   backgroundColor: Colors.blue,
    // );
  }

  Future<Map<String, dynamic>> loadModel() async {
    try {
      String jsonString = await rootBundle.loadString("assets/amara.json");
      Map<String, dynamic> modelData = json.decode(jsonString);
      return modelData;
    } catch (e) {
      print("Error loading model data: $e");
      return {};
    }
  }

  Future<void> _showLogoutConfirmationDialog() async {
    // Show a confirmation dialog using the built-in showDialog method.
    // It returns a Future that represents the user's choice (yes or no).
    bool shouldLogout = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Do you really want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginScreen(),
                  ),
                );
              },
              child: Text("Yes"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("No"),
            ),
          ],
        );
      },
    );

    // Handle the user's choice.
    if (shouldLogout == true) {
      // If the user tapped "Yes," navigate to the login page.
      Navigator.pushReplacementNamed(context, '/login'); // Replace '/login' with your login route.
    } else {
      // If the user tapped "No" or closed the dialog, do nothing.
    }
  }

  // Custom function to check if the minimum number of symptoms is selected (5)
  bool isMinimumSymptomsSelected() {
    int selectedCount = symptomValues.where((value) => value == 1).length;
    return selectedCount >= 5;
  }

  void _showPredictionDialog() {
    if(prediction==1){
      diseaseName='Diabities';
    }
    else if(prediction==2){
      diseaseName='Hepatitus';
    }
    else if(prediction==3){
      diseaseName='Dengue';
    }

    else if(prediction==4){
      diseaseName='Pneumonia';
    }
    else{
      diseaseName='unknown';
    }

    // Replace this with the actual disease name based on the prediction
    showDialog(

      context: context,
      builder: (context) {
        return AlertDialog(

          title: Text("Predicted Disease"),
          content: Text("The predicted disease is: $diseaseName"),
          actions: [
            TextButton(
              onPressed: () {
                // Show precautions information (you can replace this with the actual precautions)
                Navigator.pop(context); // Close the AlertDialog
                _showPrecautionsDialog();
              },
              child: Text("Precautions"),
            ),
            TextButton(
              onPressed: () {
                // Show medicines information (you can replace this with the actual medicines)
                Navigator.pop(context); // Close the AlertDialog
                _showMedicinesDialog();
              },
              child: Text("Medicines"),
            ),
          ],
        );
      },
    );
  }

  void _showPrecautionsDialog() {
    // Show precautions information here (you can customize this dialog)
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Precautions"),
          content: Text("Yhn Precautions add kr lena"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the AlertDialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showMedicinesDialog() {
    // Show medicines information here (you can customize this dialog)
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Medicines"),
          content: Text("Yhn Medicines add kr lena"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the AlertDialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

}

class MyColors {
  static const primaryColor = Colors.blue;
  static const accentColor = Colors.blueAccent;
}
