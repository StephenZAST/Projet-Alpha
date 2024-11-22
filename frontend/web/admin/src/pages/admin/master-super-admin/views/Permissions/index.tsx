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
import permissionService, { Permission, PermissionCreateInput } from '../../../../../services/permission.service';
import { useSnackbar } from 'notistack';

const Permissions: FC = () => {
  const [permissions, setPermissions] = useState<Permission[]>([]);
  const [openDialog, setOpenDialog] = useState(false);
  const [newPermission, setNewPermission] = useState<PermissionCreateInput>({
    role: '',
    resource: '',
    actions: []
  });
  const { enqueueSnackbar } = useSnackbar();

  const loadPermissions = async () => {
    try {
      const response = await permissionService.getAllPermissions();
      setPermissions(response.data);
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Erreur lors du chargement des permissions';
      enqueueSnackbar(errorMessage, { variant: 'error' });
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
      setNewPermission({ role: '', resource: '', actions: [] });
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Erreur lors de la création de la permission';
      enqueueSnackbar(errorMessage, { variant: 'error' });
    }
  };

  const handleUpdatePermission = async (permissionId: string, role: string) => {
    try {
      const permission = permissions.find(p => p.id === permissionId);
      if (!permission) return;

      const updatedPermission: Partial<PermissionCreateInput> = {
        role: permission.role,
        resource: permission.resource,
        actions: permission.actions.includes(role)
          ? permission.actions.filter(a => a !== role)
          : [...permission.actions, role]
      };

      await permissionService.updatePermission(permissionId, updatedPermission);
      loadPermissions();
    } catch (error: unknown) {
      const errorMessage = error instanceof Error ? error.message : 'Erreur lors de la modification des rôles';
      enqueueSnackbar(errorMessage, { variant: 'error' });
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
              <TableCell>Ressource</TableCell>
              <TableCell>Rôle</TableCell>
              <TableCell>Actions</TableCell>
              {roles.map(role => (
                <TableCell key={role} align="center">{role}</TableCell>
              ))}
            </TableRow>
          </TableHead>
          <TableBody>
            {permissions.map(permission => (
              <TableRow key={permission.id}>
                <TableCell>{permission.resource}</TableCell>
                <TableCell>{permission.role}</TableCell>
                <TableCell>{permission.actions.join(', ')}</TableCell>
                {roles.map(role => (
                  <TableCell key={role} align="center">
                    <Checkbox
                      checked={permission.actions.includes(role)}
                      onChange={() => handleUpdatePermission(permission.id, role)}
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
            label="Ressource"
            fullWidth
            value={newPermission.resource}
            onChange={(e) => setNewPermission({ ...newPermission, resource: e.target.value })}
          />
          <TextField
            margin="dense"
            label="Rôle"
            fullWidth
            value={newPermission.role}
            onChange={(e) => setNewPermission({ ...newPermission, role: e.target.value })}
          />
          <TextField
            margin="dense"
            label="Actions (séparées par des virgules)"
            fullWidth
            multiline
            rows={2}
            value={newPermission.actions.join(', ')}
            onChange={(e) => setNewPermission({ 
              ...newPermission, 
              actions: e.target.value.split(',').map(action => action.trim()).filter(Boolean)
            })}
            helperText="Entrez les actions séparées par des virgules"
          />
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setOpenDialog(false)}>Annuler</Button>
          <Button 
            onClick={handleCreatePermission} 
            variant="contained"
            disabled={!newPermission.resource || !newPermission.role || newPermission.actions.length === 0}
          >
            Créer
          </Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default Permissions;
