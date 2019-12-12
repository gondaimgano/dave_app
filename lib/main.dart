import 'dart:math';

import 'package:dave_app/db.dart';
import 'package:dave_app/models/Person.dart';
import 'package:dave_app/network/NetworkUtil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {

  await DatabaseCreator().initDatabase();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  return runApp(MyApp());
}

class RandomColor {
  RandomColor._();
  static  final Random _random = Random();
  static const List<Color> colors = [
    Colors.deepPurple,
    Colors.green,
    Colors.red,
    Colors.yellow,
    Colors.deepOrange
  ];

  static Color generate() => colors[_random.nextInt(4)];
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.blue,
      ),
      home: DaveApp(),
    );
  }
}

class DaveApp extends StatefulWidget {
  @override
  _DaveAppState createState() => _DaveAppState();
}

class _DaveAppState extends State<DaveApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed: () async {
              await DatabaseCreator.unarchivePersons();

              setState(() {

              });

            },
            icon: Icon(Icons.refresh,color: Colors.white,),
          )
        ],
      ),
      body: StreamBuilder(
        stream: NetworkUtil.getAllUsers().asStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData)
            return ListView.separated(
                itemBuilder: (context, idx) => Dismissible(
                      key: UniqueKey(),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (dir) async{
                        if (DismissDirection.startToEnd == dir)
                         {
                           var p=Person(
                             id: snapshot.data[idx].id,
                             username: snapshot.data[idx].username,
                             email: snapshot.data[idx].email,
                             phone: snapshot.data[idx].phone,
                             website: snapshot.data[idx].website,
                             name: snapshot.data[idx].name,

                           );
                           await DatabaseCreator.removePerson(p);
                           setState(() {

                           });

                         }

                      },
                      background: Container(
                        color: Colors.red,
                        child: Icon(
                          Icons.done,
                          color: Colors.white,
                        ),
                      ),
                      //secondaryBackground: Container(color: Colors.red,child: Icon(Icons.cancel,color: Colors.white,),),
                      child: ListTile(
                        leading: Container(
                          width: 50,
                          height: 50,
                          child: Center(
                              child: Text(
                            "${snapshot.data[idx].name.substring(0, 1)}",
                            style: TextStyle(color: Colors.white),
                          )),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: RandomColor.generate(),
                          ),
                        ),
                        title: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text("${snapshot.data[idx].name}"),
                            Text("${snapshot.data[idx].username}"),
                          ],
                        ),
                        subtitle: Text(
                            "${snapshot.data[idx].email} - ${snapshot.data[idx].phone}"),
                        trailing: Icon(Icons.short_text),
                      ),
                    ),
                separatorBuilder: (context, idx) => SizedBox(
                      height: 22,
                    ),
                itemCount: snapshot.data.length);

          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Text(
                "Something went wrong :(",
                style: Theme.of(context).textTheme.headline,
              ),
            );
          }

          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
