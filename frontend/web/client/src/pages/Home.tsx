import { Box, Grid, Heading } from '@chakra-ui/react';
import ServiceCard from '../components/common/ServiceCard';
import { useArticles } from '../hooks/useArticles';

export default function Home() {
  const { articles, loading } = useArticles();

  return (
    <Box>
      <Heading mb={6}>Our Services</Heading>
      <Grid templateColumns="repeat(auto-fit, minmax(250px, 1fr))" gap={6}>
        {articles.map(article => (
          <ServiceCard key={article.articleId} article={article} />
        ))}
      </Grid>
    </Box>
  );
}
