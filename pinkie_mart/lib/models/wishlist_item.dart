import 'package:hive/hive.dart';

class WishlistItem extends HiveObject {
  String username;
  int productId;
  String title;
  double price;
  String image;
  String category;

  WishlistItem({
    required this.username,
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.category,
  });
}

class WishlistItemAdapter extends TypeAdapter<WishlistItem> {
  @override
  final int typeId = 1;

  @override
  WishlistItem read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{};

    for (int i = 0; i < fieldCount; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    return WishlistItem(
      username: fields[0] as String,
      productId: fields[1] as int,
      title: fields[2] as String,
      price: (fields[3] as num).toDouble(),
      image: fields[4] as String,
      category: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WishlistItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.price)
      ..writeByte(4)
      ..write(obj.image)
      ..writeByte(5)
      ..write(obj.category);
  }
}
