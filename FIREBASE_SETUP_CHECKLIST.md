# Firebase Setup Checklist ✅

Use this checklist to ensure your Firebase project is properly configured.

## Firebase Project Setup

- [ ] Firebase project created: `first-aws-de44a`
- [ ] Authentication enabled (Email/Password)
- [ ] Firestore Database created
- [ ] Storage enabled

## Security Rules

- [ ] Firestore Security Rules published (see `FIRESTORE_SECURITY_RULES.md`)
- [ ] Storage Security Rules published (see `STORAGE_SECURITY_RULES.md`)

## Admin Setup

- [ ] Created admin user in Firebase Authentication
- [ ] Created admin document in Firestore `admins` collection
  - Document ID = User UID from Authentication
  - Field: `email` (string)

## Flutter App

- [ ] Dependencies installed: `flutter pub get`
- [ ] App tested locally: `flutter run -d chrome`
- [ ] Authentication works
- [ ] Can create/read events
- [ ] Can create/read members
- [ ] Can create/read gallery items
- [ ] Contact form submits successfully

## Collections (Auto-created)

These will be created automatically when you use the app:
- [ ] `events` collection exists (after first event creation)
- [ ] `members` collection exists (after first member creation)
- [ ] `gallery_items` collection exists (after first gallery item)
- [ ] `contacts` collection exists (after first contact submission)

## Storage Folders (Auto-created)

These will be created automatically when you upload files:
- [ ] `event-images/` folder exists (after first image upload)
- [ ] `gallery-images/` folder exists (after first gallery upload)

## Indexes (If Needed)

Firebase may prompt you to create indexes. Check for:
- [ ] Composite index for `gallery_items` (orderBy display_order, created_at)
- [ ] Any other indexes requested by error messages

## Deployment (Optional)

- [ ] Test build: `flutter build web`
- [ ] Deploy to Vercel (if needed)
- [ ] Environment variables set (if using env vars)

---

## Quick Test Commands

```bash
# Install dependencies
flutter pub get

# Run locally
flutter run -d chrome

# Build for web
flutter build web

# Check for errors
flutter analyze
```

---

## Need Help?

- Firestore Rules: See `FIRESTORE_SECURITY_RULES.md`
- Storage Rules: See `STORAGE_SECURITY_RULES.md`
- Collection Schemas: See `FIRESTORE_COLLECTIONS_SETUP.md`
- Migration Details: See `MIGRATION_COMPLETE.md`

