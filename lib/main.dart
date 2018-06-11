import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';

import 'card_data.dart';

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
            child: new CardFlipper(demoCards),
          ),

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

class CardFlipper extends StatefulWidget {
  final List<CardModel> cards;
  CardFlipper(this.cards);

  @override
  _CardFlipperState createState() => _CardFlipperState();
}

class _CardFlipperState extends State<CardFlipper>
    with TickerProviderStateMixin {
  double scrollPercent = 0.0;
  Offset startDrag;
  double startDragPercentScroll;
  double finishScrollStart;
  double finishScrollEnd;
  AnimationController finishScrollController;

  @override
  void initState() {
    super.initState();
    finishScrollController = new AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150))
      ..addListener(() {
        setState(() {
          scrollPercent = ui.lerpDouble(
              finishScrollStart, finishScrollEnd, finishScrollController.value);
        });
      });
  }

  @override
  void dispose() {
    finishScrollController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    startDrag = details.globalPosition;
    startDragPercentScroll = scrollPercent;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final currDrag = details.globalPosition;
    final dragDistance = currDrag.dx - startDrag.dx;
    final singleCardDragPercent = dragDistance / context.size.width;

    final numCards = widget.cards.length;
    setState(() {
      scrollPercent =
          (startDragPercentScroll + (-singleCardDragPercent / numCards))
              .clamp(0.0, 1.0 - (1 / numCards));
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    finishScrollStart = scrollPercent;

    final numCards = widget.cards.length;
    finishScrollEnd = (scrollPercent * numCards).round() / numCards;
    finishScrollController.forward(from: 0.0);

    setState(() {
      startDrag = null;
      startDragPercentScroll = null;
    });
  }

  List<Widget> _buildCards() {
    final cardsCount = widget.cards.length;

    List<Widget> cards = new List<Widget>();

    for (CardModel model in widget.cards) {
      cards.add(_buildCard(
          model, widget.cards.indexOf(model), cardsCount, scrollPercent));
    }

    return cards;

//    return [
//      _buildCard(0, cardsCount, scrollPercent),
//      _buildCard(1, cardsCount, scrollPercent),
//      _buildCard(2, cardsCount, scrollPercent),
//    ];
  }

  Widget _buildCard(
      CardModel model, int cardIndex, int cardCount, double scrollPercent) {
    final cardScrollPercent = scrollPercent / (1 / cardCount);
    final parallax = scrollPercent - (cardIndex / cardCount);

    return FractionalTranslation(
        translation: new Offset(cardIndex - cardScrollPercent, 0.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: new Card(model, parallaxPercent: parallax),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: Stack(
        children: _buildCards(),
      ),
    );
  }
}

class Card extends StatelessWidget {
  final CardModel model;
  final double parallaxPercent;

  Card(this.model, {this.parallaxPercent: 0.0});

  @override
  Widget build(BuildContext context) {
    return new Stack(
      fit: StackFit.expand,
      children: <Widget>[
        new ClipRRect(
          borderRadius: new BorderRadius.circular(10.0),
          child: FractionalTranslation(
            translation: new Offset(parallaxPercent, 0.0),
            child: OverflowBox(
              maxWidth: double.infinity,
              child:
                  new Image.asset(model.backdropAssetPath, fit: BoxFit.cover),
            ),
          ),
        ),

        // Content
        new Column(mainAxisAlignment: MainAxisAlignment.start, children: <
            Widget>[
          Padding(
              padding:
                  const EdgeInsets.only(left: 20.0, top: 30.0, right: 20.0),
              child: new Text(
                model.address,
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
                  border: new Border.all(color: Colors.white.withOpacity(0.5), width: 1.0),
                  color: Colors.black.withOpacity(0.3)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Text(
                      "Mostly Cloud",
                      style: new TextStyle(color: Colors.white, fontSize: 16.0),
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
