class PokemonDetail {
  final String name;
  final String weight;
  final String type;
  final String sprite;

  PokemonDetail({
    required this.name,
    required this.weight,
    required this.type,
    required this.sprite,
  });

  factory PokemonDetail.fromJson(Map<String, dynamic> json) {
    final types = json['types'] as List<dynamic>;
    return PokemonDetail(
      name: json['name'] as String,
      weight: json['weight'].toString(),
      type: types.isNotEmpty
          ? types[0]['type']['name'] as String
          : 'Unknown',
      sprite: json['sprites']['front_default']
    );
  }
}
