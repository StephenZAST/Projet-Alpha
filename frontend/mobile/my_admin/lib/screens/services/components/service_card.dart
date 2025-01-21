import 'package:flutter/material.dart';
import '../../../constants.dart';
import '../../../models/service.dart';

class ServiceCard extends StatelessWidget {
  final Service service;

  const ServiceCard({Key? key, required this.service}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(defaultPadding),
      child: ListTile(
        title: Text(service.name),
        subtitle: Text(service.description),
        trailing: Text('\$${service.basePrice}'),
        leading: Icon(Icons.cleaning_services),
      ),
    );
  }
}
