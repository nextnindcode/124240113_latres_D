import 'package:hive/hive.dart';

class CartItem extends HiveObject {
  String username;
  int productId;
  String title;
  double price;
  String image;
  int qty;
  int stock;

  CartItem({
    required this.username,
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.qty,
    required this.stock,
  });
}

class CartItemAdapter extends TypeAdapter<CartItem> {
  @override
  final int typeId = 0;

  @override
  CartItem read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{};

    for (int i = 0; i < fieldCount; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    return CartItem(
      username: fields[0] as String,
      productId: fields[1] as int,
      title: fields[2] as String,
      price: (fields[3] as num).toDouble(),
      image: fields[4] as String,
      qty: fields[5] as int,
      stock: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CartItem obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.qty)
      ..writeByte(6)
      ..write(obj.stock);
  }
}
