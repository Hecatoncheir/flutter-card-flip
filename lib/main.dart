import 'dart:math';
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
  double scrollPercent = 0.0;

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
              child: new CardFlipper(
                  cards: demoCards,
                  onScroll: (double scrollPercent) {
                    setState(() {
                      this.scrollPercent = scrollPercent;
                    });
                  })),

          // Bottom bar
          new BottomBar(
              scrollPercent: this.scrollPercent, cardCount: demoCards.length)
        ],
      ),
    );
  }
}

class CardFlipper extends StatefulWidget {
  final List<CardModel> cards;

  final Function(double scrollPercent) onScroll;

  CardFlipper({this.cards, this.onScroll});

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

          if (widget.onScroll != null) {
            widget.onScroll(scrollPercent);
          }
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

    if (widget.onScroll != null) {
      widget.onScroll(scrollPercent);
    }
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

  Matrix4 _buildCardProjection(double scrollPercent) {
    // Pre-multiplied matrix of a projection matrix and a view matrix.
    //
    // Projection matrix is a simplified perspective matrix
    // http://web.iitd.ac.in/~hegde/cad/lecture/L9_persproj.pdf
    // in the form of
    // [[1.0, 0.0, 0.0, 0.0],
    //  [0.0, 1.0, 0.0, 0.0],
    //  [0.0, 0.0, 1.0, 0.0],
    //  [0.0, 0.0, -perspective, 1.0]]
    //
    // View matrix is a simplified camera view matrix.
    // Basically re-scales to keep object at original size at angle = 0 at
    // any radius in the form of
    // [[1.0, 0.0, 0.0, 0.0],
    //  [0.0, 1.0, 0.0, 0.0],
    //  [0.0, 0.0, 1.0, -radius],
    //  [0.0, 0.0, 0.0, 1.0]]
    final perspective = 0.002;
    final radius = 1.0;
    final angle = scrollPercent * pi / 16;
    final horizontalTranslation = 0.0;
    Matrix4 projection = new Matrix4.identity()
      ..setEntry(0, 0, 1 / radius)
      ..setEntry(1, 1, 1 / radius)
      ..setEntry(3, 2,-perspective * 2)
      ..setEntry(1, 2,  radius)
      ..setEntry(2, 3, -radius)
      ..setEntry(0, 3, radius)
      ..setEntry(3, 3, perspective * radius + 1.0);

    final multiplier = 75.0;

    // Model matrix by first translating the object from the origin of the world
    // by radius in the z axis and then rotating against the world.
    final rotationPointMultiplier = angle > 0.0 ? angle / angle.abs() : 1.0;
    print('Angle: $angle');
    projection *= new Matrix4.translationValues(
            horizontalTranslation + (rotationPointMultiplier * multiplier),
            0.0,
            0.0) *
        new Matrix4.rotationY(angle) *
        new Matrix4.translationValues(0.0, 0.0, radius) *
        new Matrix4.translationValues(
            -rotationPointMultiplier * multiplier, 0.0, 0.0);

    return projection;
  }

  Widget _buildCard(
      CardModel model, int cardIndex, int cardCount, double scrollPercent) {
    final cardScrollPercent = scrollPercent / (1 / cardCount);
    final parallax = scrollPercent - (cardIndex / cardCount);

    return FractionalTranslation(
        translation: new Offset(cardIndex - cardScrollPercent, 0.0),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: new Transform(
              transform: _buildCardProjection(cardScrollPercent - cardIndex),
              child: new Card(model, parallaxPercent: parallax),
            )));
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
            translation: new Offset(parallaxPercent * 2.0, 0.0),
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
                  border: new Border.all(
                      color: Colors.white.withOpacity(0.5), width: 1.0),
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

class BottomBar extends StatelessWidget {
  final int cardCount;
  final double scrollPercent;

  BottomBar({this.cardCount, this.scrollPercent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 15.0),
      child: new Row(
        children: <Widget>[
          new Expanded(
              child: new Center(
            child: new Icon(
              Icons.settings_backup_restore,
              color: Colors.white,
            ),
          )),
          new Expanded(
              child: new Container(
            width: double.infinity,
            height: 5.0,
            child: new ScrollIndicator(
                cardCount: cardCount, scrollPercent: scrollPercent),
          )),
          new Expanded(
              child: new Center(
            child: new Icon(
              Icons.add_a_photo,
              color: Colors.white,
            ),
          ))
        ],
      ),
    );
  }
}

class ScrollIndicator extends StatelessWidget {
  final int cardCount;
  final double scrollPercent;

  ScrollIndicator({this.cardCount, this.scrollPercent});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
        painter: new ScrollIndicatorPainter(
            cardCount: cardCount, scrollPercent: scrollPercent),
        child: new Container());
  }
}

class ScrollIndicatorPainter extends CustomPainter {
  final int cardCount;
  final double scrollPercent;

  final Paint trackPaint;
  final Paint thumbPaint;

  ScrollIndicatorPainter({this.cardCount, this.scrollPercent})
      : trackPaint = new Paint()
          ..color = const Color.fromRGBO(115, 126, 142, 0.5)
          ..style = PaintingStyle.fill,
        thumbPaint = new Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            new Rect.fromLTWH(0.0, 0.0, size.width, size.height),
            topLeft: new Radius.circular(3.0),
            topRight: new Radius.circular(3.0),
            bottomLeft: new Radius.circular(3.0),
            bottomRight: new Radius.circular(3.0)),
        trackPaint);

    final thumbWidth = size.width / cardCount;
    final thumbLeft = scrollPercent * size.width;

    canvas.drawRRect(
        RRect.fromRectAndCorners(
            new Rect.fromLTWH(thumbLeft, 0.0, thumbWidth, size.height),
            topLeft: new Radius.circular(3.0),
            topRight: new Radius.circular(3.0),
            bottomLeft: new Radius.circular(3.0),
            bottomRight: new Radius.circular(3.0)),
        thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
