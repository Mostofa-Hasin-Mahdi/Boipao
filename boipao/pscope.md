boi pao is a resource sharing mobile app 
The purpose of BoiPao is to create a dedicated mobile platform that connects students
who have completed their SSC and HSC examinations with incoming students who need
study materials, solving the critical problem of educational resource wastage and financial
burden in Bangladesh.
The Users
• Donors: Students who have recently completed SSC or HSC examinations and
want to give away their books, notes, and test papers
• Recipients: Current students preparing for upcoming SSC or HSC examinations
who need study materials
• Viewers: Students browsing materials for future reference

• Administrators: Project team members who verify student identities and moderate content

Core Functions (High Priority):
1. User Registration & Authentication
9

• Sign up using email or phone number
• Login/logout functionality
• Password reset via email
2. Student Verification System
• Upload school/college ID card photo
• OCR text extraction (school name, roll number, class)
• Submit verification request to admin
• Receive approval/rejection notification
• Display verification badge on profile
3. Material Management
• Add new material with photos and description
• Categorize by exam type (SSC/HSC), subject, year, condition
• Set location
• Edit or delete own listings
• Mark materials as claimed/completed
4. Browse and Search
• View all available materials in grid/list layout
• Filter by subject, exam type, college, area
• Search by keyword (title, subject, description)
• Sort by date, popularity
5. Claim System
• Request material from donor
• Donor approves/rejects claim
• Track claim status (pending → approved → completed)
• Rate donor/recipient after completion
6. Real-time Messaging
• Chat between donor and recipient for coordination
• Message history storage
7. Notifications
• Push notification on claim request
• Notification on claim approval/rejection
• New message notifications
• Verification status updates
10

8. User Profile
• View and edit personal information
• View donation history
• View claimed materials history
• Display points and badges
• Show verification status
9. Gamification
• Earn points for each donation (e.g., 10 points per book)
• Earn badges for milestones (First Donation, Generous Donor, Verified Student)
• View leaderboard of top donors
Supporting Functions (Medium Priority):
10. Saved/Favorites - Bookmark interesting materials for later
11. Reporting - Report inappropriate content or users
12. Ratings - Rate donors after successful transfer

Project development phases:

1 UI design and color palette
choices with preliminary landing
page

Initial UI/UX

2 Multiple role test with hardcoded
credentials

Dummy login

3 User profile screens, profile edit-
ing

View and edit user profiles

4 Supabase Setup, Authentication
and Entire backend schema

Database Schema (designing with Row Level Security (RLS) in mind from day one), Working
Signup/Login

5 Listing feature,
add/create/delete/update list-
ings

CRUD Operation for Listing fea-
ture

6 Search, Browse, add to favourites Working filters, search and brows-
ing system

7 OCR verification system, admin
dashboard, approval system, Su-
pabase RLS policies

Student Validation System (on-device ML Kit OCR with secure text upload to Supabase), Ad-
min Panel

8 Claim materials, track claims,
Review the quality of materials

Working material claiming sys-
tem for recipients

9 Chat System Donor-recipient communication
(Leveraging Supabase Real-time subscriptions for instant messaging)

10 Notification tab, embedded
within the app

Working Notification for claim re-
quests

11 Gamification/Rank system for
donors

Working Ranking system for
Donors

12 Testing, bug fixes, documentation Tested APK, final report

---
### Technical & Architecture Recommendations:
* **State Management:** Implement a robust state management solution early on (e.g., Riverpod, Provider, or BLoC) to handle the complex state of multiple user roles, real-time chat updates, and dynamic listing data.
* **UI Architecture:** Implement Neumorphism combined with Glassmorphism for a soft, premium look, utilizing custom `BackdropFilter` elements for the floating bottom navigation bar.