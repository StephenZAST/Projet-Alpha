import { FC, useEffect, useState } from 'react';
import {
  Box,
  Typography,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Checkbox,
  Button,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
} from '@mui/material';
import { Add as AddIcon } from '@mui/icons-material';
import permissionService from '../../../../../services/permission.service';
import { useSnackbar } from 'notistack';

interface Permission {
  id: string;
  name: string;
  description: string;
  roles: string[];
}

const Permissions: FC = () => {
  const [permissions, setPermissions] = useState<Permission[]>([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [newPermission, setNewPermission] = useState({
    name: '',
    description: '',
  });
  const { enqueueSnackbar } = useSnackbar();

  const loadPermissions = async () => {
    try {
      const response = await permissionService.getAllPermissions();
      setPermissions(response.data);
    } catch (error) {
      enqueueSnackbar('Erreur lors du chargement des permissions', { variant: 'error' });
    }
  };

  useEffect(() => {
    loadPermissions();
  }, []);

  const handleCreatePermission = async () => {
    try {
      await permissionService.createPermission(newPermission);
      enqueueSnackbar('Permission créée avec succès', { variant: 'success' });
      setOpenDialog(false);
      loadPermissions();
      setNewPermission({ name: '', description: '' });
    } catch (error) {
      enqueueSnackbar('Erreur lors de la création de la permission', { variant: 'error' });
    }
  };

  const handleToggleRole = async (permissionId: string, role: string) => {
    try {
      const permission = permissions.find(p => p.id === permissionId);
      if (!permission) return;

      const hasRole = permission.roles.includes(role);
      if (hasRole) {
        await permissionService.removeRoleFromPermission(permissionId, role);
      } else {
        await permissionService.addRoleToPermission(permissionId, role);
      }
      
      loadPermissions();
    } catch (error) {
      enqueueSnackbar('Erreur lors de la modification des rôles', { variant: 'error' });
    }
  };

  const roles = ['SUPER_ADMIN', 'ADMIN', 'MANAGER'];

  return (
    <Box>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', mb: 3 }}>
        <Typography variant="h4">Gestion des Permissions</Typography>
        <Button
          variant="contained"
          startIcon={<AddIcon />}
          onClick={() => setOpenDialog(true)}
        >
          Nouvelle Permission
        </Button>
      </Box>

      <TableContainer component={Paper}>
        <Table>
          <TableHead>
            <TableRow>
              <TableCell>Nom</TableCell>
              <TableCell>Description</TableCell>
              {roles.map(role => (
                <TableCell key={role} align="center">{role}</TableCell>
              ))}
            </TableRow>
          </TableHead>
          <TableBody>
            {permissions.map(permission => (
              <TableRow key={permission.id}>
                <TableCell>{permission.name}</TableCell>
                <TableCell>{permission.description}</TableCell>
                {roles.map(role => (
                  <TableCell key={role} align="center">
                    <Checkbox
                      checked={permission.roles.includes(role)}
                      onChange={() => handleToggleRole(permission.id, role)}
                    />
                  </TableCell>
                ))}
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </TableContainer>

      <Dialog open={openDialog} onClose={() => setOpenDialog(false)}>
        <DialogTitle>Nouvelle Permission</DialogTitle>
        <DialogContent>
          <TextField
            autoFocus
            margin="dense"
            label="Nom"
            fullWidth
            value={newPermission.name}
            onChange={(e) => setNewPermission({ ...newPermission, name: e.target.value })}
          />
          <TextField
            margin="dense"
            label="Description"
            fullWidth
            multiline
            rows={3}
            value={newPermission.description}
            onChange={(e) => setNewPermission({ ...newPermission, description: e.target.value })}
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDialog(false)}>Annuler</Button>
          <Button onClick={handleCreatePermission} variant="contained">
            Créer
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default Permissions;
