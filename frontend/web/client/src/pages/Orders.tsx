import { Box, Stack, Heading } from '@chakra-ui/react';
import { useOrders } from '../hooks/useOrders';
import OrderCard from '../components/orders/OrderCard';

export default function Orders() {
  const { orders, loading } = useOrders();

  return (
    <Box>
      <Heading mb={6}>My Orders</Heading>
      <Stack spacing={4}>
        {orders.map(order => (
          <OrderCard key={order.orderId} order={order} />
        ))}
      </Stack>
    </Box>
  );
}
