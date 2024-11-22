# Master Super Admin API Documentation

This document outlines the functionalities, APIs, and implementation details related to the Master Super Admin role within the Alpha Laundry Management System.

## Contexts

| Context | Description | File Location |
|---|---|---|
| Admin Management | The master super admin has full control over admin management, including creating, updating, deleting, and viewing all admin profiles, including other super admins. | `backend/src/services/adminService.ts`, `backend/src/models/admin.ts` |
| Security | The master super admin cannot be modified or deleted by other admins, ensuring the highest level of security. | `backend/src/services/adminService.ts`, `backend/src/models/admin.ts` |
| Permissions | The master super admin has all permissions by default and can manage permissions for other roles. | `backend/src/models/permission.ts` |

## APIs

The master super admin has access to all APIs, including those specifically designed for admin management and permission management. Refer to `superAdminAPI.md` for a detailed list of APIs.

## Actions

The master super admin can perform all actions related to admin management and permission management. Refer to `superAdminAPI.md` for a detailed list of actions.

## Roles

- Master Super Admin

## Controls

The master super admin has the highest level of control and can bypass certain restrictions that apply to other admin roles.

## Specific Code Examples

- `backend/src/services/adminService.ts`: Contains logic for creating, updating, and deleting admins, with specific checks for the master super admin role.
- `backend/src/models/admin.ts`: Defines the `Admin` model, including the `isMasterAdmin` flag.
- `backend/src/models/permission.ts`: Defines default permissions for the master super admin role.

## Endpoints

Refer to the APIs section in `superAdminAPI.md` for a list of endpoints and their corresponding HTTP methods.
