import 'package:admin/controllers/orders_controller.dart';
import 'package:admin/models/order_draft.dart';
import 'package:admin/services/order_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderService filter contract', () {
    test(
        'resetOrderStepper returns to the first step and clears the draft state',
        () {
      final controller = OrdersController();

      controller.currentStep.value = 4;
      controller.orderDraft.update((draft) {
        draft?.clientId = 'client-123';
        draft?.addressId = 'address-456';
        draft?.serviceId = 'service-789';
        draft?.items.add(OrderDraftItem(
          articleId: 'article-1',
          quantity: 2,
          isPremium: true,
        ));
      });
      controller.selectedClientId.value = 'client-123';
      controller.selectedAddressId.value = 'address-456';
      controller.selectedServiceId.value = 'service-789';
      controller.selectedItems.add({'articleId': 'article-1', 'quantity': 2});
      controller.selectedArticleDetails.add({'articleId': 'article-1'});

      controller.resetOrderStepper();

      expect(controller.currentStep.value, 0);
      expect(controller.orderDraft.value.clientId, isNull);
      expect(controller.orderDraft.value.addressId, isNull);
      expect(controller.orderDraft.value.serviceId, isNull);
      expect(controller.orderDraft.value.items, isEmpty);
      expect(controller.selectedClientId.value, isNull);
      expect(controller.selectedAddressId.value, isNull);
      expect(controller.selectedServiceId.value, isNull);
      expect(controller.selectedItems, isEmpty);
      expect(controller.selectedArticleDetails, isEmpty);
    });

    test('builds query params using backend contract keys', () {
      final params = OrderService.buildOrdersQueryParams(
        page: 2,
        limit: 25,
        status: 'PENDING',
        serviceTypeId: 'standard',
        paymentMethod: 'CASH',
        startDate: '2025-01-01',
        endDate: '2025-01-31',
        minAmount: '1000',
        maxAmount: '5000',
        isFlashOrder: true,
        searchTerm: 'alpha',
        affiliateCode: 'AFF-1',
        recurrenceType: 'WEEKLY',
        city: 'Ouagadougou',
        postalCode: '11000',
        collectionDateStart: '2025-01-01',
        collectionDateEnd: '2025-01-31',
        deliveryDateStart: '2025-02-01',
        deliveryDateEnd: '2025-02-28',
        isRecurring: true,
        sortField: 'created_at',
        sortOrder: 'desc',
      );

      expect(params['page'], '2');
      expect(params['limit'], '25');
      expect(params['status'], 'PENDING');
      expect(params['serviceTypeId'], 'standard');
      expect(params['paymentMethod'], 'CASH');
      expect(params['startDate'], '2025-01-01');
      expect(params['endDate'], '2025-01-31');
      expect(params['minAmount'], '1000');
      expect(params['maxAmount'], '5000');
      expect(params['isFlashOrder'], 'true');
      expect(params['query'], 'alpha');
      expect(params['affiliateCode'], 'AFF-1');
      expect(params['recurrenceType'], 'WEEKLY');
      expect(params['city'], 'Ouagadougou');
      expect(params['postalCode'], '11000');
      expect(params['collectionDateStart'], '2025-01-01');
      expect(params['collectionDateEnd'], '2025-01-31');
      expect(params['deliveryDateStart'], '2025-02-01');
      expect(params['deliveryDateEnd'], '2025-02-28');
      expect(params['isRecurring'], 'true');
      expect(params['sortField'], 'createdAt');
      expect(params['sortOrder'], 'desc');
      expect(params.containsKey('sort'), isFalse);
    });

    test('normalizes legacy sort field names', () {
      expect(OrderService.normalizeSortField('created_at'), 'createdAt');
      expect(OrderService.normalizeSortField('updated_at'), 'updatedAt');
      expect(OrderService.normalizeSortField('total_amount'), 'totalAmount');
    });

    test('ignores empty filter values', () {
      final params = OrderService.buildOrdersQueryParams(
        status: '',
        serviceTypeId: 'all',
        paymentMethod: 'all',
        searchTerm: '   ',
      );

      expect(params.containsKey('status'), isFalse);
      expect(params.containsKey('serviceTypeId'), isFalse);
      expect(params.containsKey('paymentMethod'), isFalse);
      expect(params.containsKey('query'), isFalse);
    });
  });
}
