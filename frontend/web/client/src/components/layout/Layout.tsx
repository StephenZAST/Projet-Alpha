import { Box, Container, Flex } from '@chakra-ui/react';
import Navbar from './Navbar';
import Sidebar from './Sidebar';

export default function Layout({ children }: { children: React.ReactNode }) {
  return (
    <Box minH="100vh">
      <Navbar />
      <Flex>
        <Sidebar />
        <Container maxW="container.xl" py={8}>
          {children}
        </Container>
      </Flex>
    </Box>
  );
}