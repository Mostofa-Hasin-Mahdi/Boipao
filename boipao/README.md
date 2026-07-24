# Boipao - Student Academic Material Sharing Platform

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/postgresql-4169e1?style=for-the-badge&logo=postgresql&logoColor=white)

Boipao is a localized, student-centric academic material sharing application. It enables students to easily donate, exchange, and claim educational materials such as books, test papers, and notes within their local communities. To encourage active participation, Boipao incorporates a gamification system where users earn points, badges, and reputation through successful material donations and positive reviews.

## 🚀 Features

* **Authentication & Profiles:** Secure email/password login, customizable profiles, and an Admin verification system for student IDs.
* **Listings & Search:** Browse recent and featured listings, search by title, and filter by subject/condition.
* **Material Claims & Chat:** Request materials from donors and communicate in real-time through an integrated chat system.
* **Real-time Notifications:** Get instantly notified when someone requests your material, accepts your claim, or sends you a message.
* **Gamification:** Earn points for donating materials. Unlock badges (e.g., "First Donation", "Elite Donor") based on your contribution count and points.
* **Reviews & Ratings:** Leave feedback for donors after a successful exchange to build a trustworthy community.
* **Favourites:** Save materials you're interested in for later viewing.

---

## 📂 Project File Structure

```
lib/
├── assets/                  # App images and static assets
├── controllers/             # State management and business logic (Providers)
│   ├── admin_controller.dart
│   ├── auth_controller.dart
│   ├── chat_controller.dart
│   ├── claim_controller.dart
│   ├── main_controller.dart
│   ├── material_controller.dart
│   ├── notification_controller.dart
│   ├── review_controller.dart
│   └── verification_controller.dart
├── core/
│   └── theme/               # Global Neumorphic design system (AppColors)
├── models/                  # Data models mapping to Supabase tables
│   ├── favourite_model.dart
│   ├── material_model.dart
│   ├── message_model.dart
│   ├── notification_model.dart
│   ├── review_model.dart
│   └── user_model.dart
├── views/                   # UI Screens organized by feature
│   ├── admin/               # Admin dashboard for verifying IDs
│   ├── auth/                # Login and Signup views
│   ├── chat/                # Inbox and Chat views
│   ├── home/                # Main home feed
│   ├── listings/            # Creating, editing, and viewing materials
│   ├── main/                # Main scaffold (Navigation bar) & Search
│   ├── notifications/       # Notifications feed
│   └── profile/             # Profile, Badges, Claims, Favourites
└── widgets/                 # Reusable UI components (NeuCards, NavBars, Dialogs)
```

---

## 🔄 Feature Flow Diagrams

### 1. Gamification Flow
```mermaid
sequenceDiagram
    participant Requester
    participant Donor
    participant Database (Supabase)
    
    Requester->>Donor: Claims Material
    Donor->>Database: Approves Claim (status = accepted)
    Requester->>Donor: Meets & receives material
    Donor->>Database: Marks Claim as Completed
    Database-->>Database: Trigger `handle_claim_status_change` runs
    Database-->>Database: Adds 10 points to Donor
    Database-->>Database: Increments Donor's `total_donations` (+1)
    Database-->>Database: Increments Requester's `total_claims` (+1)
    Database-->>Donor: UI updates with new Points & Badges
```

### 2. Chat & Messaging Flow
```mermaid
sequenceDiagram
    participant User A
    participant ChatController
    participant Supabase
    participant User B

    User A->>ChatController: Sends message
    ChatController->>Supabase: Insert into `messages` table
    Supabase-->>ChatController: Message saved
    Supabase-->>Supabase: Database Trigger fires (creates Notification)
    Supabase->>User B: Realtime Event (Postgres changes)
    User B->>ChatController: Subscribed to changes, updates UI
    User B-->>User A: Views message
```

### 3. Notification Flow
```mermaid
sequenceDiagram
    participant Trigger
    participant Notifications Table
    participant NotificationController
    participant App UI

    Trigger->>Notifications Table: Insert new row (e.g. from chat/claim trigger)
    Notifications Table-->>NotificationController: Realtime stream pushes event
    NotificationController->>NotificationController: Adds to local list & increments unreadCount
    NotificationController->>App UI: notifyListeners()
    App UI-->>App UI: Shows red dot on Nav Bar
    App UI->>NotificationController: User taps notification (markAsRead)
    NotificationController->>Notifications Table: Update is_read = true
```

---

## 🗄️ Database Schema

```mermaid
erDiagram
    profiles ||--o{ materials : "creates"
    profiles ||--o{ claims : "makes/receives"
    profiles ||--o{ messages : "sends"
    profiles ||--o{ notifications : "receives"
    profiles ||--o{ reviews : "writes/receives"
    profiles ||--o{ favourites : "saves"

    profiles {
        uuid id PK
        string email
        string display_name
        string location
        string avatar_url
        string role "admin/user"
        boolean is_verified
        string student_id_url
        int points
        int total_donations
        int total_claims
    }

    materials {
        uuid id PK
        uuid donor_id FK
        string title
        string subject
        string location
        string condition
        string status "available/claimed/completed"
        text[] image_urls
    }

    claims {
        uuid id PK
        uuid material_id FK
        uuid requester_id FK
        string status "pending/accepted/rejected/completed"
    }

    messages {
        uuid id PK
        uuid claim_id FK
        uuid sender_id FK
        text content
    }

    notifications {
        uuid id PK
        uuid user_id FK
        string title
        string body
        string type
        uuid reference_id
        boolean is_read
    }

    reviews {
        uuid id PK
        uuid reviewer_id FK
        uuid reviewee_id FK
        uuid claim_id FK
        int rating
        text comment
    }
```

---

## 🛠️ How to Run

### Prerequisites
* Flutter SDK (3.10.4 or higher)
* Dart SDK
* A Supabase project with the correct database schema applied (found in `dbschema.sql`).

### Setup Instructions
1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd boipao
   ```
2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```
3. **Configure Supabase:**
   * Open `lib/main.dart` and locate the `Supabase.initialize` block.
   * Replace the `url` and `anonKey` with your actual Supabase project credentials.
4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE section below for details.

### MIT License

Copyright (c) 2024 Boipao

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
