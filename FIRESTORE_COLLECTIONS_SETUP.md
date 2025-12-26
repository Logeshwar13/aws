# Firestore Collections Setup Guide

This document describes the Firestore collections (equivalent to Supabase tables) that need to be created in your Firebase project.

## Collections Overview

Your app uses the following Firestore collections:

1. **events** - Store event information
2. **members** - Store member information
3. **gallery_items** - Store gallery photos
4. **contacts** - Store contact form submissions
5. **admins** - Store admin user references

## Collection Schemas

### 1. Collection: `events`

Each document contains:
```javascript
{
  id: "string" (auto-generated),
  title: "string",
  description: "string",
  event_date: "string" (ISO8601 format, e.g., "2025-01-15T10:00:00.000Z"),
  location: "string",
  image_url: "string | null",
  registration_link: "string | null",
  is_featured: boolean,
  created_at: "string" (ISO8601 format)
}
```

### 2. Collection: `members`

Each document contains:
```javascript
{
  id: "string" (auto-generated),
  name: "string",
  role: "string",
  email: "string",
  skills: ["string"] (array),
  avatar: "string | null",
  image_url: "string | null",
  bio: "string | null",
  linkedin_url: "string | null",
  github_url: "string | null",
  twitter_url: "string | null",
  website_url: "string | null",
  display_order: number,
  is_active: boolean,
  created_at: "string" (ISO8601 format),
  updated_at: "string | null" (ISO8601 format)
}
```

### 3. Collection: `gallery_items`

Each document contains:
```javascript
{
  id: "string" (auto-generated),
  title: "string",
  description: "string | null",
  image_url: "string",
  month_year: "string" (e.g., "May 2025"),
  created_at: "string" (ISO8601 format),
  updated_at: "string | null" (ISO8601 format),
  display_order: number,
  is_active: boolean
}
```

### 4. Collection: `contacts`

Each document contains:
```javascript
{
  id: "string" (auto-generated),
  name: "string",
  email: "string",
  phone: "string",
  message: "string",
  type: "string" (e.g., "Contact Core Team", "Collaborate", "Want to Speak?"),
  created_at: "string" (ISO8601 format)
}
```

### 5. Collection: `admins`

Each document contains:
```javascript
{
  id: "string" (Firebase Auth UID),
  email: "string",
  created_at: "string" (ISO8601 format) - optional
}
```

## Important Notes

1. **Collections are created automatically**: You don't need to manually create these collections. They will be created automatically when you add the first document.

2. **Indexes may be required**: For queries that order by multiple fields or filter on multiple fields, Firestore may require composite indexes. If you see an error about missing indexes, Firebase Console will provide a link to create them.

3. **Required Indexes**:
   - `gallery_items`: Order by `display_order` (ascending) and `created_at` (descending)
   - If you plan to filter and order, you may need composite indexes

4. **To create indexes**:
   - When you see an error about missing index, click the link in the error message
   - Or go to Firebase Console > Firestore Database > Indexes tab
   - Click "Create Index" if needed

## Setup Steps

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: `first-aws-de44a`
3. Click on "Firestore Database"
4. The collections will be created automatically when you use the app
5. Make sure to set up the Security Rules (see `FIRESTORE_SECURITY_RULES.md`)

## Adding Your First Admin

To add your first admin user:

1. Create an account in your app using Firebase Authentication
2. Note the User UID from Firebase Console > Authentication
3. Go to Firestore Database
4. Start a collection named `admins`
5. Create a document with the Document ID = User UID
6. Add field:
   - `email`: string (your admin email)

Alternatively, you can use the Firebase Console to manually add the admin document after authentication is set up.

