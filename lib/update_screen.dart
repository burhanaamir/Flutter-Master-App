import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class UpdateSceen extends StatefulWidget {
  const UpdateSceen({super.key, required this.dataID, required this.dataName, required this.dataImage});

  final String dataID;
  final String dataName;
  final String dataImage;

  @override
  State<UpdateSceen> createState() => _UpdateSceenState();
}

class _UpdateSceenState extends State<UpdateSceen> {

  File? imageFile;
  final TextEditingController userName = TextEditingController();

  bool isLoading = false;

  void imageUpload()async{
    setState(() {
      isLoading != isLoading;
    });
  if(imageFile != null ){
    FirebaseStorage.instance.refFromURL(widget.dataImage).delete();
    UploadTask uploadTask = FirebaseStorage.instance.ref().child("userImage").child(const Uuid().v1()).putFile(imageFile!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String imgUrl = await taskSnapshot.ref.getDownloadURL();
    userData(image: imgUrl);
    Navigator.pop(context);
  }else{
    userData(image: widget.dataImage);
    Navigator.pop(context);
  }
    setState(() {
      isLoading != isLoading;
    });
  }

  void userData({String? image})async{
    FirebaseFirestore.instance.collection("userData").doc(widget.dataID).update({
      "name" : userName.text,
      "image" : image
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("User With Image Added")));
  }

  @override
  void initState() {
    // TODO: implement initState
    userName.text = widget.dataName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Data"),
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
                  image: DecorationImage(image:  NetworkImage(widget.dataImage))
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
            }, child: isLoading == false ? const Text("Update Me") : const CircularProgressIndicator()),

            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
