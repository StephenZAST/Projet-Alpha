import React, { useState } from 'react';
import {
  Box,
  Button,
  Container,
  TextField,
  Typography,
  Paper,
  Alert,
  AlertTitle,
} from '@mui/material';
import { Link, useNavigate } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import authService from '../../services/auth.service';
import { AxiosError } from 'axios';

interface ApiErrorResponse {
  message: string;
  statusCode?: number;
}

// Schéma de validation
const schema = yup.object().shape({
  email: yup
    .string()
    .email('Adresse email invalide')
    .required('L\'email est requis'),
});

interface ForgotPasswordForm {
  email: string;
}

const ForgotPassword: React.FC = () => {
  const navigate = useNavigate();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<ForgotPasswordForm>({
    resolver: yupResolver(schema),
  });

  const onSubmit = async (data: ForgotPasswordForm) => {
    try {
      setIsSubmitting(true);
      setError(null);
      
      // Appel au service d'authentification
      await authService.forgotPassword(data.email);
      
      setSuccess(true);
      setTimeout(() => {
        navigate('/auth/login');
      }, 5000);
    } catch (err) {
      const error = err as AxiosError<ApiErrorResponse>;
      setError(
        error.response?.data?.message ||
        'Une erreur est survenue lors de la réinitialisation du mot de passe'
      );
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <Container component="main" maxWidth="xs">
      <Box
        sx={{
          marginTop: 8,
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
        }}
      >
        <Paper
          elevation={3}
          sx={{
            padding: 4,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            width: '100%',
          }}
        >
          <Typography component="h1" variant="h5" gutterBottom>
            Mot de passe oublié
          </Typography>

          {success ? (
            <Alert severity="success" sx={{ width: '100%', mb: 2 }}>
              <AlertTitle>Email envoyé</AlertTitle>
              Un email de réinitialisation a été envoyé à votre adresse email.
              Vous allez être redirigé vers la page de connexion...
            </Alert>
          ) : (
            <Typography variant="body2" color="text.secondary" align="center" sx={{ mb: 3 }}>
              Entrez votre adresse email pour recevoir un lien de réinitialisation
              de votre mot de passe.
            </Typography>
          )}

          {error && (
            <Alert severity="error" sx={{ width: '100%', mb: 2 }}>
              {error}
            </Alert>
          )}

          <Box
            component="form"
            onSubmit={handleSubmit(onSubmit)}
            sx={{ width: '100%' }}
          >
            <TextField
              margin="normal"
              required
              fullWidth
              id="email"
              label="Adresse email"
              autoComplete="email"
              autoFocus
              {...register('email')}
              error={!!errors.email}
              helperText={errors.email?.message}
              disabled={isSubmitting || success}
            />

            <Button
              type="submit"
              fullWidth
              variant="contained"
              sx={{ mt: 3, mb: 2 }}
              disabled={isSubmitting || success}
            >
              {isSubmitting ? 'Envoi en cours...' : 'Envoyer le lien'}
            </Button>

            <Box sx={{ textAlign: 'center' }}>
              <Link
                to="/auth/login"
                style={{
                  textDecoration: 'none',
                  color: 'inherit',
                }}
              >
                <Typography variant="body2" color="primary">
                  Retour à la connexion
                </Typography>
              </Link>
            </Box>
          </Box>
        </Paper>
      </Box>
    </Container>
  );
};

export default ForgotPassword;
