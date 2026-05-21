import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class MenuItemRow extends StatelessWidget {
  final Map mObj;
  final VoidCallback onTap;

  const MenuItemRow({
    super.key,
    required this.mObj,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String image = mObj["image"]?.toString() ?? "assets/img/menu_1.png";
    final String name = mObj["name"]?.toString() ?? "Món ăn";
    final String rate = mObj["rate"]?.toString() ?? "4.5";
    final String type = mObj["type"]?.toString() ?? "Food";
    final String foodType = mObj["food_type"]?.toString() ?? "Fast Food";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Image.asset(
              image,
              width: double.maxFinite,
              height: 200,
              fit: BoxFit.cover,
            ),

            Container(
              width: double.maxFinite,
              height: 200,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: TColor.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Row(
                    children: [
                      Image.asset(
                        "assets/img/rate.png",
                        width: 10,
                        height: 10,
                        fit: BoxFit.cover,
                      ),

                      const SizedBox(width: 4),

                      Text(
                        rate,
                        style: TextStyle(
                          color: TColor.primary,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Text(
                        type,
                        style: TextStyle(
                          color: TColor.white,
                          fontSize: 11,
                        ),
                      ),

                      Text(
                        " . ",
                        style: TextStyle(
                          color: TColor.primary,
                          fontSize: 11,
                        ),
                      ),

                      Expanded(
                        child: Text(
                          foodType,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: TColor.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}