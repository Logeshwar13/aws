# How to Create an Admin User in Firebase

## Step-by-Step Guide

### Method 1: Using Firebase Console (Recommended)

#### Part 1: Create Authentication User

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `first-aws-de44a`
3. Click **"Authentication"** in the left sidebar
4. Click **"Get started"** (if not already enabled)
5. Click on the **"Users"** tab
6. Click **"Add user"** button (top right)
7. Enter:
   - **Email**: Your admin email (e.g., `admin@example.com`)
   - **Password**: Your admin password (min 6 characters)
8. Click **"Add user"**
9. **Important**: Copy the **User UID** - you'll need it for the next step
   - The UID looks like: `abc123xyz789...` (long string)

#### Part 2: Create Admin Document in Firestore

1. Still in Firebase Console, click **"Firestore Database"** in the left sidebar
2. Click **"Start collection"** (if no collections exist) or find the `admins` collection
3. **Collection ID**: `admins`
4. **Document ID**: Paste the **User UID** you copied from Authentication
   - This is important! The Document ID must match the User UID exactly
5. Click **"Next"** to add fields
6. Add the following field:
   - **Field name**: `email`
   - **Type**: `string`
   - **Value**: Your admin email (same as used in Authentication)
7. (Optional) Add another field:
   - **Field name**: `created_at`
   - **Type**: `string` or `timestamp`
   - **Value**: Current date/time (or leave empty)
8. Click **"Save"**

### Method 2: Using Firebase CLI (Advanced)

If you have Firebase CLI installed, you can create a script:

```bash
# Install Firebase CLI (if not installed)
npm install -g firebase-tools

# Login to Firebase
firebase login

# Create user and admin document using Firebase Admin SDK
# (This requires a server-side script)
```

### Method 3: Using Flutter App (After Initial Setup)

Once you have at least one admin, you can add more admins through your app's admin panel.

---

## Verify Admin Setup

1. **Check Authentication**: 
   - Go to Authentication > Users
   - Verify your admin email is listed

2. **Check Firestore**:
   - Go to Firestore Database
   - Open `admins` collection
   - Verify document exists with User UID as Document ID
   - Verify `email` field matches your admin email

3. **Test Login**:
   - Run your Flutter app: `flutter run -d chrome`
   - Try logging in with your admin credentials
   - You should be able to access admin features

---

## Quick Reference

**Firebase Console Links**:
- Authentication: https://console.firebase.google.com/project/first-aws-de44a/authentication/users
- Firestore: https://console.firebase.google.com/project/first-aws-de44a/firestore

**Important Notes**:
- The Firestore document ID **must** match the Authentication User UID
- The `email` field in Firestore should match the Authentication email
- After creating the admin, your app will recognize them as an admin automatically

---

## Troubleshooting

**Problem**: Can't access admin features after login
- **Solution**: Verify the Firestore document ID exactly matches the User UID (case-sensitive)

**Problem**: Security rules blocking access
- **Solution**: Make sure Firestore Security Rules are published (see `FIRESTORE_SECURITY_RULES.md`)

**Problem**: "Missing or insufficient permissions" error
- **Solution**: 
  1. Check that admin document exists in Firestore
  2. Verify document ID = User UID
  3. Verify Security Rules are published

---

**Your Admin User Setup**:
- Email: `[Your admin email]`
- Password: `[Your admin password]`
- User UID: `[Copy from Authentication after creating user]`
- Firestore Document ID: `[Same as User UID]`

