import { FC } from 'react';
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  Button,
  TextField,
  MenuItem,
  Box,
} from '@mui/material';
import { useFormik } from 'formik';
import * as Yup from 'yup';
import { useSnackbar } from 'notistack';
import adminService, { Admin, AdminUpdateInput } from '../../../../../../services/admin.service';

interface Props {
  open: boolean;
  admin: Admin | null;
  onClose: () => void;
  onSuccess: () => void;
}

const validationSchema = Yup.object({
  username: Yup.string()
    .required('Le nom d\'utilisateur est requis')
    .min(3, 'Le nom d\'utilisateur doit contenir au moins 3 caractères'),
  email: Yup.string()
    .email('Email invalide')
    .required('L\'email est requis'),
  role: Yup.string()
    .required('Le rôle est requis'),
});

const roles = [
  { value: 'super_admin', label: 'Super Admin' },
  { value: 'secretary', label: 'Secrétaire' },
  { value: 'delivery', label: 'Livreur' },
];

const AdminEditDialog: FC<Props> = ({ open, admin, onClose, onSuccess }) => {
  const { enqueueSnackbar } = useSnackbar();

  const formik = useFormik<AdminUpdateInput>({
    initialValues: {
      username: admin?.username || '',
      email: admin?.email || '',
      role: admin?.role || '',
    },
    validationSchema,
    onSubmit: async (values) => {
      if (!admin) return;
      
      try {
        await adminService.updateAdmin(admin.id, values);
        enqueueSnackbar('Administrateur mis à jour avec succès', { variant: 'success' });
        onSuccess();
      } catch (error) {
        if (error instanceof Error) {
          enqueueSnackbar(error.message, { variant: 'error' });
        } else {
          enqueueSnackbar('Erreur inconnue', { variant: 'error' });
        }
      }
    },
    enableReinitialize: true,
  });

  return (
    <Dialog open={open} onClose={onClose} maxWidth="sm" fullWidth>
      <form onSubmit={formik.handleSubmit}>
        <DialogTitle>Modifier l'administrateur</DialogTitle>
        <DialogContent>
          <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, mt: 2 }}>
            <TextField
              fullWidth
              name="username"
              label="Nom d'utilisateur"
              value={formik.values.username}
              onChange={formik.handleChange}
              error={formik.touched.username && Boolean(formik.errors.username)}
              helperText={formik.touched.username && formik.errors.username}
            />
            <TextField
              fullWidth
              name="email"
              label="Email"
              type="email"
              value={formik.values.email}
              onChange={formik.handleChange}
              error={formik.touched.email && Boolean(formik.errors.email)}
              helperText={formik.touched.email && formik.errors.email}
            />
            <TextField
              fullWidth
              name="role"
              label="Rôle"
              select
              value={formik.values.role}
              onChange={formik.handleChange}
              error={formik.touched.role && Boolean(formik.errors.role)}
              helperText={formik.touched.role && formik.errors.role}
            >
              {roles.map((role) => (
                <MenuItem key={role.value} value={role.value}>
                  {role.label}
                </MenuItem>
              ))}
            </TextField>
            <TextField
              fullWidth
              name="password"
              label="Nouveau mot de passe (optionnel)"
              type="password"
              value={formik.values.password || ''}
              onChange={formik.handleChange}
            />
          </Box>
        </DialogContent>
        <DialogActions>
          <Button onClick={onClose}>Annuler</Button>
          <Button type="submit" variant="contained" color="primary">
            Mettre à jour
          </Button>
        </DialogActions>
      </form>
    </Dialog>
  );
};

export default AdminEditDialog;
