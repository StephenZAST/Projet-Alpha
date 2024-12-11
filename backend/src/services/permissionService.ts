import { createPermission } from './permissionService/createPermission';
import { getPermissions } from './permissionService/getPermissions';
import { getPermissionById } from './permissionService/getPermissionById';
import { updatePermission } from './permissionService/updatePermission';
import { deletePermission } from './permissionService/deletePermission';
import { initializeDefaultPermissions } from './permissionService/initializeDefaultPermissions';
import { getPermissionsByRole } from './permissionService/getPermissionsByRole';
import { addPermission } from './permissionService/addPermission';
import { removePermission } from './permissionService/removePermission';
import { getRoleMatrix } from './permissionService/getRoleMatrix';
import { getResourcePermissions } from './permissionService/getResourcePermissions';

export class PermissionService {
  static createPermission = createPermission;
  static getPermissions = getPermissions;
  static getPermissionById = getPermissionById;
  static updatePermission = updatePermission;
  static deletePermission = deletePermission;
  static initializeDefaultPermissions = initializeDefaultPermissions;
  static getPermissionsByRole = getPermissionsByRole;
  static addPermission = addPermission;
  static removePermission = removePermission;
  static getRoleMatrix = getRoleMatrix;
  static getResourcePermissions = getResourcePermissions;
}
