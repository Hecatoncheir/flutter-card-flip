import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  runApp(new Main());
}

class Main extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Main page",
      theme: new ThemeData(primaryColor: Colors.pink),
      home: new CardFlipPage(),
    );
  }
}

class CardFlipPage extends StatefulWidget {
  @override
  State createState() => new _CardFlipState();
}

class _CardFlipState extends State<CardFlipPage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.black,
      body: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          // Status bar
          new Container(
            width: double.infinity,
            height: 20.0,
          ),

          // Cards
          new Expanded(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: new Card(),
          )),

          // Bottom bar
          new Container(
            width: double.infinity,
            height: 50.0,
            color: Colors.grey,
          )
        ],
      ),
    );
  }
}

class Card extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new ClipRRect(
          borderRadius: new BorderRadius.circular(10.0),
          child: new Image.asset(
            'assets/images/card_background_0.jpg',
            fit: BoxFit.cover,
          ),
        ),

        // Content
        new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                  padding:
                      const EdgeInsets.only(left: 20.0, top: 30.0, right: 20.0),
                  child: new Text(
                    "10th Street ".toUpperCase(),
                    style: new TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0),
                  )),
              new Expanded(child: new Container()),
              new Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(left: 30.0),
                    child: new Text("2-3",
                        style: new TextStyle(
                            color: Colors.white,
                            fontSize: 140.0,
                            letterSpacing: 1.0)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 30.0),
                    child: new Text(
                      "FT",
                      style: new TextStyle(
                          color: Colors.white,
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Icon(Icons.wb_sunny, color: Colors.white),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: new Text(
                      "64%",
                      style: new TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0),
                    ),
                  )
                ],
              ),
              new Expanded(child: new Container()),
              Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 50.0),
                child: new Container(
                  decoration: new BoxDecoration(
                      borderRadius: new BorderRadius.circular(30.0),
                      border: new Border.all(color: Colors.white, width: 1.5),
                      color: Colors.black.withOpacity(0.3)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 10.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Text(
                          "Mostly Cloud",
                          style: new TextStyle(
                              color: Colors.white,
                              fontSize: 16.0),
                        ),
                        new Padding(
                          padding: new EdgeInsets.only(left: 10.0, right: 10.0),
                          child: new Icon(
                            Icons.wb_sunny,
                            color: Colors.white,
                          ),
                        ),
                        new Text(
                          "11.2 mph ENE",
                          style: new TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ])
      ],
    );
  }
}
