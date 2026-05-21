import 'package:flutter/material.dart';

import '../common/color_extension.dart';

class PopularRestaurantRow extends StatelessWidget {
  final Map pObj;
  final VoidCallback onTap;

  const PopularRestaurantRow({
    super.key,
    required this.pObj,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String image = pObj["image"]?.toString() ?? "assets/img/offer_1.png";
    final String name = pObj["name"]?.toString() ?? "Nhà hàng";
    final String rate = pObj["rate"]?.toString() ?? "4.5";
    final String rating = pObj["rating"]?.toString() ?? "0";
    final String type = pObj["type"]?.toString() ?? "Cafe";
    final String foodType = pObj["food_type"]?.toString() ?? "Food";

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              image,
              width: double.maxFinite,
              height: 200,
              fit: BoxFit.cover,
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: TColor.primaryText,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 8),

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
                        "($rating Ratings)",
                        style: TextStyle(
                          color: TColor.secondaryText,
                          fontSize: 11,
                        ),
                      ),

                      const SizedBox(width: 8),

                      Flexible(
                        child: Text(
                          type,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: TColor.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                      ),

                      Text(
                        " . ",
                        style: TextStyle(
                          color: TColor.primary,
                          fontSize: 11,
                        ),
                      ),

                      Flexible(
                        child: Text(
                          foodType,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: TColor.secondaryText,
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