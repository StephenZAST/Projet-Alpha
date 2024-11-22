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
  InputAdornment,
  IconButton,
} from '@mui/material';
import { Link, useNavigate, useParams } from 'react-router-dom';
import { useForm } from 'react-hook-form';
import * as yup from 'yup';
import { yupResolver } from '@hookform/resolvers/yup';
import { Visibility, VisibilityOff } from '@mui/icons-material';
import authService from '../../services/auth.service';
import { AxiosError } from 'axios';

interface ApiErrorResponse {
  message: string;
  statusCode?: number;
}

// Schéma de validation
const schema = yup.object().shape({
  password: yup
    .string()
    .min(8, 'Le mot de passe doit contenir au moins 8 caractères')
    .matches(
      /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[a-zA-Z\d]{8,}$/,
      'Le mot de passe doit contenir au moins une majuscule, une minuscule et un chiffre'
    )
    .required('Le mot de passe est requis'),
  confirmPassword: yup
    .string()
    .oneOf([yup.ref('password')], 'Les mots de passe ne correspondent pas')
    .required('La confirmation du mot de passe est requise'),
});

interface ResetPasswordForm {
  password: string;
  confirmPassword: string;
}

const ResetPassword: React.FC = () => {
  const { token } = useParams<{ token: string }>();
  const navigate = useNavigate();
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [success, setSuccess] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  const {
    register,
    handleSubmit,
    formState: { errors },
  } = useForm<ResetPasswordForm>({
    resolver: yupResolver(schema),
  });

  const onSubmit = async (data: ResetPasswordForm) => {
    if (!token) {
      setError('Token de réinitialisation invalide');
      return;
    }

    try {
      setIsSubmitting(true);
      setError(null);
      
      // Appel au service d'authentification
      await authService.resetPassword(token, data.password);
      
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

  const handleClickShowPassword = () => {
    setShowPassword(!showPassword);
  };

  const handleClickShowConfirmPassword = () => {
    setShowConfirmPassword(!showConfirmPassword);
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
            Réinitialisation du mot de passe
          </Typography>

          {success ? (
            <Alert severity="success" sx={{ width: '100%', mb: 2 }}>
              <AlertTitle>Mot de passe réinitialisé</AlertTitle>
              Votre mot de passe a été réinitialisé avec succès.
              Vous allez être redirigé vers la page de connexion...
            </Alert>
          ) : (
            <Typography variant="body2" color="text.secondary" align="center" sx={{ mb: 3 }}>
              Entrez votre nouveau mot de passe.
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
              type={showPassword ? 'text' : 'password'}
              id="password"
              label="Nouveau mot de passe"
              {...register('password')}
              error={!!errors.password}
              helperText={errors.password?.message}
              disabled={isSubmitting || success}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton
                      aria-label="toggle password visibility"
                      onClick={handleClickShowPassword}
                      edge="end"
                    >
                      {showPassword ? <VisibilityOff /> : <Visibility />}
                    </IconButton>
                  </InputAdornment>
                ),
              }}
            />

            <TextField
              margin="normal"
              required
              fullWidth
              type={showConfirmPassword ? 'text' : 'password'}
              id="confirmPassword"
              label="Confirmer le mot de passe"
              {...register('confirmPassword')}
              error={!!errors.confirmPassword}
              helperText={errors.confirmPassword?.message}
              disabled={isSubmitting || success}
              InputProps={{
                endAdornment: (
                  <InputAdornment position="end">
                    <IconButton
                      aria-label="toggle password visibility"
                      onClick={handleClickShowConfirmPassword}
                      edge="end"
                    >
                      {showConfirmPassword ? <VisibilityOff /> : <Visibility />}
                    </IconButton>
                  </InputAdornment>
                ),
              }}
            />

            <Button
              type="submit"
              fullWidth
              variant="contained"
              sx={{ mt: 3, mb: 2 }}
              disabled={isSubmitting || success}
            >
              {isSubmitting ? 'Réinitialisation...' : 'Réinitialiser le mot de passe'}
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

export default ResetPassword;
