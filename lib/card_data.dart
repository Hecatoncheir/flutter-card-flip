final List<CardModel> demoCards = [
  new CardModel(
      backdropAssetPath: "assets/images/card_background_0.jpg",
      address: "10th street",
      minHeightInFeet: 2,
      maxHeightInFeet: 3,
      tempInDegrees: 65.1,
      weatherType: "Mosctly Cloud",
      windSpeedInMph: 11.2,
      cardinalDirection: "ENE"),
  new CardModel(
      backdropAssetPath: "assets/images/card_background_1.jpg",
      address: "10th street",
      minHeightInFeet: 2,
      maxHeightInFeet: 3,
      tempInDegrees: 65.1,
      weatherType: "Mosctly Cloud",
      windSpeedInMph: 11.2,
      cardinalDirection: "ENE"),
  new CardModel(
      backdropAssetPath: "assets/images/card_background_2.jpg",
      address: "10th street",
      minHeightInFeet: 2,
      maxHeightInFeet: 3,
      tempInDegrees: 65.1,
      weatherType: "Mosctly Cloud",
      windSpeedInMph: 11.2,
      cardinalDirection: "ENE"),
];

class CardModel {
  final String backdropAssetPath;
  final String address;
  final int minHeightInFeet;
  final int maxHeightInFeet;
  final double tempInDegrees;
  final String weatherType;
  final double windSpeedInMph;
  final String cardinalDirection;

  CardModel(
      {this.backdropAssetPath,
      this.address,
      this.minHeightInFeet,
      this.maxHeightInFeet,
      this.tempInDegrees,
      this.weatherType,
      this.windSpeedInMph,
      this.cardinalDirection});
}
