# Order Service

The `OrderService` class provides methods for managing orders.

## Methods

### createOrder

Creates a new order with the provided data.

**Parameters:**

* `orderData`: The data for the new order.

**Returns:**

* The created order.

### createOneClickOrder

Creates a new one-click order for a user with their default address and items.

**Parameters:**

* `userId`: The ID of the user.
* `zoneId`: The ID of the zone.

**Returns:**

* The created order.

### getOrdersByUser

Retrieves a list of orders for a specific user.

**Parameters:**

* `userId`: The ID of the user.
* `options`: Optional filtering options.

**Returns:**

* A list of orders.

### getOrdersByZone

Retrieves a list of orders for a specific zone.

**Parameters:**

* `zoneId`: The ID of the zone.
* `status`: Optional filtering by status.

**Returns:**

* A list of orders.

### updateOrderStatus

Updates the status of an order.

**Parameters:**

* `orderId`: The ID of the order.
* `status`: The new status of the order.
* `deliveryPersonId`: The ID of the delivery person.

**Returns:**

* The updated order.

### getDeliveryRoute

Retrieves the delivery route for a specific delivery person.

**Parameters:**

* `deliveryPersonId`: The ID of the delivery person.

**Returns:**

* The delivery route.

### getOrderStatistics

Calculates order statistics.

**Parameters:**

* `options`: Optional filtering options.

**Returns:**

* The order statistics.

### getOrderById

Retrieves an order by its ID.

**Parameters:**

* `orderId`: The ID of the order.
* `userId`: The ID of the user.

**Returns:**

* The order.

### updateOrder

Updates an order with the provided data.

**Parameters:**

* `orderId`: The ID of the order.
* `userId`: The ID of the user.
* `updates`: The updated data for the order.

**Returns:**

* The updated order.

### cancelOrder

Cancels an order.

**Parameters:**

* `orderId`: The ID of the order.
* `userId`: The ID of the user.

**Returns:**

* The cancelled order.

### getAllOrders

Retrieves a list of all orders.

**Parameters:**

* `options`: Optional filtering options.

**Returns:**

* A list of orders.
