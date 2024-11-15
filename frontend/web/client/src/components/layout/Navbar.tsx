import { Box, Flex, Button, useColorMode } from '@chakra-ui/react';
import { Link } from 'react-router-dom';

export default function Navbar() {
  const { colorMode, toggleColorMode } = useColorMode();

  return (
    <Box as="nav" bg="brand.primary" color="white" px={4} py={2}>
      <Flex justify="space-between" align="center">
        <Link to="/">Alpha Laundry</Link>
        <Flex gap={4}>
          <Link to="/orders">Orders</Link>
          <Link to="/profile">Profile</Link>
          <Button onClick={toggleColorMode}>
            {colorMode === 'light' ? 'Dark' : 'Light'}
          </Button>
        </Flex>
      </Flex>
    </Box>
  );
}
