import 'package:hive/hive.dart';

class OrderItem extends HiveObject {
  String orderId;
  String username;
  int productId;
  String title;
  double price;
  String image;
  int qty;
  int createdAt;

  OrderItem({
    required this.orderId,
    required this.username,
    required this.productId,
    required this.title,
    required this.price,
    required this.image,
    required this.qty,
    required this.createdAt,
  });
}

class OrderItemAdapter extends TypeAdapter<OrderItem> {
  @override
  final int typeId = 2;

  @override
  OrderItem read(BinaryReader reader) {
    final fieldCount = reader.readByte();
    final fields = <int, dynamic>{};

    for (int i = 0; i < fieldCount; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    return OrderItem(
      orderId: fields[0] as String,
      username: fields[1] as String,
      productId: fields[2] as int,
      title: fields[3] as String,
      price: (fields[4] as num).toDouble(),
      image: fields[5] as String,
      qty: fields[6] as int,
      createdAt: fields[7] as int,
    );
  }

  @override
  void write(BinaryWriter writer, OrderItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.orderId)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.productId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.image)
      ..writeByte(6)
      ..write(obj.qty)
      ..writeByte(7)
      ..write(obj.createdAt);
  }
}
