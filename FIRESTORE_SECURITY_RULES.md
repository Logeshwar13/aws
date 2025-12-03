# Firestore Security Rules

Copy and paste these rules into your Firebase Console > Firestore Database > Rules tab.

## Security Rules

```javascript

rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user is admin
    function isAdmin() {
      return isAuthenticated() && 
             exists(/databases/$(database)/documents/admins/$(request.auth.uid));
    }
    
    // Events collection
    match /events/{eventId} {
      // Anyone can read events (public viewing)
      allow read: if true;
      // Only admins can write
      allow create, update, delete: if isAdmin();
    }
    
    // Members collection
    match /members/{memberId} {
      // Anyone can read members (public viewing)
      allow read: if true;
      // Only admins can write
      allow create, update, delete: if isAdmin();
    }
    
    // Gallery items collection
    match /gallery_items/{itemId} {
      // Anyone can read active gallery items (public viewing)
      allow read: if true;
      // Only admins can write
      allow create, update, delete: if isAdmin();
    }
    
    // Contacts collection
    match /contacts/{contactId} {
      // Anyone can create (submit contact form)
      allow create: if true;
      // Only admins can read
      allow read: if isAdmin();
      // Only admins can delete
      allow delete: if isAdmin();
      // No updates allowed
      allow update: if false;
    }
    
    // Admins collection
    match /admins/{adminId} {
      // Only authenticated admins can read
      allow read: if isAdmin();
      // Only existing admins can create new admins (manual setup required)
      allow create, update, delete: if isAdmin();
    }
  }
}
```

## Setup Instructions

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: `first-aws-de44a`
3. Click on "Firestore Database" in the left sidebar
4. Click on the "Rules" tab
5. Replace the existing rules with the rules above
6. Click "Publish"

## Adding Your First Admin

After setting up authentication and creating your admin user account:

1. Sign in to your app with the admin email/password
2. Go to Firebase Console > Firestore Database
3. Click "Start collection"
4. Collection ID: `admins`
5. Document ID: Use the Firebase Auth UID of your admin user
6. Add a field:
   - Field: `email`
   - Type: `string`
   - Value: Your admin email
7. Click "Save"

Alternatively, you can create the admin document programmatically through the Firebase Console's Firestore console or using a script.

