import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasetts06c1/fetch_data.dart';
import 'package:firebasetts06c1/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
    debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {

  File? imageFile;

  final TextEditingController userName = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    userName.dispose();
  }

  bool isLoading = false;

  void imageUpload()async{
    setState(() {
      isLoading != isLoading;
    });
    UploadTask uploadTask = FirebaseStorage.instance.ref().child("userImage").child(const Uuid().v1()).putFile(imageFile!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String imgUrl = await taskSnapshot.ref.getDownloadURL();
    userData(image: imgUrl);
    setState(() {
      isLoading != isLoading;
    });
  }

  void userData({String? image})async{
    FirebaseFirestore.instance.collection("userData").add({
      "name" : userName.text,
      "image" : image
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User With Image Added")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Picker"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            imageFile != null ? Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  image: DecorationImage(image:  FileImage(imageFile!))
              ),
              ) : Container(
          width: double.infinity,
          height: 100,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              image: const DecorationImage(image:  NetworkImage("data:image/png;base64,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"))
          ),),

            ElevatedButton(onPressed: (){

              showDialog(context: context, builder: (context) {
                return AlertDialog(
                  title: const Text("Choose Image"),
                  content: const SizedBox(
                    height: 100 ,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Camera: App will redirect you to your mobile Camera"),
                        Text("Gallery: App will redirect you to your mobile Gallery"),
                      ],
                    ),
                  ),
                  actions: [
                    ElevatedButton(onPressed: ()async{
                      XFile? pickImage = await ImagePicker().pickImage(source: ImageSource.gallery);

                      if(pickImage != null){
                        File convertedFile = File(pickImage.path);
                        setState(() {
                          imageFile = convertedFile;
                        });
                      }
                      else{
                        if(context.mounted){
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image Not Selected")));
                        }
                      }

                    }, child: const Text("Gallery")),
                    ElevatedButton(onPressed: ()async{
                      XFile? pickImage = await ImagePicker().pickImage(source: ImageSource.camera);

                      if(pickImage != null){
                        File convertedFile = File(pickImage.path);
                        setState(() {
                          imageFile = convertedFile;
                        });
                        Navigator.pop(context);
                      }
                      else{
                        if(context.mounted){
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Image Not Selected")));
                          Navigator.pop(context);
                        }
                      }
                    }, child: const Text("Camera"))
                  ],
                );
              },);


            }, child: const Text("Pick Image")),

            const SizedBox(
              height: 10,
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: TextFormField(
                controller: userName,
                decoration: const InputDecoration(
                  hintText: "Enter Your Name"
                )
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            ElevatedButton(onPressed: (){
              imageUpload();
            }, child: isLoading == false ? const Text("Add Me") : const CircularProgressIndicator()),

            const SizedBox(
              height: 10,
            ),

            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => FetchScreen(),));
            }, child: Text("Load All Data"))
          ],
        ),
      ),
    );
  }
}

