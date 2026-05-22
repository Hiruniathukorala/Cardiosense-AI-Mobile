import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;
  final double iconSize;
  final EdgeInsets padding;

  const StatusBadge({
    Key? key,
    required this.status,
    this.fontSize = 11.0,
    this.iconSize = 12.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    IconData icon;

    switch (status) {
      case 'Normal':
        bg = const Color(0xFFD1FAE5);
        text = const Color(0xFF065F46);
        icon = Icons.check_circle_outline;
        break;
      case 'Abnormal':
        bg = const Color(0xFFFEF3C7);
        text = const Color(0xFF92400E);
        icon = Icons.error_outline;
        break;
      case 'Critical':
        bg = const Color(0xFFFEE2E2);
        text = const Color(0xFF991B1B);
        icon = Icons.warning_amber_rounded;
        break;
      case 'Pending':
      default:
        bg = const Color(0xFFF3F4F6);
        text = const Color(0xFF374151);
        icon = Icons.hourglass_empty;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: text, size: iconSize),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              color: text,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
