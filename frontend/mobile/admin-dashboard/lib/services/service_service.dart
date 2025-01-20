import '../models/service.dart';

class ServiceService {
  static Future<List<Service>> getServices() async {
    // TODO: Implement API call
    return [
      Service(
        id: '1',
        name: 'Service 1',
        basePrice: 50.0,
        description: 'Description of Service 1',
      ),
      // ...other services...
    ];
  }

  static Future<void> createService(Service service) async {
    // TODO: Implement API call
  }
}
