const express= require('express');
const cors= require('cors');
require('dotenv').config();
const mongoose= require('mongoose');

const app= express();

app.use(cors());
app.use(express.json()); 



app.use(require("./middleware/errorHandler"));



/*
[Flutter Client]
|
v
[Express.js REST API] <--> [MongoDB]
| ^
v |
[Socket.IO Server] <--> [Firestore]
| ^
v |
[Firebase Storage] <--------> [Firestore]

- REST API: CRUD, auth, recruiter flow, case management
- Socket.IO: real-time chat, JWT-authenticated
- MongoDB: primary data store (users, cases, applications, analytics)
- Firestore: real-time chat, denormalized fast-access data, media metadata
- Firebase Storage: direct media uploads from Flutter

---

### 2. Folder Structure


Server/
src/
config/ # Env, DB, Firebase, Socket.IO configs
models/ # Mongoose schemas
controllers/ # Route handlers
services/ # Business logic, Firestore, JWT, media
middlewares/ # Auth, validation, error, security
routes/ # Express route definitions
sockets/ # Socket.IO event handlers
utils/ # Helpers (logging, error, etc.)
validators/ # Zod/Joi schemas
jobs/ # Background tasks (sync, cleanup)
app.js # Express app setup
server.js # Entry point (HTTP + Socket.IO)
tests/ # Unit/integration tests
package.json
---

### 3. MongoDB Schema Design

**Collections & Key Fields:**

- `users`
  - _id, email, passwordHash, roles [USER, RECRUITER, ADMIN], profile, createdAt, updatedAt, refreshTokens[]
- `cases`
  - _id, title, description, status [OPEN, IN_PROGRESS, RESOLVED, CLOSED], owner, tags[], metadata, media[], applicants[], assignedRecruiter, createdAt, updatedAt
- `applications`
  - _id, caseId, applicantId, status [PENDING, ACCEPTED, REJECTED], appliedAt, decisionAt
- `messages`
  - _id, caseId, senderId, type [TEXT, MEDIA], content, mediaUrl, createdAt
- `media`
  - _id, url, type [IMAGE, VIDEO], uploaderId, caseId/messageId, metadata, createdAt
- (Optional) `audit_logs`, `analytics`

**References vs Embedding:**
- Reference users/applicants in cases/applications
- Embed tags/metadata in cases
- Reference media in cases/messages

---

### 4. Firestore Data Model

**Collections & Documents:**

- `caseChats/{caseId}/messages/{messageId}`
  - senderId, type, content, mediaUrl, timestamp
- `caseMedia/{caseId}/media/{mediaId}`
  - url, type, uploaderId, metadata, timestamp
- `caseSummaries/{caseId}`
  - denormalized: status, tags, lastMessage, unreadCount, participants
- (Optional) `userPresence/{userId}` for online status

**Usage:**
- Fast chat reads/writes, real-time updates
- Denormalized case summaries for dashboards
- Media metadata for quick access

---

### 5. REST API Endpoints

| Method | Path                        | Purpose                                 |
|--------|-----------------------------|-----------------------------------------|
| POST   | /api/auth/signup            | User registration                       |
| POST   | /api/auth/login             | User login, issue tokens                |
| POST   | /api/auth/logout            | Invalidate refresh token                |
| POST   | /api/auth/refresh           | Rotate/issue new access token           |
| GET    | /api/users/me               | Get current user profile                |
| GET    | /api/cases                  | List/search cases                       |
| POST   | /api/cases                  | Create new case                         |
| GET    | /api/cases/:id              | View case details                       |
| PUT    | /api/cases/:id              | Update case (status, metadata)          |
| GET    | /api/cases/:id/media        | List case media                         |
| GET    | /api/cases/:id/chat         | List case chat messages (history)       |
| POST   | /api/cases/:id/apply        | Apply to work on a case                 |
| GET    | /api/cases/:id/applicants   | List applicants for a case              |
| POST   | /api/applications/:id/accept| Recruiter accepts applicant             |
| POST   | /api/applications/:id/reject| Recruiter rejects applicant             |
| GET    | /api/media/:id              | Get media metadata                      |
| GET    | /api/analytics/cases        | Case analytics (admin)                  |

---

### 6. Socket.IO Events

| Event Name         | Payload                      | Direction      | Purpose                        |
|--------------------|-----------------------------|---------------|--------------------------------|
| connect            | JWT token                   | Client → Server| Authenticate socket            |
| join_case_chat     | {caseId}                    | Client → Server| Join case chat room            |
| leave_case_chat    | {caseId}                    | Client → Server| Leave case chat room           |
| send_message       | {caseId, type, content, mediaUrl} | Client → Server| Send chat message              |
| receive_message    | {message}                   | Server → Client| Broadcast new message          |
| typing             | {caseId, userId}            | Client ↔ Server| Typing indicator               |
| message_history    | {caseId, messages[]}        | Server → Client| Initial chat history           |
| user_presence      | {userId, status}            | Server → Client| Online/offline updates         |
| error              | {code, message}             | Server → Client| Error notification             |

---

### 7. Authentication & Security Strategy

- **JWT Access Token:** Short-lived, signed, sent via Authorization header
- **JWT Refresh Token:** Rotated, stored securely (httpOnly cookie or DB), invalidated on logout
- **Role-Based Access Control:** Middleware checks user roles for protected routes/events
- **Secure Middleware:** Centralized auth, input validation, error handling
- **Security Best Practices:** Helmet, CORS, rate limiting, input validation, logging, monitoring, password hashing (bcrypt), token revocation, audit logs

---

### 8. Data Consistency Strategy (MongoDB & Firestore)

- **Source of Truth:** MongoDB for core entities (users, cases, applications)
- **Denormalization:** Firestore for real-time chat, case summaries, media metadata
- **Sync Mechanisms:**
  - On chat/message creation: Write to Firestore (real-time), batch sync to MongoDB for history/analytics
  - On case/media update: Update MongoDB, propagate summary/media metadata to Firestore
  - Use background jobs for periodic reconciliation (e.g., missed syncs, analytics)
- **Conflict Resolution:** Prefer last-write-wins for chat, explicit status for cases/applications

---

### Further Considerations

1. Should media metadata be stored in both Firestore and MongoDB for redundancy?
2. Consider using Redis for socket scaling (pub/sub) if needed.
3. Plan for future admin features (audit logs, analytics, user management).
*/