import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebasetts06c1/update_screen.dart';
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

                  String id = snapshot.data!.docs[index].id;
                  String name = snapshot.data!.docs[index]["name"];
                  String imgUrl = snapshot.data!.docs[index]["image"];

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(imgUrl),
                    ),
                    title: Text(name),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(onPressed: ()async{
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => UpdateSceen(
                                  dataID: id,
                                  dataName: name,
                                  dataImage: imgUrl,
                                ),));
                          }, icon: const Icon(Icons.update)),

                          IconButton(onPressed: ()async{
                            await FirebaseFirestore.instance.collection("userData").doc(snapshot.data!.docs[index].id).delete();
                            FirebaseStorage.instance.refFromURL("${snapshot.data!.docs[index]["image"]}").delete();
                          }, icon: const Icon(Icons.delete)),
                        ],
                      ),
                    )
                  );
                },) : const Center(child: Text("Nothing to show"));
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
