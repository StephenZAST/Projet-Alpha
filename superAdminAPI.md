# Super Admin API Documentation

This document outlines the functionalities, APIs, and implementation details related to the Super Admin role within the Alpha Laundry Management System.

## Contexts

| Context | Description | File Location |
|---|---|---|
| Admin Management | Managing other admin users, including creating, updating, deleting, and viewing their profiles. | `backend/src/controllers/adminController.ts`, `backend/src/services/adminService.ts`, `backend/src/models/admin.ts` |
| System Configuration | Configuring various system settings, such as commissions, payment gateways, and security parameters. |  |
| Analytics and Reporting | Accessing and analyzing system data to generate reports and monitor performance. |  |
| Admin Log Management | Viewing, creating, updating, and deleting admin logs to track admin activity and monitor system security. | `backend/src/controllers/adminLogController.ts`, `backend/src/models/adminLog.ts` |
| Permission Management | Managing permissions, including initializing default permissions, retrieving permissions by role, adding permissions, updating permissions, removing permissions, retrieving the role matrix, retrieving resource permissions, retrieving all permissions, retrieving a permission by ID, creating permissions, updating permissions by ID, deleting permissions, retrieving role permissions, assigning permissions to roles, and removing permissions from roles. | `backend/src/controllers/permissionController.ts`, `backend/src/services/permissionService.ts`, `backend/src/models/permission.ts` |


## APIs

### Admin Management

| API | Method | Description | File Location |
|---|---|---|---|
| `/admin/login` | POST | Allows an admin to log in to the system. | `backend/src/controllers/adminController.ts` |
| `/admin` | POST | Creates a new admin user. | `backend/src/controllers/adminController.ts` |
| `/admin/:id` | PUT | Updates an existing admin user. | `backend/src/controllers/adminController.ts` |
| `/admin/:id` | DELETE | Deletes an admin user. | `backend/src/controllers/adminController.ts` |
| `/admin` | GET | Retrieves all admin users. | `backend/src/controllers/adminController.ts` |
| `/admin/:id` | GET | Retrieves an admin user by ID. | `backend/src/controllers/adminController.ts` |
| `/admin/:id/status` | PUT | Toggles the status of an admin user (active/inactive). | `backend/src/controllers/adminController.ts` |
| `/admin/master` | POST | Creates the master super admin account (protected endpoint). | `backend/src/controllers/adminController.ts` |

### Admin Log Management

| API | Method | Description | File Location |
|---|---|---|---|
| `/admin/logs` | GET | Retrieves all admin logs. | `backend/src/controllers/adminLogController.ts` |
| `/admin/logs/:id` | GET | Retrieves an admin log by ID. | `backend/src/controllers/adminLogController.ts` |
| `/admin/logs` | POST | Creates a new admin log. | `backend/src/controllers/adminLogController.ts` |
| `/admin/logs/:id` | PUT | Updates an existing admin log. | `backend/src/controllers/adminLogController.ts` |
| `/admin/logs/:id` | DELETE | Deletes an admin log. | `backend/src/controllers/adminLogController.ts` |
| `/admin/logs/recent` | GET | Retrieves recent admin activity. | `backend/src/controllers/adminLogController.ts` |
| `/admin/logs/:adminId/failed-logins` | GET | Retrieves failed login attempts for a specific admin. | `backend/src/controllers/adminLogController.ts` |

### Permission Management

| API | Method | Description | File Location |
|---|---|---|---|
| `/permissions/initialize` | POST | Initializes default permissions. | `backend/src/controllers/permissionController.ts` |
| `/permissions/role/:role` | GET | Retrieves permissions by role. | `backend/src/controllers/permissionController.ts` |
| `/permissions` | POST | Adds a new permission. | `backend/src/controllers/permissionController.ts` |
| `/permissions/:role/:resource` | PUT | Updates an existing permission. | `backend/src/controllers/permissionController.ts` |
| `/permissions/:role/:resource` | DELETE | Removes a permission. | `backend/src/controllers/permissionController.ts` |
| `/permissions/matrix` | GET | Retrieves the role matrix. | `backend/src/controllers/permissionController.ts` |
| `/permissions/resource/:resource` | GET | Retrieves resource permissions. | `backend/src/controllers/permissionController.ts` |
| `/permissions` | GET | Retrieves all permissions. | `backend/src/controllers/permissionController.ts` |
| `/permissions/:id` | GET | Retrieves a permission by ID. | `backend/src/controllers/permissionController.ts` |
| `/permissions` | POST | Creates a new permission. | `backend/src/controllers/permissionController.ts` |
| `/permissions/:id` | PUT | Updates an existing permission. | `backend/src/controllers/permissionController.ts` |
| `/permissions/:id` | DELETE | Deletes a permission. | `backend/src/controllers/permissionController.ts` |
| `/permissions/role/:roleId` | GET | Retrieves role permissions. | `backend/src/controllers/permissionController.ts` |
| `/permissions/role/:roleId` | POST | Assigns a permission to a role. | `backend/src/controllers/permissionController.ts` |
| `/permissions/role/:roleId/:permissionId` | DELETE | Removes a permission from a role. | `backend/src/controllers/permissionController.ts` |


## Actions

Refer to the APIs section for a list of actions associated with each API endpoint.

## Roles

- Super Admin

## Controls

- Authentication: Only authenticated admins can access the admin management APIs.
- Authorization: Only the super admin can perform certain actions, such as creating and deleting other admins.
- Input Validation: The APIs validate the input data to ensure it meets the required format and constraints.
- Error Handling: The APIs handle errors gracefully and return appropriate error messages.

## Additional Super Admin Connections

- **Super Admin Creation:** Only the master super admin can create other super admins. (`backend/src/services/adminService.ts`)
- **Super Admin Modification:** Only the master super admin can modify other super admins. (`backend/src/services/adminService.ts`)
- **Admin Details Access:** Only super admins can view the details of other admins. (`backend/src/services/adminService.ts`)
- **Master Super Admin Identification:** The `isMasterAdmin` flag in the `Admin` model identifies the master super admin. (`backend/src/models/admin.ts`)

## Endpoints

Refer to the APIs section for a list of endpoints and their corresponding HTTP methods.
