import 'package:dmart/dmart.dart';
import 'package:dmart/src/models/request/action_response.dart';
import 'package:dmart/src/models/query/query_request.dart';
import 'package:dmart/src/enums/query_type.dart';

import 'dmart.dart';

/// 1. Define your model for the response body
class Order {
  final String info;
  final String payment;
  final int combinedOrderId;

  Order({required this.info, required this.payment, required this.combinedOrderId});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      info: json['info'] ?? '',
      payment: json['payment'] ?? '',
      combinedOrderId: json['combined_order_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'info': info, 'payment': payment, 'combined_order_id': combinedOrderId};
}

void main() async {
  // 2. Initialize Dmart
  Dmart.init(configuration: const DmartConfig(baseUrl: "https://api.example.com"));

  // 3. Perform a generic query
  // You pass the type [Order] and the [parser] function.
  final response = await Dmart.query<Order>(
    QueryRequest(
      queryType: QueryType.search,
      spaceName: "personal",
      subpath: "people/964788198314/private/orders",
      search: "",
    ),
    parser: (json) => Order.fromJson(json),
  );

  // 4. Access the typed body directly!
  if (response.records != null && response.records!.isNotEmpty) {
    ActionResponseRecord record = response.records!.first;
    if (record.hasAttachment) {
      record.attachmentsUrls(spaceName: "exampleSpaceName");

      record.getAttachementByShortname(shortname: "thumbail", spaceName: "exampleSpaceName");
    }

    Order? firstOrder = record.attributes.payload?.body;

    if (firstOrder != null) {
      print("Order ID: ${firstOrder.combinedOrderId}");
      print("Payment Method: ${firstOrder.payment}");
    }
  }
}
