import 'package:admin/services/order_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OrderService filter contract', () {
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
