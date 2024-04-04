import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FetchScreen extends StatefulWidget {
  const FetchScreen({super.key});

  @override
  State<FetchScreen> createState() => _FetchScreenState();
}

class _FetchScreenState extends State<FetchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection("userData").snapshots(),
          builder: (BuildContext context,  snapshot) {
            if (snapshot.hasData) {

              var dataLength = snapshot.data!.docs.length;
              return dataLength != 0 ? ListView.builder(
                itemCount: dataLength,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage("${snapshot.data!.docs[index]["image"]}"),
                    ),
                    title: Text("${snapshot.data!.docs[index]["name"]}"),
                    trailing: IconButton(onPressed: ()async{
                      await FirebaseFirestore.instance.collection("userData").doc(snapshot.data!.docs[index].id).delete();
                      FirebaseStorage.instance.refFromURL("${snapshot.data!.docs[index]["image"]}").delete();
                    }, icon: Icon(Icons.delete)),
                  );
                },) : Center(child: const Text("Nothing to show"));
            } else if (snapshot.hasError) {
              return const Icon(Icons.error_outline);
            } else if(snapshot.connectionState == ConnectionState.waiting){
              return const CircularProgressIndicator();
            }
            return Container();
          }),
    );
  }
}
