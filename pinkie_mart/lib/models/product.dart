class Product {
  final int id;
  final String title;
  final String description;
  final String category;
  final double price;
  final double rating;
  final int stock;
  final String brand;
  final List<dynamic> tags;
  final List<dynamic> images;
  final String thumbnail;
  final List<dynamic> reviews;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.price,
    required this.rating,
    required this.stock,
    required this.brand,
    required this.tags,
    required this.images,
    required this.thumbnail,
    required this.reviews,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '-',
      description: json['description'] as String? ?? '-',
      category: json['category'] as String? ?? '-',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int? ?? 0,
      brand: json['brand'] as String? ?? '-',
      tags: json['tags'] as List<dynamic>? ?? [],
      images: json['images'] as List<dynamic>? ?? [],
      thumbnail: json['thumbnail'] as String? ?? '',
      reviews: json['reviews'] as List<dynamic>? ?? [],
    );
  }
}
