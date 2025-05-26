# Coffeeist Database Schema

This document defines the database structure for the Coffeeist app using Firebase Firestore.

## Core Entity Collections

### 1. `users` Collection
User profiles and authentication data.

**Document Structure:**
```json
{
  "uid": "string (Firebase Auth UID)",
  "email": "string",
  "displayName": "string",
  "profileImageURL": "string (optional)",
  "bio": "string (optional)",
  "location": "string (optional)",
  "userTypes": ["string"] // ["amateur_barista", "content_creator", etc.]
  "isVerified": "boolean",
  "verificationRequested": "boolean",
  "isPublic": "boolean",
  "joinDate": "timestamp",
  "followersCount": "number",
  "followingCount": "number",
  "preparationsCount": "number"
}
```

**Indexes:**
- `uid` (primary)
- `isPublic` - for public profile discovery

### 2. `coffee_beans` Collection
Standalone coffee products that can be reused across preparations.

**Document Structure:**
```json
{
  "id": "string (UUID)",
  "brand": "string",
  "name": "string",
  "origin": "string",
  "roastLevel": "string",
  "processingMethod": "string (washed, natural, honey, etc.)",
  "tastingNotes": ["string"],
  "roastDate": "timestamp (optional)",
  "price": "number (optional)",
  "imageURL": "string (optional)",
  "averageRating": "number",
  "ratingCount": "number",
  "createdBy": "string (user UID)",
  "createdAt": "timestamp",
  "isVerified": "boolean"
}
```

**Indexes:**
- `brand` + `name` (compound)
- `origin`
- `roastLevel`
- `averageRating` (descending)

### 3. `equipment` Collection
All equipment items (machines, grinders, portafilters, etc.)

**Document Structure:**
```json
{
  "id": "string (UUID)",
  "type": "string (espresso_machine|grinder|portafilter|scale|etc.)",
  "brand": "string",
  "model": "string",
  "specifications": {
    "size": "string (optional)",
    "capacity": "string (optional)",
    "features": ["string"] (optional)
  },
  "imageURL": "string (optional)",
  "category": "string (optional)",
  "averageRating": "number",
  "ratingCount": "number",
  "createdBy": "string (user UID)",
  "createdAt": "timestamp",
  "isVerified": "boolean"
}
```

**Indexes:**
- `type` + `brand` (compound)
- `type` + `averageRating` (compound)

### 4. `brewing_methods` Collection
Different preparation methods (espresso, V60, French press, etc.)

**Document Structure:**
```json
{
  "id": "string (UUID)",
  "name": "string",
  "description": "string",
  "category": "string (espresso|pour_over|immersion|etc.)",
  "defaultParameters": {
    "grindSize": "string (optional)",
    "waterTemp": "number (optional)",
    "brewTime": "string (optional)"
  },
  "imageURL": "string (optional)"
}
```

**Indexes:**
- `category`
- `name`

## User-Specific Collections

### 5. `user_setups` Collection
User's saved equipment configurations.

**Document Structure:**
```json
{
  "id": "string (UUID)",
  "userId": "string (user UID)",
  "name": "string",
  "brewingMethodId": "string (reference to brewing_methods)",
  "equipmentIds": {
    "espressoMachine": "string (equipment ID - optional)",
    "grinder": "string (equipment ID - optional)",
    "portafilter": "string (equipment ID - optional)",
    "scale": "string (equipment ID - optional)"
  },
  "isDefault": "boolean",
  "isPublic": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Indexes:**
- `userId` + `isDefault` (compound)
- `userId` + `createdAt` (compound)

### 6. `user_coffee_inventory` Collection
User's owned coffee beans.

**Document Structure:**
```json
{
  "id": "string (UUID)",
  "userId": "string (user UID)",
  "coffeeBeanId": "string (reference to coffee_beans)",
  "purchaseDate": "timestamp",
  "quantity": "number (grams)",
  "price": "number (optional)",
  "personalRating": "number (1-10 - optional)",
  "personalNotes": "string (optional)",
  "isFinished": "boolean",
  "createdAt": "timestamp"
}
```

**Indexes:**
- `userId` + `isFinished` (compound)
- `userId` + `purchaseDate` (compound)

### 7. `user_coffee_wishlist` Collection
User's desired coffee beans.

**Document Structure:**
```json
{
  "id": "string (UUID)",
  "userId": "string (user UID)",
  "coffeeBeanId": "string (reference to coffee_beans)",
  "priority": "number (1-5)",
  "notes": "string (optional)",
  "createdAt": "timestamp"
}
```

**Indexes:**
- `userId` + `priority` (compound)
- `userId` + `createdAt` (compound)

### 8. `user_equipment_owned` Collection
User's owned equipment.

**Document Structure:**
```json
{
  "id": "string (UUID)",
  "userId": "string (user UID)",
  "equipmentId": "string (reference to equipment)",
  "purchaseDate": "timestamp (optional)",
  "price": "number (optional)",
  "personalRating": "number (1-10 - optional)",
  "personalNotes": "string (optional)",
  "isCurrentlyUsing": "boolean",
  "createdAt": "timestamp"
}
```

**Indexes:**
- `userId` + `isCurrentlyUsing` (compound)
- `userId` + `purchaseDate` (compound)

### 9. `preparations` Collection (Enhanced)
Individual brewing sessions with references to normalized data.

**Document Structure:**
```json
{
  "id": "string (UUID)",
  "userId": "string (user UID)",
  "setupId": "string (reference to user_setups - optional)",
  "coffeeBeanId": "string (reference to coffee_beans)",
  "brewingMethodId": "string (reference to brewing_methods)",
  "date": "timestamp",
  
  // Measurements
  "measurements": {
    "grindSize": "string",
    "grindingTime": "string",
    "groundCoffeeWeight": "string",
    "preInfusionTime": "string",
    "extractionTime": "string",
    "yieldWeight": "string",
    "waterTemperature": "string (optional)",
    "pressure": "string (optional)"
  },
  
  // Results & Characteristics
  "preparationRating": "number (1-10)", // How good was this specific preparation
  "coffeeBeanRating": "number (1-10)", // How good is this coffee bean
  "characteristics": {
    "bitterness": "number (1-10)",
    "acidity": "number (1-10)",
    "sweetness": "number (1-10)",
    "body": "number (1-10)",
    "crema": "number (1-10)",
    "aroma": "number (1-10)",
    "aftertaste": "number (1-10)"
  },
  "notes": "string",
  
  // Media & Privacy
  "imageURL": "string (Firebase Storage URL - optional)",
  "isPublic": "boolean",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Indexes:**
- `userId` + `date` (compound, descending)
- `coffeeBeanId` + `date` (compound)
- `isPublic` + `date` (compound) - for public feed

## Community Collections

### 10. `follows` Collection
User follow relationships.

**Document Structure:**
```json
{
  "id": "string (UUID)",
  "follower": "string (user UID)",
  "following": "string (user UID)",
  "createdAt": "timestamp"
}
```

**Indexes:**
- `follower` + `createdAt` (compound)
- `following` + `createdAt` (compound)

### 11. `clubs` Collection
Coffee communities/clubs.

**Document Structure:**
```json
{
  "id": "string (UUID)",
  "name": "string",
  "description": "string",
  "location": "string (optional)",
  "createdBy": "string (user UID)",
  "createdAt": "timestamp",
  "memberCount": "number",
  "isPublic": "boolean",
  "imageURL": "string (optional)"
}
```

### 12. `brand_pages` Collection
Official brand presence.

**Document Structure:**
```json
{
  "id": "string (UUID)",
  "name": "string",
  "description": "string",
  "website": "string (optional)",
  "logoURL": "string (optional)",
  "location": "string (optional)",
  "ownerId": "string (user UID)",
  "isVerified": "boolean",
  "followersCount": "number",
  "createdAt": "timestamp"
}
```

## Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // User profiles
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      allow read: if request.auth != null && resource.data.isPublic == true;
    }
    
    // Core entity collections (read-only for users, write via admin/server)
    match /coffee_beans/{document} {
      allow read: if request.auth != null;
      allow create: if request.auth != null; // Users can add new coffee beans
      allow update: if request.auth != null && resource.data.createdBy == request.auth.uid;
    }
    
    match /equipment/{document} {
      allow read: if request.auth != null;
      allow create: if request.auth != null; // Users can add new equipment
      allow update: if request.auth != null && resource.data.createdBy == request.auth.uid;
    }
    
    match /brewing_methods/{document} {
      allow read: if request.auth != null;
      allow write: if false; // Admin-only
    }
    
    // User-specific collections
    match /user_setups/{document} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow read: if request.auth != null && resource.data.isPublic == true;
    }
    
    match /user_coffee_inventory/{document} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }
    
    match /user_coffee_wishlist/{document} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }
    
    match /user_equipment_owned/{document} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
    }
    
    // Preparations
    match /preparations/{document} {
      allow read, write: if request.auth != null && resource.data.userId == request.auth.uid;
      allow read: if request.auth != null && resource.data.isPublic == true;
    }
    
    // Community features
    match /follows/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (resource.data.follower == request.auth.uid || 
         resource.data.following == request.auth.uid);
    }
    
    match /clubs/{document} {
      allow read: if request.auth != null && resource.data.isPublic == true;
      allow read, write: if request.auth != null && resource.data.createdBy == request.auth.uid;
    }
    
    match /brand_pages/{document} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && resource.data.ownerId == request.auth.uid;
    }
  }
}
```

## Implementation Status

### ✅ Currently Implemented (Legacy)
- Basic `preparations` collection (needs migration)
- Basic `equipment` collection (needs restructuring)
- Image storage with Firebase Storage

### 🔄 Phase 1: Core Schema Migration (Current Priority)
1. **User Authentication System**
   - Implement Firebase Auth
   - Create `users` collection
   - Add user profile management

2. **Normalize Core Entities**
   - Create `coffee_beans` collection
   - Restructure `equipment` collection
   - Create `brewing_methods` collection

3. **Migrate Preparations**
   - Update `preparations` to use references
   - Add dual rating system
   - Implement privacy controls

### 🚀 Phase 2: User-Specific Features
1. **User Setups System**
   - Implement `user_setups` collection
   - Setup creation and management UI

2. **Coffee Inventory Management**
   - `user_coffee_inventory` collection
   - `user_coffee_wishlist` collection
   - Coffee tracking features

3. **Equipment Ownership**
   - `user_equipment_owned` collection
   - Equipment management UI

### 🌟 Phase 3: Community Features
1. **Social Features**
   - Follow system (`follows` collection)
   - Public preparation feeds
   - User discovery

2. **Communities**
   - Clubs/groups functionality
   - Brand pages
   - Community-driven content

## Migration Strategy

### Step 1: Preserve Existing Data
- Export current preparations
- Create migration scripts
- Maintain backward compatibility during transition

### Step 2: Implement New Schema
- Deploy new collections alongside existing ones
- Gradually migrate data
- Update app to use new structure

### Step 3: Clean Up
- Remove legacy collections
- Optimize indexes
- Update security rules

## Database Maintenance

### Backup Strategy
- Firebase automatically handles backups
- Consider exporting data periodically for additional safety

### Performance Optimization
- Monitor query performance in Firebase Console
- Add composite indexes as needed for complex queries
- Implement pagination for large datasets

### Data Migration
- Use Firebase Functions for schema updates
- Maintain backward compatibility during transitions 