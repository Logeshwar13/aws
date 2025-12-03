# ⚠️ IMPORTANT: Update Firebase Config

You changed your database name to **`aws-pudu`**, but your code still has the old config!

## 🔴 You Need to Provide Your NEW Firebase Config Values

Go to Firebase Console → Project Settings → Your apps → Web app

Copy the config object and provide me:
- `apiKey`
- `authDomain` 
- `projectId` (should be `aws-pudu`)
- `storageBucket`
- `messagingSenderId`
- `appId`

**OR** if the project ID is still the same (`first-aws-de44a`) but just renamed, then I just need to know.

---

## Current Config in Code:
- projectId: `first-aws-de44a`
- authDomain: `first-aws-de44a.firebaseapp.com`
- storageBucket: `first-aws-de44a.firebasestorage.app`

## Expected Config:
- projectId: `aws-pudu` (or different?)
- authDomain: `aws-pudu.firebaseapp.com` (or different?)
- storageBucket: `aws-pudu.firebasestorage.app` (or different?)

---

## Also Check These in Firebase Console:

1. **Firestore Security Rules** - Must be published!
   - Go to: Firestore Database → Rules
   - Copy the rules from `FIRESTORE_SECURITY_RULES.md`
   - Click "Publish"

2. **Storage Security Rules** - Must be published!
   - Go to: Storage → Rules
   - Copy the rules from `STORAGE_SECURITY_RULES.md`
   - Click "Publish"

3. **Admin Document** - Must exist!
   - Go to: Firestore Database
   - Check `admins` collection exists
   - Document ID = Your User UID from Authentication
   - Has `email` field

---

**Provide me the new Firebase config values and I'll update everything!**

