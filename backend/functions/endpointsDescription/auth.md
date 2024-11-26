# Authentication Endpoints

This document describes the API endpoints for user authentication and account management.

## User Registration

### Register a New User

**Method:** POST
**Path:** `/auth/register`

**Description:** Creates a new user account with the provided details.

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "********",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+1234567890",
  "role": "CLIENT" // Optional, defaults to CLIENT
}
```

**Response Body:**

```json
{
  "id": "userId",
  "email": "user@example.com",
  "token": "jwtToken"
}
```

### Register as Affiliate

**Method:** POST
**Path:** `/auth/register/affiliate/{code}`

**Description:** Registers a new user account with an affiliate code.

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "********",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+1234567890"
}
```

**Path Parameters:**

* `code`: Affiliate code

**Response Body:**

```json
{
  "id": "userId",
  "email": "user@example.com",
  "token": "jwtToken"
}
```

### Register as Referral

**Method:** POST
**Path:** `/auth/register/referral/{code}`

**Description:** Registers a new user account with a referral code.

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "********",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+1234567890"
}
```

**Path Parameters:**

* `code`: Referral code

**Response Body:**

```json
{
  "id": "userId",
  "email": "user@example.com",
  "token": "jwtToken"
}
```

## Admin-Created Customer Account

**Method:** POST
**Path:** `/auth/admin/create-customer`

**Description:** Creates a new customer account with the provided details as an admin.

**Request Body:**

```json
{
  "email": "user@example.com",
  "password": "********",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+1234567890"
}
```

**Response Body:**

```json
{
  "id": "userId",
  "email": "user@example.com",
  "token": "jwtToken"
}
```

## Email Verification

**Method:** POST
**Path:** `/auth/verify-email`

**Description:** Verifies an email address using a verification token.

**Request Body:**

```json
{
  "token": "verification-token"
}
```

**Response Body:**

```json
{
  "message": "Email verified successfully"
}
```

## Test Email Sending

**Method:** POST
**Path:** `/auth/test-email`

**Description:** Sends a test email to a specified email address.

**Request Body:**

```json
{
  "email": "user@example.com"
}
```

**Response Body:**

```json
{
  "message": "Test email sent successfully"
}
```

## Password Reset

### Request Password Reset

**Method:** POST
**Path:** `/auth/forgot-password`

**Description:** Sends a password reset link to the user's email.

**Request Body:**

```json
{
  "email": "user@example.com"
}
```

**Response Body:**

```json
{
  "message": "Password reset instructions sent to your email"
}
```

### Reset Password

**Method:** POST
**Path:** `/auth/reset-password`

**Description:** Resets a user's password using a reset token.

**Request Body:**

```json
{
  "token": "reset-token",
  "password": "********"
}
```

**Response Body:**

```json
{
  "message": "Password reset successfully"
}
