import 'package:flutter/material.dart';



class HomeHeader extends StatelessWidget {
  final String heading;
  final VoidCallback? onActionPressed;
  const HomeHeader({
    super.key,
    required this.heading,
    this.onActionPressed,
  });
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return 
    Padding(
      padding:   const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: 
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            heading,
            style: TextStyle(
              color: colors.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onActionPressed !=null) ...{
          TextButton(
              onPressed: onActionPressed,
              child: Text(
                "View All",
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          }
        ],
      ),
    );
  }
}