// import 'package:admin/models/enums.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import '../../controllers/orders_controller.dart';
// import '../../constants.dart';
// import '../../models/order.dart';
// import '../../theme/glass_style.dart';

// class OrderDetailsScreen extends StatelessWidget {
//   final String orderId;
//   final OrdersController controller = Get.find<OrdersController>();

//   OrderDetailsScreen({required this.orderId}) {
//     controller.fetchOrderDetails(orderId);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Détails de la commande'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: () => controller.fetchOrderDetails(orderId),
//           ),
//         ],
//       ),
//       body: Obx(() {
//         if (controller.isLoading.value) {
//           return Center(child: CircularProgressIndicator());
//         }

//         final order = controller.selectedOrder.value;
//         if (order == null) {
//           return Center(
//             child: Text(
//               'Commande non trouvée',
//               style: AppTextStyles.bodyMedium
//                   .copyWith(color: AppColors.textSecondary),
//             ),
//           );
//         }

//         return SingleChildScrollView(
//           padding: EdgeInsets.all(AppSpacing.md),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildOrderHeader(order),
//               SizedBox(height: AppSpacing.md),
//               _buildCustomerInfo(order),
//               SizedBox(height: AppSpacing.md),
//               _buildOrderItems(order),
//               SizedBox(height: AppSpacing.md),
//               _buildTotalSection(order),
//             ],
//           ),
//         );
//       }),
//     );
//   }

//   Widget _buildOrderHeader(Order order) {
//     return Container(
//       padding: EdgeInsets.all(AppSpacing.md),
//       decoration: GlassStyle.containerDecoration(
//         context: Get.context!,
//         color: AppColors.primary,
//         opacity: 0.1,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Commande #${order.id}',
//                 style: AppTextStyles.h3,
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: _getStatusColor(order.status).withOpacity(0.1),
//                   borderRadius: AppRadius.radiusMD,
//                 ),
//                 child: Text(
//                   _getStatusLabel(order.status),
//                   style: AppTextStyles.bodySmall.copyWith(
//                     color: _getStatusColor(order.status),
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: AppSpacing.sm),
//           Text(
//             'Créée le ${DateFormat('dd/MM/yyyy à HH:mm').format(order.createdAt)}',
//             style: AppTextStyles.bodySmall.copyWith(
//               color: AppColors.textSecondary,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCustomerInfo(Order order) {
//     return Container(
//       padding: EdgeInsets.all(AppSpacing.md),
//       decoration: GlassStyle.containerDecoration(
//         context: Get.context!,
//         opacity: 0.1,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Informations client', style: AppTextStyles.h4),
//           SizedBox(height: AppSpacing.sm),
//           _buildInfoRow('Nom', order.customerName ?? 'N/A'),
//           _buildInfoRow('Email', order.customerEmail ?? 'N/A'),
//           _buildInfoRow('Téléphone', order.customerPhone ?? 'N/A'),
//           if (order.deliveryAddress != null) ...[
//             SizedBox(height: AppSpacing.sm),
//             Text('Adresse de livraison', style: AppTextStyles.bodyBold),
//             SizedBox(height: 4),
//             Text(
//               order.deliveryAddress!,
//               style: AppTextStyles.bodyMedium,
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildOrderItems(Order order) {
//     final currencyFormat = NumberFormat.currency(
//       locale: 'fr_FR',
//       symbol: 'FCFA',
//       decimalDigits: 0,
//     );

//     return Container(
//       padding: EdgeInsets.all(AppSpacing.md),
//       decoration: GlassStyle.containerDecoration(
//         context: Get.context!,
//         opacity: 0.1,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Articles', style: AppTextStyles.h4),
//           SizedBox(height: AppSpacing.sm),
//           if (order.items?.isEmpty ?? true)
//             Text(
//               'Aucun article',
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//             )
//           else
//             ListView.separated(
//               shrinkWrap: true,
//               physics: NeverScrollableScrollPhysics(),
//               itemCount: order.items!.length,
//               separatorBuilder: (_, __) => Divider(),
//               itemBuilder: (context, index) {
//                 final item = order.items![index];
//                 return Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             item.name,
//                             style: AppTextStyles.bodyMedium,
//                           ),
//                           Text(
//                             '${item.quantity}x @ ${currencyFormat.format(item.unitPrice)}',
//                             style: AppTextStyles.bodySmall.copyWith(
//                               color: AppColors.textSecondary,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Text(
//                       currencyFormat.format(item.total),
//                       style: AppTextStyles.bodyMedium.copyWith(
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 );
//               },
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTotalSection(Order order) {
//     final currencyFormat = NumberFormat.currency(
//       locale: 'fr_FR',
//       symbol: 'FCFA',
//       decimalDigits: 0,
//     );

//     return Container(
//       padding: EdgeInsets.all(AppSpacing.md),
//       decoration: GlassStyle.containerDecoration(
//         context: Get.context!,
//         color: AppColors.success,
//         opacity: 0.1,
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('Total', style: AppTextStyles.h4),
//               Text(
//                 currencyFormat.format(order.totalAmount),
//                 style: AppTextStyles.h4.copyWith(
//                   color: AppColors.success,
//                 ),
//               ),
//             ],
//           ),
//           if (order.paymentMethod != null) ...[
//             SizedBox(height: AppSpacing.sm),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Mode de paiement',
//                   style: AppTextStyles.bodyMedium,
//                 ),
//                 Text(
//                   _getPaymentMethodLabel(order.paymentMethod),
//                   style: AppTextStyles.bodyMedium.copyWith(
//                     color: AppColors.textSecondary,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 4),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               label,
//               style: AppTextStyles.bodyMedium.copyWith(
//                 color: AppColors.textSecondary,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: AppTextStyles.bodyMedium,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Color _getStatusColor(String status) {
//     switch (status.toUpperCase()) {
//       case 'PENDING':
//         return AppColors.warning;
//       case 'PROCESSING':
//         return AppColors.primary;
//       case 'DELIVERED':
//         return AppColors.success;
//       case 'CANCELLED':
//         return AppColors.error;
//       default:
//         return AppColors.gray400;
//     }
//   }

//   String _getStatusLabel(String status) {
//     switch (status.toUpperCase()) {
//       case 'PENDING':
//         return 'En attente';
//       case 'PROCESSING':
//         return 'En traitement';
//       case 'DELIVERED':
//         return 'Livré';
//       case 'CANCELLED':
//         return 'Annulé';
//       default:
//         return 'Inconnu';
//     }
//   }

//   // Modifier cette méthode pour accepter PaymentMethod au lieu de String
//   String _getPaymentMethodLabel(PaymentMethod method) {
//     switch (method) {
//       case PaymentMethod.CASH:
//         return 'Espèces';
//       case PaymentMethod.ORANGE_MONEY:
//         return 'Orange Money';
//       default:
//         return method.name;
//     }
//   }
// }
