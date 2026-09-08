import 'package:flutter/material.dart';

/// One shelf in Themes.
///
/// [name] is what the reader sees, [query] is what Pexels is actually asked —
/// the two are not the same, because a good shelf name ("Mono") is usually a
/// poor search term.
class Collection {
  const Collection(this.name, this.query, this.tint);

  final String name;
  final String query;

  ///holds the card before its cover lands, and if the network never answers
  final Color tint;
}

/// The shelves, strongest first.
///
/// Chosen by looking at what the library actually returns for each term: every
/// one of these gives pictures a person would set as a wallpaper. The old list
/// carried Funny, Baby, Love, Draw, Food, Music and Game, which return stock
/// portraits of strangers and desk photos — fine pictures, but nobody puts them
/// behind their home screen.
const List<Collection> kCollections = <Collection>[
  Collection('Nature', 'nature landscape', Color(0xFF1E3A2B)),
  Collection('Space', 'space galaxy stars', Color(0xFF161A33)),
  Collection('Dark', 'dark black background', Color(0xFF141416)),
  Collection('Abstract', 'abstract art background', Color(0xFF3A1F3D)),
  Collection('City', 'city night lights', Color(0xFF2A2136)),
  Collection('Minimal', 'minimalist background', Color(0xFF2C2C30)),
  Collection('Mountains', 'mountains landscape', Color(0xFF23303B)),
  Collection('Neon', 'neon lights', Color(0xFF361B36)),
  Collection('Ocean', 'ocean waves', Color(0xFF13303A)),
  Collection('Sunset', 'sunset sky', Color(0xFF40261F)),
  Collection('Cars', 'sports car', Color(0xFF2B1D1D)),
  Collection('Flowers', 'flowers macro', Color(0xFF3A2130)),
  Collection('Architecture', 'architecture building', Color(0xFF242A30)),
  Collection('Animals', 'animal wildlife', Color(0xFF2E2A20)),
  Collection('Texture', 'texture pattern background', Color(0xFF2E2823)),
  Collection('Mono', 'black and white photography', Color(0xFF1B1B1D)),
];
