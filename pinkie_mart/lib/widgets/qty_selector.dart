import 'package:flutter/material.dart';

class QtySelector extends StatelessWidget {
  final int quantity;
  final int stock;
  final ValueChanged<int> onChanged;

  const QtySelector({
    super.key,
    required this.quantity,
    required this.stock,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final canDecrease = quantity > 1;
    final canIncrease = quantity < stock;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFD2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: canDecrease ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove_rounded),
            color: const Color(0xFFE5738A),
          ),

          Text(
            '$quantity',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A2C2A),
            ),
          ),

          IconButton(
            onPressed: canIncrease ? () => onChanged(quantity + 1) : null,
            icon: const Icon(Icons.add_rounded),
            color: const Color(0xFFE5738A),
          ),
        ],
      ),
    );
  }
}
