import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:weigh_in/main.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  TextEditingController controller = TextEditingController();

  void addItem(String value) async {
    if (value.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(widget.title)
          .collection("weight")
          .add({
        "weight": value,
        "date_time": DateTime.now().toString(),
      }).whenComplete(() {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Added!")));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.blue[200],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text(
          "Progress",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextFormField(
              decoration:
                  const InputDecoration(hintText: "So, what's today's score?"),
              keyboardType: TextInputType.number,
              key: widget.key,
              controller: controller,
              onFieldSubmitted: (value) => addItem(value),
            ),
          ),
          ElevatedButton(
            child: const Text("Submit"),
            onPressed: () => addItem(controller.text),
          ),
          const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "Previous Sessions",
                style: TextStyle(fontSize: 20.0),
              )),
          Expanded(
            child: weights(widget.title),
          ),
          ElevatedButton(
              onPressed: () => signOut(context, widget.title),
              child: const Text("Log out?")),
        ],
      ),
    );
  }
}

void signOut(BuildContext context, String id) async {
  // Anonymous sign in will only leave documents that can't be accessed anymore
  // If you choose to go through with Anonymous Auth, Delete the records first
  // A new anonymous id will be given on next sign in

  // await FirebaseFirestore.instance
  //     .collection("Users")
  //     .doc(id)
  //     .delete()
  //     .whenComplete(() {
  FirebaseAuth.instance.signOut().whenComplete(() {
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Signed out!")));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MyHomePage(title: "Login")),
    );
  });
  // });
}

Widget buildPopupDialog(
    BuildContext context, String userId, String id, String value) {
  TextEditingController controllerEdit = TextEditingController();
  return AlertDialog(
    backgroundColor: Colors.blue[200],
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          decoration: InputDecoration(
            hintText: '${value}kgs (Edit this entry)',
          ),
          controller: controllerEdit,
          keyboardType: TextInputType.number,
        ),
      ],
    ),
    actions: <Widget>[
      FlatButton(
        onPressed: () => delete(context, userId, id),
        textColor: Theme.of(context).primaryColor,
        child: const Text('Delete'),
      ),
      FlatButton(
          onPressed: () => update(context, userId, id, controllerEdit.text),
          child: const Text("Edit")),
    ],
  );
}

void delete(BuildContext context, String userId, String id) async {
  await FirebaseFirestore.instance
      .collection("Users")
      .doc(userId)
      .collection("weight")
      .doc(id)
      .delete()
      .whenComplete(() {
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Deleted!")));
  });
}

void update(
    BuildContext context, String userId, String id, String value) async {
  await FirebaseFirestore.instance
      .collection("Users")
      .doc(userId)
      .collection("weight")
      .doc(id)
      .set(
          {"weight": value},
          SetOptions(
            merge: true,
          )).whenComplete(() {
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Updated!")));
  });
}

Widget weights(String id) {
  DateFormat format = DateFormat.yMMMMd('en_US');
  Query firestore = FirebaseFirestore.instance
      .collection('Users')
      .doc(id)
      .collection('weight')
      .orderBy('date_time', descending: true);
  return StreamBuilder(
      stream: firestore.snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.only(bottom: 1.0),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            DateTime date =
                DateTime.parse(snapshot.data!.docs[index]["date_time"]);
            String dt = format.format(date);
            return RaisedButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) => buildPopupDialog(
                          context,
                          id,
                          snapshot.data!.docs[index].id,
                          snapshot.data!.docs[index]['weight']));
                },
                child: Text(
                  "${snapshot.data!.docs[index]["weight"]}kgs on $dt",
                  style: const TextStyle(fontSize: 20.00),
                ));
          },
        );
      });
}
