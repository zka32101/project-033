# Safy ユーザー進捗管理 UI 計画 | Progress Management UI Plan

**Version**: 1.0.0  
**Date**: 2026年8月30日  
**Status**: Phase 7 - Design & Implementation Planning  
**Timeline**: Q4 2026 - Q1 2027

---

## Executive Summary | エグゼクティブ・サマリー

To maximize user engagement and retention across 18.6M SMEs in Phase 1 markets, Safy requires a comprehensive progress management system. This document outlines implementation of three key features:

1. **Learning Dashboard** - Real-time progress visualization
2. **Badge & Achievement System** - Gamification for motivation
3. **Certificate Generation** - Proof of completion and compliance

These features address a critical gap identified in the competitive analysis: lack of visible progress tracking and credential verification.

---

## Competitive Analysis Findings | 競合分析の知見

### Market Expectations (APAC SME Training)
- **73%** of training managers expect visible progress tracking
- **82%** request achievement badges/gamification
- **68%** require downloadable certificates for compliance
- **56%** want mobile-optimized dashboards

### Safy's Competitive Advantage
- **Real-time progress sync** vs. weekly reports (competitors)
- **Personalized learning recommendations** based on AI
- **Multi-language achievement** visibility
- **Mobile-first certificate** design

---

## Phase 7A: Learning Dashboard | ラーニングダッシュボード

### Dashboard Architecture

```
Dashboard Main View (Mobile-First)
├─ Header Section
│  ├─ User Welcome ("Welcome, [Name]")
│  ├─ Overall Progress Ring (0-100%)
│  └─ Quick Stats (Courses, Lessons, Badges)
│
├─ Personal Metrics Section
│  ├─ Total Learning Hours
│  ├─ Course Completion Rate (%)
│  ├─ Quiz Pass Rate (%)
│  ├─ Streak Counter (Consecutive Days)
│  └─ Next Milestone
│
├─ Active Courses Section
│  ├─ Card-based layout
│  ├─ Progress bar per course
│  ├─ Time remaining
│  ├─ Next lesson preview
│  └─ "Continue Learning" CTA
│
├─ Recent Achievements
│  ├─ Latest badges earned
│  ├─ Certificate milestones
│  ├─ Leaderboard position (optional)
│  └─ Sharing options
│
├─ Recommended Next Steps
│  ├─ AI-suggested courses
│  ├─ Personalized learning path
│  ├─ Industry-relevant modules
│  └─ Skill gaps identified
│
└─ Learning Statistics Section
   ├─ Performance trend chart
   ├─ Category breakdown pie chart
   ├─ Time tracking analytics
   └─ Engagement metrics
```

### Dashboard Screens - Detailed UX

#### 1. Dashboard Home (Main View)
**Purpose**: Quick overview of all learning activity  
**Users**: All learners  
**Update Frequency**: Real-time

```
┌─────────────────────────────────────┐
│  ← Dashboard          🔔 ⚙️          │
├─────────────────────────────────────┤
│ Welcome back, Tanaka!               │
│ You're 68% through your learning    │
│ path this month                     │
├─────────────────────────────────────┤
│      ◯◯◯◯◯◯◯◯◯◯ 68%               │
│     68 hours learned | 12 badges    │
├─────────────────────────────────────┤
│ 🔥 7-Day Streak                     │
│ Keep it up! Study again tomorrow    │
├─────────────────────────────────────┤
│ Continuing...                       │
│ ┌─────────────────────────────────┐ │
│ │ Security Best Practices  ▶ ▶▶▶ │ │
│ │ 4 of 10 lessons done            │ │
│ │ Next: Password Management       │ │
│ └─────────────────────────────────┘ │
│ ┌─────────────────────────────────┐ │
│ │ AI in Compliance  ▶▶ ▶▶▶▶ ▶ │ │
│ │ 7 of 12 lessons done            │ │
│ │ Next: Responsible AI            │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Latest Achievements                 │
│ 🏆 ✓ Security Basics       (Today)  │
│ 📜 ✓ AI Fundamentals   (2 days ago) │
│ 🎯 ✓ 10-Lesson Milestone (3 days)  │
├─────────────────────────────────────┤
│ Recommended For You                 │
│ 📌 Phishing Detection              │
│    (Based on your role)             │
│ 📌 Privacy Essentials              │
│    (Trending in your industry)      │
├─────────────────────────────────────┤
│        [View Full Analytics]        │
└─────────────────────────────────────┘
```

#### 2. Detailed Analytics View
**Purpose**: Deep dive into performance metrics  
**Users**: Learners interested in self-assessment  
**Components**:
- Performance trends (last 7, 30, 90 days)
- Category-wise completion rates
- Quiz performance analysis
- Time spent per module
- Learning pace comparison (vs. program average)
- Skill proficiency radar chart

#### 3. Learning Path View
**Purpose**: Show recommended learning sequence  
**Users**: New learners, role-based learning  
**Components**:
- Industry/role-specific learning path
- Prerequisite indicators
- Estimated time to completion
- Skill outcomes on completion
- Success probability based on learner profile

---

## Phase 7B: Badge & Achievement System | バッジと達成システム

### Badge Architecture

#### Badge Categories

**1. Completion Badges** (Skill Mastery)
- **Bronze Badges**: Complete 1 module (×12 = one per category)
- **Silver Badges**: Complete 5 modules in category
- **Gold Badges**: Master all modules in category
- **Platinum Badge**: Complete all 12 categories

```dart
enum CompletionBadge {
  // Bronze Level
  ethics_basics('Ethics Basics', '🎖️'),
  security_basics('Security Basics', '🎖️'),
  // ... etc
  
  // Silver Level
  ethics_practitioner('Ethics Practitioner', '🥈'),
  security_expert('Security Expert', '🥈'),
  // ... etc
  
  // Gold Level
  ethics_master('Ethics Master', '🏅'),
  // ... etc
  
  // Platinum
  compliance_champion('Compliance Champion', '👑')
}
```

**2. Performance Badges** (Achievement Metrics)
- **Perfect Scorer**: 100% on any quiz attempt
- **Streak Master**: Maintain 7-day learning streak
- **Streak Legendary**: 30-day learning streak
- **Quiz Champion**: 95%+ average quiz score across 10+ quizzes
- **Speed Learner**: Complete course in 50% of estimated time

**3. Milestone Badges** (Progress Gates)
- **First Steps**: Complete 1st lesson
- **Getting Started**: Complete 5 lessons
- **On Track**: Complete 25 lessons
- **Dedicated Learner**: Complete 50 lessons
- **Expert Level**: Complete 100 lessons
- **Knowledge Vault**: Complete 250 lessons

**4. Engagement Badges** (Community & Interaction)
- **Early Bird**: Complete course within 24 hours of launch
- **Helpful Peer**: Assist other learners (Q&A system)
- **Quiz Reviewer**: Provide feedback on course
- **Social Champion**: Share achievements 10+ times
- **Mentor**: Help 5+ learners complete a course

**5. Special Badges** (Seasonal/Time-Based)
- **New Year Learner**: First learning activity in January
- **Summer Scholar**: Maintain 90% completion rate June-Aug
- **Corporate Champion**: Employee of quarter in learning metrics
- **Global Citizen**: Complete courses in 3+ languages

### Badge Visual Design

```
Badge Components:
├─ Icon/Graphic (64×64 px)
│  └─ Unique visual per badge type
│     ├─ Completion: Shield shape
│     ├─ Performance: Star shape
│     ├─ Milestone: Trophy shape
│     ├─ Engagement: Heart shape
│     └─ Special: Unique per badge
│
├─ Title (20-30 chars)
│  └─ Clear, motivating name
│
├─ Description (60-80 chars)
│  └─ Requirement explanation
│
├─ Unlock Date
│  └─ When earned
│
├─ Rarity Level
│  └─ Common, Rare, Epic, Legendary
│
└─ Share Button
   └─ Social media, email, messaging
```

### Badge Display Locations

1. **Achievement Notification** (In-app popup on unlock)
2. **Dashboard Achievement Section** (Last 5 badges)
3. **User Profile Page** (All badges earned)
4. **Badge Gallery** (All available badges, progress to unlock)
5. **Certificate PDF** (Earned badges shown on certificate)
6. **Social Share** (Display on LinkedIn, WhatsApp, etc.)

### Gamification Mechanics

#### Progression System
```
Rookie Level 1 → 5 Badges → Level 2
Level 2 → 10 Badges → Level 3
Level 3 → 15 Badges → Level 4
...
Level 10 → 50+ Badges → "Expert" Status
```

#### Points System
- Each lesson completion: 10 points
- Each quiz pass: 20 points
- Each badge earned: 50 points
- Daily streak (consecutive days): 5 bonus points/day
- Perfect quiz score: 30 bonus points

#### Leaderboard (Optional - Privacy-Controlled)
```
Leaderboard Types:
├─ Company-wide (if configured)
│  ├─ Top learners this week
│  ├─ Top learners this month
│  ├─ All-time top learners
│  └─ Department rankings
│
├─ Personal Metrics
│  ├─ Your rank vs. your department
│  ├─ Your rank vs. your industry
│  └─ Personal best achievements
│
└─ Privacy Controls
   ├─ Anonymous participation option
   ├─ Opt-in/out per leaderboard
   └─ Admin controls for company-wide
```

---

## Phase 7C: Certificate System | 証明書システム

### Certificate Types

#### 1. Course Completion Certificate
**Trigger**: Complete all lessons + pass final quiz (≥70%)  
**Content**:
```
┌────────────────────────────────────────┐
│     CERTIFICATE OF COMPLETION          │
│                                        │
│          Presented to:                 │
│     [User Name]                        │
│                                        │
│     For successful completion of:      │
│     [Course Name]                      │
│                                        │
│  Issued: [Date]                        │
│  Certificate ID: SAFY-2026-[ID]       │
│  Validity: [Expiration Date]           │
│                                        │
│  Score: [Quiz Average %]               │
│  Time Spent: [Hours]                   │
│  Lessons Completed: [X of Y]           │
│                                        │
│ ______________________                │
│     Authorized Signature               │
│   Safy Learning Platform              │
└────────────────────────────────────────┘
```

#### 2. Module Specialization Certificate
**Trigger**: Complete all modules in one category (e.g., "Security Expert")  
**Validity**: 1 year (auto-renewal on recertification quiz)

#### 3. Professional Certification
**Trigger**: Complete entire learning path (all 12 categories + specialization)  
**Content**:
- Comprehensive skills validation
- Individual module scores
- Completion timeline
- Badge achievements
- CPD/CEU credits (where applicable)
- LinkedIn-shareable version

### Certificate Features

**Digital Certificate**
- PDF format (printable and shareable)
- QR code linking to verification page
- Tamper-resistant design
- Blockchain-backed (optional - for premium tier)
- Multi-language generation

**Certificate Customization** (Admin Level)
- Company branding
- Custom issuer name
- Additional fields
- Logo/watermark placement
- Font/color scheme

**Verification Portal**
```
Certificate Verification
├─ URL-based verification
│  └─ www.safy.app/verify/[ID]
│
├─ Publicly accessible
│  └─ Show name, date, course, score
│
├─ Admin verification API
│  └─ Integration with HR systems
│
└─ Blockchain verification (optional)
   └─ Immutable certificate proof
```

### Certificate Export Options

1. **PDF Download**
   - Standard format (8.5"×11")
   - Landscape orientation
   - Print-ready quality

2. **Digital Share**
   - LinkedIn automatic posting
   - Email to contacts
   - WhatsApp/Telegram share
   - Facebook posting

3. **Professional Platforms**
   - Credly/Acclaim integration
   - LinkedIn Skills endorsements
   - Resume build services
   - Job application attachments

4. **API for Employers**
   - SCORM integration
   - LMS data sync
   - Real-time verification
   - Bulk reporting

---

## Implementation Roadmap | 実装ロードマップ

### Sprint 1: Foundation (Weeks 1-2)
- [ ] Database schema design (achievements, certificates)
- [ ] Dashboard UI components (Flutter)
- [ ] Badge data model and storage
- [ ] Certificate template engine
- [ ] Backend API endpoints

### Sprint 2: Dashboard (Weeks 3-4)
- [ ] Dashboard home screen UI
- [ ] Real-time progress calculation
- [ ] Analytics charts and graphs
- [ ] Personalized recommendations engine
- [ ] Mobile responsiveness optimization

### Sprint 3: Badge System (Weeks 5-6)
- [ ] Badge unlock logic (completion rules)
- [ ] Badge notification system
- [ ] Badge gallery UI
- [ ] Achievement animations
- [ ] Social sharing integration

### Sprint 4: Certificates (Weeks 7-8)
- [ ] Certificate generation (PDF)
- [ ] Verification portal
- [ ] Email delivery system
- [ ] Digital certificate styling
- [ ] Admin management interface

### Sprint 5: Polish & Integration (Weeks 9-10)
- [ ] Localization (8 languages)
- [ ] Performance optimization
- [ ] A/B testing setup
- [ ] Analytics integration
- [ ] Bug fixes and QA

### Sprint 6: Launch (Weeks 11-12)
- [ ] Beta testing with pilot users
- [ ] Feedback incorporation
- [ ] Production deployment
- [ ] User communication
- [ ] Monitor and optimize

---

## Technical Architecture | 技術アーキテクチャ

### Backend Services

```dart
// Achievement Service
class AchievementService {
  Future<void> checkAndUnlockBadges(User user) async {
    // Calculate metrics
    // Check unlock conditions
    // Create achievement records
    // Send notifications
  }
  
  List<Badge> getBadgesForUser(String userId) { }
  bool isBadgeUnlocked(String userId, String badgeId) { }
}

// Certificate Service
class CertificateService {
  Future<Certificate> generateCertificate(
    String userId, 
    String courseId,
  ) async {
    // Verify completion
    // Generate PDF
    // Store record
    // Return certificate
  }
  
  Future<bool> verifyCertificate(String certificateId) async { }
  Future<void> sendCertificateEmail(String userId, Certificate cert) async { }
}

// Dashboard Service
class DashboardService {
  Future<DashboardData> getDashboardData(String userId) async {
    // Calculate progress
    // Get active courses
    // Fetch recent achievements
    // Get recommendations
    // Calculate streaks
  }
}
```

### Database Schema

```sql
-- Achievements table
CREATE TABLE achievements (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  badge_id TEXT NOT NULL,
  unlocked_at TIMESTAMP,
  shared_count INT DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Certificates table
CREATE TABLE certificates (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  course_id TEXT NOT NULL,
  score REAL,
  issued_date TIMESTAMP,
  expiry_date TIMESTAMP,
  pdf_url TEXT,
  verification_token TEXT,
  FOREIGN KEY (user_id) REFERENCES users(id)
);

-- Learning streaks table
CREATE TABLE learning_streaks (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  current_streak INT,
  best_streak INT,
  last_activity_date DATE,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### Frontend Components

```dart
// Main Dashboard Widget
class LearningDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardProvider);
    return dashboardData.when(
      data: (data) => DashboardContent(data),
      loading: () => LoadingState(),
      error: (err, stack) => ErrorState(err),
    );
  }
}

// Progress Ring Component
class ProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String title;
  @override
  Widget build(BuildContext context) { }
}

// Badge Display Component
class BadgeCard extends StatelessWidget {
  final Badge badge;
  final bool isUnlocked;
  @override
  Widget build(BuildContext context) { }
}

// Certificate Viewer
class CertificateViewer extends StatelessWidget {
  final Certificate certificate;
  @override
  Widget build(BuildContext context) { }
}
```

---

## Analytics & Success Metrics | アナリティクスと成功指標

### Engagement Metrics
- Dashboard daily active users (DAU): Target 40%+
- Average dashboard session time: Target 3-5 minutes
- Badge unlock frequency: 1+ per learner per week average
- Certificate generation rate: 20%+ of course completions

### Business Metrics
- Course completion increase: 25-35% with progress visibility
- User retention (30-day): 60%+ with achievements
- Learning time investment: +40% with gamification
- Certification value perception: 4.2/5.0+ NPS

### Technical Metrics
- Dashboard load time: <2 seconds
- Certificate generation: <5 seconds
- Badge unlock latency: Real-time (< 1 second)
- API uptime: 99.9%+

---

## Localization Considerations | 現地化の考慮事項

### Multi-Language Support
- All badge names translated (8 languages)
- Certificate text multilingual
- Achievement notifications i18n
- Dashboard UI fully localized

### Cultural Adaptation
- Badge imagery culturally appropriate
- Achievement names resonate locally
- Certificate designs region-specific
- Gamification mechanics adapted to market norms

---

## User Communication Strategy | ユーザーコミュニケーション戦略

### Launch Announcement
- In-app banner notification
- Email to all active users
- Social media announcement
- Help documentation

### Education Materials
- Video tutorial (showing dashboard)
- Badge system explainer
- Certificate benefits guide
- FAQ documentation

### Ongoing Communication
- Achievement celebration emails
- Weekly progress digest
- Monthly "Top Learners" feature
- Certificate milestone announcements

---

## Risk Mitigation | リスク軽減

### Risk: Badge Devaluation (Too Easy to Earn)
**Mitigation**: Carefully calibrated unlock thresholds, rare badge tier system, analytics monitoring

### Risk: Fairness Concerns (Leaderboard)
**Mitigation**: Anonymous leaderboards, opt-in participation, personal streak tracking focus

### Risk: Certificate Credibility
**Mitigation**: Verification system, timestamp records, blockchain integration (premium)

### Risk: Mobile Performance (Certificate Generation)
**Mitigation**: Server-side PDF generation, caching, queue system for bulk requests

---

## Success Criteria | 成功基準

- [x] Dashboard accessible from main navigation
- [ ] 40%+ DAU within 2 months of launch
- [ ] Badge unlock rate: 1+ per user per week
- [ ] Certificate verification API: 99.9% uptime
- [ ] User satisfaction: 4.5/5.0+ rating
- [ ] Performance: <2s dashboard load time
- [ ] All 8 languages fully localized

---

## Next Phase: Administrative Features (Phase 8)

After Phase 7 completion, implement Phase 8:
- **Admin Dashboard** - Learning analytics reporting
- **Training Assignment** - Mandatory course assignment
- **Compliance Tracking** - Regulatory requirement fulfillment
- **Bulk User Management** - Department/organization management
- **Reporting & Export** - CSV, PDF, SCORM export

---

**Document Status**: Draft - Ready for Design Review  
**Last Updated**: 2026年8月30日  
**Version History**: 
- v1.0 (2026-08-30): Initial phase plan with detailed specifications
