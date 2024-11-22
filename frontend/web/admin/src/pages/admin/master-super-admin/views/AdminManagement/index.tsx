import { FC, useEffect, useState, useCallback } from 'react';
import {
  Box,
  Typography,
  Button,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  IconButton,
  Chip,
} from '@mui/material';
import { Edit as EditIcon, Delete as DeleteIcon } from '@mui/icons-material';
import adminService, { Admin } from '../../../../../services/admin.service';
import AdminCreateDialog from './components/AdminCreateDialog';
import AdminEditDialog from './components/AdminEditDialog';
import { useSnackbar } from 'notistack';

const AdminManagement: FC = () => {
  const [admins, setAdmins] = useState<Admin[]>([]);
  const [selectedAdmin, setSelectedAdmin] = useState<Admin | null>(null);
  const [isCreateDialogOpen, setIsCreateDialogOpen] = useState(false);
  const [isEditDialogOpen, setIsEditDialogOpen] = useState(false);
  const { enqueueSnackbar } = useSnackbar();

  const loadAdmins = useCallback(async () => {
    try {
      const response = await adminService.getAllAdmins();
      setAdmins(response.data);
    } catch (error) {
      if (error instanceof Error) {
        enqueueSnackbar(error.message, { variant: 'error' });
      } else {
        enqueueSnackbar('Erreur inconnue', { variant: 'error' });
      }
    }
  }, [enqueueSnackbar]);

  useEffect(() => {
    loadAdmins();
  }, [loadAdmins]);

  const handleCreateAdmin = async () => {
    setIsCreateDialogOpen(true);
  };

  const handleEditAdmin = (admin: Admin) => {
    setSelectedAdmin(admin);
    setIsEditDialogOpen(true);
  };

  const handleDeleteAdmin = async (adminId: string) => {
    if (window.confirm('Êtes-vous sûr de vouloir supprimer cet administrateur ?')) {
      try {
        await adminService.deleteAdmin(adminId);
        enqueueSnackbar('Administrateur supprimé avec succès', { variant: 'success' });
        loadAdmins();
      } catch (error) {
        if (error instanceof Error) {
          enqueueSnackbar(error.message, { variant: 'error' });
        } else {
          enqueueSnackbar('Erreur inconnue', { variant: 'error' });
        }
      }
    }
  };

  const handleToggleStatus = async (adminId: string) => {
    try {
      await adminService.toggleAdminStatus(adminId);
      enqueueSnackbar('Statut mis à jour avec succès', { variant: 'success' });
      loadAdmins();
    } catch (error) {
      if (error instanceof Error) {
        enqueueSnackbar(error.message, { variant: 'error' });
      } else {
        enqueueSnackbar('Erreur inconnue', { variant: 'error' });
      }
    }
  };

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
        <Typography variant="h4">Gestion des Administrateurs</Typography>
        <Button
          variant="contained"
          color="primary"
          onClick={handleCreateAdmin}
        >
          Nouvel Administrateur
        </Button>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Nom d'utilisateur</TableCell>
              <TableCell>Email</TableCell>
              <TableCell>Rôle</TableCell>
              <TableCell>Statut</TableCell>
              <TableCell>Date de création</TableCell>
              <TableCell>Actions</TableCell>
            </TableRow>
          </TableHead>
          <TableBody>
            {admins.map((admin) => (
              <TableRow key={admin.id}>
                <TableCell>{admin.username}</TableCell>
                <TableCell>{admin.email}</TableCell>
                <TableCell>{admin.role}</TableCell>
                <TableCell>
                  <Chip
                    label={admin.status === 'active' ? 'Actif' : 'Inactif'}
                    color={admin.status === 'active' ? 'success' : 'error'}
                    onClick={() => handleToggleStatus(admin.id)}
                  />
                </TableCell>
                <TableCell>
                  {new Date(admin.createdAt).toLocaleDateString()}
                </TableCell>
                <TableCell>
                  <IconButton
                    color="primary"
                    onClick={() => handleEditAdmin(admin)}
                  >
                    <EditIcon />
                  </IconButton>
                  <IconButton
                    color="error"
                    onClick={() => handleDeleteAdmin(admin.id)}
                  >
                    <DeleteIcon />
                  </IconButton>
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      <AdminCreateDialog
        open={isCreateDialogOpen}
        onClose={() => setIsCreateDialogOpen(false)}
        onSuccess={() => {
          setIsCreateDialogOpen(false);
          loadAdmins();
        }}
      />

      <AdminEditDialog
        open={isEditDialogOpen}
        admin={selectedAdmin}
        onClose={() => {
          setIsEditDialogOpen(false);
          setSelectedAdmin(null);
        }}
        onSuccess={() => {
          setIsEditDialogOpen(false);
          setSelectedAdmin(null);
          loadAdmins();
        }}
      />
    </Box>
  );
};

export default AdminManagement;
