# MongoDB Commands Guide

## Option 1: Add User Using Python Script (Recommended)

### Step 1: Install required packages
```bash
pip install motor passlib[bcrypt]
```

### Step 2: Port-forward MongoDB service (if running in K8s)
```bash
kubectl port-forward -n default svc/mongodb-service 27017:27017
```

### Step 3: Run the script
```bash
cd /home/mahme/Lab_Final/DevOps-Lab-Mid
python add_user.py
```

---

## Option 2: Add User Directly via MongoDB Shell

### Step 1: Access MongoDB pod
```bash
# Get MongoDB pod name
kubectl get pods | grep mongodb

# Connect to MongoDB pod
kubectl exec -it mongodb-0 -- mongosh -u admin -p admin123 --authenticationDatabase admin
```

### Step 2: Inside mongosh, run these commands
```javascript
// Switch to your app database
use appdb

// Check existing users
db.User.find().pretty()

// Add the new user (you need to hash the password first)
db.User.insertOne({
  "uuid": UUID(),
  "email": "mahmedraza90@gmail.com",
  "first_name": "Mahmed",
  "last_name": "Raza",
  "hashed_password": "$2b$12$XyZabc123...hash_here",  // Need to generate this
  "provider": null,
  "picture": null,
  "is_active": true,
  "is_superuser": false
})
```

**Note:** Option 2 is harder because you need to manually hash the password using bcrypt.

---

## Commands to View MongoDB Data

### View all users in the database:
```bash
# Connect to MongoDB
kubectl exec -it mongodb-0 -- mongosh -u admin -p admin123 --authenticationDatabase admin

# Inside mongosh
use appdb
db.User.find().pretty()
```

### View specific user by email:
```bash
# Inside mongosh
use appdb
db.User.findOne({"email": "mahmedraza90@gmail.com"})
```

### Count total users:
```bash
# Inside mongosh
use appdb
db.User.countDocuments()
```

### View user without password hash (cleaner output):
```bash
# Inside mongosh
use appdb
db.User.find({}, {hashed_password: 0}).pretty()
```

---

## Quick Verification Commands

### One-liner to check if user exists:
```bash
kubectl exec -it mongodb-0 -- mongosh -u admin -p admin123 --authenticationDatabase admin --eval "db.getSiblingDB('appdb').User.findOne({email: 'mahmedraza90@gmail.com'}, {hashed_password: 0})"
```

### List all databases:
```bash
kubectl exec -it mongodb-0 -- mongosh -u admin -p admin123 --authenticationDatabase admin --eval "show dbs"
```

### List all collections in appdb:
```bash
kubectl exec -it mongodb-0 -- mongosh -u admin -p admin123 --authenticationDatabase admin --eval "db.getSiblingDB('appdb').getCollectionNames()"
```

---

## Troubleshooting

### If MongoDB credentials don't work:
```bash
# Check secrets in Kubernetes
kubectl get secret app-secrets -o jsonpath='{.data.MONGO_USER}' | base64 -d
kubectl get secret app-secrets -o jsonpath='{.data.MONGO_PASSWORD}' | base64 -d
```

### If MongoDB pod is not running:
```bash
kubectl get pods
kubectl logs mongodb-0
```
