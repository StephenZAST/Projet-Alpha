import { FC } from 'react';
import { Box, Typography, Grid, Paper } from '@mui/material';

const Dashboard: FC = () => {
  return (
    <Box>
      <Typography variant="h4" gutterBottom>
        Tableau de Bord
      </Typography>
      <Grid container spacing={3}>
        <Grid item xs={12} md={6} lg={3}>
          <Paper
            sx={{
              p: 2,
              display: 'flex',
              flexDirection: 'column',
              height: 140,
            }}
          >
            <Typography component="h2" variant="h6" color="primary" gutterBottom>
              Administrateurs
            </Typography>
            <Typography component="p" variant="h4">
              0
            </Typography>
          </Paper>
        </Grid>
        {/* Ajoutez d'autres widgets ici */}
      </Grid>
    </Box>
  );
};

export default Dashboard;
