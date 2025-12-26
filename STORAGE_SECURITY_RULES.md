# Firebase Storage Security Rules

Copy and paste these rules into your Firebase Console > Storage > Rules tab.

## Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user is admin
    function isAdmin() {
      return isAuthenticated() && 
             firestore.get(/databases/(default)/documents/admins/$(request.auth.uid)) != null;
    }
    
    // Event images folder
    match /event-images/{imageId} {
      // Anyone can read images
      allow read: if true;
      // Only admins can write (upload/delete)
      allow write: if isAdmin() && 
                      request.resource.size < 5 * 1024 * 1024 && // 5MB limit
                      request.resource.contentType.matches('image/.*');
    }
    
    // Gallery images folder
    match /gallery-images/{imageId} {
      // Anyone can read images
      allow read: if true;
      // Only admins can write (upload/delete)
      allow write: if isAdmin() && 
                      request.resource.size < 5 * 1024 * 1024 && // 5MB limit
                      request.resource.contentType.matches('image/.*');
    }
    
    // Speaker images folder
    match /speaker-images/{imageId} {
      // Anyone can read images
      allow read: if true;
      // Only admins can write (upload/delete)
      allow write: if isAdmin() && 
                      request.resource.size < 5 * 1024 * 1024 && // 5MB limit
                      request.resource.contentType.matches('image/.*');
    }
  }
}
```

## Setup Instructions

1. Go to Firebase Console: https://console.firebase.google.com/
2. Select your project: `first-aws-de44a`
3. Click on "Storage" in the left sidebar
4. Click on the "Rules" tab
5. Replace the existing rules with the rules above
6. Click "Publish"

## Storage Buckets Setup

The following folders will be created automatically when you upload files:
- `event-images/` - For event banner images
- `gallery-images/` - For gallery item images
- `speaker-images/` - For speaker profile images (if needed)

These folders don't need to be created manually - they will be created when you upload the first file to each folder.

