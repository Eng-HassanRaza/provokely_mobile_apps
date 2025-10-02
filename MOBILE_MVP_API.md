## Provokely Mobile MVP – Core API Guide (v1)

- **Base URL**: `/api/v1/`
- **Auth**: Token-based. Send header `Authorization: Token <token>`
- **Responses**: JSON, versioned, paginated where applicable
- **Errors**:
```json
{
  "success": false,
  "error": { "code": "ERROR_CODE", "message": "Human readable", "details": {} }
}
```

### 1) Create/Login Account

- Create account (MVP): via web `POST /accounts/signup/` or admin; no mobile signup endpoint in MVP.

- Login
  - POST `/api/v1/auth/login`
  - Body (either username or email + password):
```json
{ "username": "alice", "password": "secret123" }
```
or
```json
{ "email": "alice@example.com", "password": "secret123" }
```
  - Success:
```json
{
  "success": true,
  "data": {
    "token": "abcd1234...",
    "user": { "id": 1, "username": "alice", "email": "alice@example.com", "first_name": "", "last_name": "" }
  },
  "message": "Login successful"
}
```

- Current user
  - GET `/api/v1/auth/me`

### 2) Connect Instagram (Mobile OAuth)

- Get auth URL
  - GET `/api/v1/instagram/accounts/mobile/auth-url`
  - Response:
```json
{
  "success": true,
  "data": { "url": "https://www.facebook.com/v23.0/dialog/oauth?...state=...", "state": "random32chars" },
  "message": "Auth URL generated"
}
```

- Open the `url` in an in-app browser (must match Facebook App settings).

- Callback (server-handled)
  - GET `/api/v1/instagram/mobile/callback/`
  - On success: deep-link `provokely://oauth/instagram?status=success`
  - On error: `provokely://oauth/instagram?status=error&reason=<reason>`

- Connection status
  - GET `/api/v1/instagram/accounts/mobile/status`
  - Response (connected):
```json
{
  "success": true,
  "data": { "connected": true, "ig_user": { "id": "1784...", "username": "brand" } },
  "message": "Status fetched"
}
```

### 3) Settings (Notifications + Auto/Manual Replies)

- Get
  - GET `/api/v1/core/settings/instagram`

- Update
  - PUT `/api/v1/core/settings/instagram`
  - Body (send only fields to change):
```json
{
  "auto_comment_enabled": true,
  "auto_respond_to_positive": true,
  "auto_respond_to_negative": true,
  "auto_respond_to_hate": true,
  "require_approval_for_negative": true,
  "require_approval_for_hate": true,
  "response_style": "controversial",
  "notify_on_positive": false,
  "notify_on_negative": true,
  "notify_on_hate": true,
  "notify_on_neutral": false,
  "notify_on_purchase_intent": true,
  "notify_on_question": true
}
```

- Notes
  - If `auto_comment_enabled` is true and approval is required for a sentiment, replies are generated but held for approval.
  - Notification toggles control which incoming comments create a `Notification` (and trigger push).

### 4) Approve AI Response (when auto-post is off or approval required)

- Find pending approvals
  - Notifications (recommended inbox):
    - GET `/api/v1/core/notifications/?needs_approval=true&is_read=false&page=1&page_size=20`
  - Or comments feed:
    - GET `/api/v1/core/comments/?requires_approval=true&response_posted=false&page=1&page_size=20`

- Approve and post threaded reply (Instagram)
  - POST `/api/v1/core/comments/{id}/approve`
  - Optional body to edit reply:
```json
{ "text": "Edited witty reply in the same language..." }
```
  - Idempotent: if already replied, returns current state.

- Decline (no posting)
  - POST `/api/v1/core/comments/{id}/decline`

### Optional (Push Registration)

- Register device (Android first)
  - POST `/api/v1/core/devices/`
```json
{ "platform": "android", "token": "<FCM_TOKEN>" }
```

- Unregister
  - DELETE `/api/v1/core/devices/{id}`

### Notification Utilities (for inbox UIs)

- List: GET `/api/v1/core/notifications/` with filters `platform`, `is_read`, `sentiment_label`, `needs_approval`, plus `search`, `ordering`, pagination
- Count: GET `/api/v1/core/notifications/count`
- Mark read: PATCH `/api/v1/core/notifications/{id}/mark_read`
- Mark all read: POST `/api/v1/core/notifications/mark_all_read`

### General Conventions

- Pagination: `?page=1&page_size=20`
- Search (where supported): `?search=<text>`
- Ordering (where supported): `?ordering=-created_at`


