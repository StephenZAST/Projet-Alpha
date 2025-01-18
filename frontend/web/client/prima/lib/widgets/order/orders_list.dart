import 'package:flutter/material.dart';
import 'package:prima/models/order.dart';
import 'package:prima/widgets/order/order_card.dart';
import 'package:prima/theme/colors.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class OrdersList extends StatelessWidget {
  final List<Order> orders;
  final ScrollController scrollController;
  final bool isLoading;
  final bool hasMore;

  const OrdersList({
    Key? key,
    required this.orders,
    required this.scrollController,
    required this.isLoading,
    required this.hasMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty && !isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: AppColors.gray400,
            ),
            SizedBox(height: 16),
            Text(
              'Aucune commande trouvée',
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return AnimationLimiter(
      child: ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: orders.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == orders.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            );
          }

          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 375),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: OrderCard(
                  order: orders[index],
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/order-details',
                    arguments: orders[index],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
