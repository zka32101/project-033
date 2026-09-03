# Admin Training Program - Detailed Curriculum
## Safy Platform Administration Certification (2026)

**Document Purpose**: Comprehensive training curriculum for 42 FTE administrators across Safy's $2.5M transformation. Defines learning objectives, assessment criteria, and instructor materials for three certification tiers.

**Program Duration**: Sep 15 - Nov 25, 2026 (11 weeks)  
**Participants**: 42 team members (Content, Engineering, Operations, Specialists)  
**Success Target**: 95%+ certification completion by Nov 26 launch  
**Owner**: Training Coordinator

---

## TIER 1: PLATFORM BASICS CERTIFICATION
**Duration**: 4 hours | **Delivery**: Live + Asynchronous | **Target Completion**: Sep 28

### Module 1.1: Architecture Overview (45 minutes)

**Learning Objectives**:
- [ ] Understand core system architecture and component relationships
- [ ] Explain data flow through platform (user input → processing → delivery)
- [ ] Identify roles of different backend/frontend services
- [ ] Describe 8-language localization architecture
- [ ] Know where to find system architecture documentation

**Content Outline**:
1. **System Components** (12 min)
   - User interface layer (web, mobile)
   - API gateway and microservices
   - Content management system (CMS)
   - Database layer and caching
   - Analytics pipeline
   - Video streaming infrastructure

2. **Data Flow Walkthrough** (15 min)
   - User login flow (authentication, session management)
   - Content delivery flow (personalization, recommendations)
   - Admin action flow (content publishing)
   - Analytics event flow (tracking, storage, reporting)
   - Localization flow (language selection, resource loading)

3. **Scalability & Reliability** (10 min)
   - Auto-scaling architecture
   - Failover and redundancy
   - Database replication
   - CDN for content delivery
   - Monitoring and alerts

4. **Security Architecture** (8 min)
   - Authentication & authorization
   - Data encryption (in-transit, at-rest)
   - Access control layers
   - Compliance frameworks
   - Audit logging

**Delivery Method**: 
- Live 45-min webinar with slides + architecture diagrams
- Video replay available (YouTube unlisted)
- Downloadable architecture diagrams (PDF)
- Recorded Q&A session (20 min)

**Assessment**:
- Attendance check
- Post-video quiz (5 questions, 80% pass)
- Reflection: "Describe data flow for one admin action"

**Instructor Notes**:
- Emphasize different data flow based on user type (viewer vs admin)
- Use visual diagrams extensively
- Pause for Q&A every 3-5 minutes
- Record in HD for international audiences

---

### Module 1.2: User Interface Tour (60 minutes)

**Learning Objectives**:
- [ ] Navigate all main interface sections
- [ ] Understand navigation hierarchy
- [ ] Access admin dashboard and control panels
- [ ] Use search, filters, and sorting
- [ ] Customize personal dashboard preferences
- [ ] Access help and documentation within app

**Content Outline**:
1. **Main Dashboard** (15 min)
   - Dashboard layout and widgets
   - Quick stats and KPIs
   - Recent activity timeline
   - Personalization options
   - Theme and language switching

2. **Navigation & Menus** (15 min)
   - Top navigation bar
   - Sidebar menu structure
   - Breadcrumb navigation
   - Search bar usage
   - Mobile-responsive design

3. **Admin Panels** (15 min)
   - Content management panel
   - User management panel
   - Settings & configuration
   - Analytics & reporting
   - System monitoring dashboard
   - Role-specific admin views

4. **Search & Filtering** (10 min)
   - Global search syntax
   - Advanced filters
   - Saved search queries
   - Filter combinations
   - Result sorting options

5. **Help & Support** (5 min)
   - In-app help tooltips
   - Help documentation portal
   - Contact support within app
   - Keyboard shortcuts
   - Accessibility features

**Delivery Method**:
- Live 60-min screen sharing webinar (presenter demonstrates, participants follow)
- Interactive: Participants have same app open and follow along
- Multiple attendee breakouts for office hours Q&A
- Video recording with clickable timestamp index

**Hands-On Practice**:
- 30-min sandbox environment access
- 5 guided tasks (navigation, search, filter, customize, help access)
- Instructor checks progress and provides feedback

**Assessment**:
- Task completion checklist (all 5 tasks completed)
- Observation: Can participants navigate independently?
- Quiz: 8 questions on interface features (80% pass)

**Instructor Notes**:
- Navigate slowly, explaining each click
- Highlight keyboard shortcuts
- Show both desktop and mobile views
- Demo in English first, then show language switching to other locales

---

### Module 1.3: User Role System (45 minutes)

**Learning Objectives**:
- [ ] Understand 5 main user roles in platform
- [ ] Describe permission levels for each role
- [ ] Apply role-based access control principles
- [ ] Explain role assignment and transitions
- [ ] Know escalation for permission questions
- [ ] Understand role-specific workflows

**Content Outline**:
1. **Five Core Roles** (25 min)
   - **Viewer/Student**: Access courses, track progress, community features
   - **Curator/Content Admin**: Create/edit content, manage modules
   - **System Admin**: System settings, user management, monitoring
   - **Support Admin**: User support, troubleshooting, escalation
   - **Executive/Analytics**: High-level reporting, decisions, strategy

2. **Permission Levels** (10 min)
   - What each role can READ
   - What each role can CREATE
   - What each role can EDIT
   - What each role can DELETE
   - What each role can APPROVE
   - Permission inheritance and exceptions

3. **Role Assignment Process** (8 min)
   - How roles are assigned
   - Role transitions (promotion, demotion)
   - Who can assign roles (role hierarchy)
   - Approval process for role changes
   - Audit trail of role changes

4. **Role-Specific Workflows** (2 min)
   - Quick tour of different workflows
   - Where to find detailed procedures
   - Escalation when permission denied

**Delivery Method**:
- Live 45-min webinar with real system demonstration
- Role comparison chart (downloadable PDF)
- Permission matrix (interactive, searchable)
- Case study scenarios for Q&A

**Hands-On Practice**:
- Access test environment with different roles
- Observe what each role can/cannot see
- Attempt actions outside permissions (observe restrictions)

**Assessment**:
- Scenario quiz: "What can Role X do with Action Y?" (10 scenarios, 80% pass)
- Reflection: "Describe your role and its key permissions"

**Instructor Notes**:
- Emphasize security principle: "least privilege access"
- Show what happens when permission denied
- Explain why certain restrictions exist
- Highlight common role confusion points

---

### Module 1.4: Basic Troubleshooting (60 minutes)

**Learning Objectives**:
- [ ] Identify and resolve common login issues
- [ ] Troubleshoot content display problems
- [ ] Know when to escalate vs. self-resolve
- [ ] Access troubleshooting documentation
- [ ] Use error messages to diagnose issues
- [ ] Document problems for escalation
- [ ] Know basic system health checks

**Content Outline**:
1. **Login Troubleshooting** (15 min)
   - Password reset procedures
   - Account lockout resolution
   - Multi-factor authentication problems
   - Session timeout explanation
   - Browser cookie/cache issues
   - "Forgot password" workflow

2. **Content Display Problems** (15 min)
   - Video not playing (browsers, codecs, streaming)
   - Content not loading (cache, CDN, network)
   - Incomplete module display
   - Language/locale issues
   - Mobile responsiveness problems
   - Plugin/extension conflicts

3. **Error Message Interpretation** (15 min)
   - Common error codes and meanings
   - How to read stack traces (basic)
   - Using browser developer tools (basics)
   - Checking system status page
   - Reading application logs (for admins)

4. **Escalation Process** (10 min)
   - When to escalate vs. troubleshoot
   - How to document problems
   - What information to collect
   - Escalation channels and procedures
   - Follow-up expectations

5. **System Health Checks** (5 min)
   - Check system status dashboard
   - Monitor performance metrics
   - Verify database connectivity
   - Test API health endpoints

**Delivery Method**:
- Live 60-min webinar with live problem scenarios
- Troubleshooting decision flowchart (downloadable PDF)
- Symptom-to-resolution guide (searchable)
- Video demonstrations of each troubleshooting scenario
- Practice environment with simulated problems

**Hands-On Practice**:
- 40-min practice: Troubleshoot 6 simulated scenarios
- Each scenario: Find root cause and resolution
- Instructor provides hints and feedback
- Practice with real error messages

**Assessment**:
- Scenario troubleshooting (6 problems, 80%+ resolution rate)
- Error message interpretation quiz (8 questions)
- Reflection: "Describe a troubleshooting scenario and escalation"

**Instructor Notes**:
- Teach systematic troubleshooting (step-by-step, not guessing)
- Emphasize: "When in doubt, escalate"
- Show real examples from previous issues
- Demonstrate use of browser developer tools
- Normalize escalation as positive (prevents larger issues)

---

### Module 1.5: 8-Language Operations (30 minutes)

**Learning Objectives**:
- [ ] Understand 8 supported languages and locales
- [ ] Switch application language/region
- [ ] Test content in different languages
- [ ] Identify language-specific issues
- [ ] Know localization workflow
- [ ] Understand RTL (right-to-left) considerations

**Content Outline**:
1. **Supported Languages Overview** (8 min)
   - Japanese (ja-JP) - primary, 2x+ content
   - English (en-US) - international business
   - Mandarin Chinese (zh-CN) - Asia expansion
   - Korean (ko-KR) - regional demand
   - Thai (th-TH) - Southeast Asia
   - Vietnamese (vi-VN) - Southeast Asia
   - Indonesian (id-ID) - Southeast Asia
   - Tagalog/Filipino (tl-PH) - Southeast Asia
   - Where each language is dominant
   - User breakdown by language

2. **Language Switching & Testing** (10 min)
   - How users switch language
   - How admins test in different languages
   - Using locale selectors
   - Testing with browser language settings
   - Mobile language switching

3. **RTL Considerations** (5 min)
   - Arabic (future phase) RTL layout
   - Text direction and CSS
   - Number and date formatting
   - Icon orientation
   - Reading order

4. **Localization Workflow** (5 min)
   - Content in English first
   - Translation process
   - Localization quality assurance
   - Variant handling (zh-CN vs. zh-TW)
   - Regional customizations

5. **Common Language Issues** (2 min)
   - Missing translations
   - Broken encoding
   - Font rendering
   - Date/time formatting issues
   - Escalation for translation issues

**Delivery Method**:
- Live 30-min demo with real system
- Show language switching live in multiple browsers
- Visual guide showing all 8 languages (PDF)
- Localization workflow diagram
- FAQ for language-specific questions

**Hands-On Practice**:
- 20-min: Switch to each of 8 languages
- Navigate interface in each language
- Identify any formatting issues
- Test with mobile device

**Assessment**:
- Observation: Can navigate in 8+ languages
- Quiz: 5 language-related questions (80% pass)
- Reflection: "Describe locale switching process"

**Instructor Notes**:
- Show all 8 flags and language names
- Demonstrate RTL text rendering (if possible)
- Highlight character set requirements (UTF-8)
- Explain why some interfaces still show English
- Show regional variations (dates, numbers)

---

### Tier 1 Assessment & Certification

**Certification Requirements**:
- Attendance: ≥80% (at least 3 of 5 modules live)
- Quiz Average: ≥80% (across all 5 module quizzes)
- Hands-On Completion: All practice tasks completed
- Time Investment: ≥4 hours of training
- Final Reflection: Submitted and approved

**Retake Policy**:
- Failed quiz: Unlimited retakes within 2 weeks
- Attendance shortfall: Complete asynchronous modules by deadline
- Time requirements: Self-directed study in sandbox environment

**Certificate Upon Completion**:
- Digital certificate: "Safy Platform Basics Competency"
- Issued: Via email and in-system dashboard
- Validity: 1 year (requires annual refresher)
- Recognition: Listed in company directory, team announcements

**Post-Certification Support**:
- Office hours every Wed 3-4 PM JST (first 2 weeks)
- Q&A forum in learning platform
- "Basics Refresher" video available 24/7
- Escalation to role-specific trainers for follow-up

---

## TIER 2: ROLE-SPECIFIC SPECIALIZATION CERTIFICATION
**Duration**: 8-16 hours per role | **Delivery**: Hands-on labs + videos | **Target**: 95%+ pass by Oct 31

### Role: Content Admin (Tier 2 - Content Team 10 FTE)

**Prerequisites**: Tier 1 Platform Basics certification

**Core Learning Objectives**:
- [ ] Manage content modules from creation to publication
- [ ] Execute video production workflow end-to-end
- [ ] Apply metadata standards consistently
- [ ] Conduct quality assurance reviews
- [ ] Use analytics to optimize content
- [ ] Coordinate content team reviews

**Curriculum**:

| Module | Duration | Hands-On | Assessment |
|--------|----------|----------|-----------|
| C1: Content Management System | 2h | Lab: Create & publish 2 test modules | Module checklist exam |
| C2: Video Workflow Mastery | 2h | Lab: Upload, transcode, subtitle 1 video | Video QA checklist |
| C3: Metadata & SEO Optimization | 1.5h | Lab: Optimize 5 content modules | Metadata review exam |
| C4: Analytics & Performance | 1.5h | Lab: Analyze 3 content pieces, write insight report | Analytics comprehension quiz |
| C5: Team Collaboration & Reviews | 1h | Lab: Review peer module, provide feedback | Collaboration exercise |

**Certification Requirement**: 
- Publish 5 original modules with ≥85% QA score
- Pass all 5 module exams with ≥80%
- Demonstrate independent content management
- Receive sign-off from Content Lead

**Post-Certification Role**:
- Responsible for module creation and publishing (200+ modules/quarter)
- Own content quality standards
- Lead peer reviews and QA
- Mentor newer content admins

---

### Role: Engineering Admin (Tier 2 - Engineering Team 15 FTE)

**Prerequisites**: Tier 1 Platform Basics certification + basic Linux knowledge

**Core Learning Objectives**:
- [ ] Monitor system performance and health
- [ ] Interpret and use API documentation
- [ ] Manage database backups and recovery
- [ ] Deploy updates via CI/CD pipeline
- [ ] Diagnose infrastructure issues
- [ ] Implement security scanning and patches

**Curriculum**:

| Module | Duration | Hands-On | Assessment |
|--------|----------|----------|-----------|
| E1: System Monitoring & Alerting | 2h | Lab: Set up 5 alerts, respond to incidents | Incident response drill |
| E2: API Testing & Integration | 2h | Lab: Test 10 APIs, verify response formats | API functionality exam |
| E3: Database Operations | 2h | Lab: Backup, restore, query optimization | DB operations exam |
| E4: CI/CD & Deployment | 2h | Lab: Deploy to staging environment | Deployment checklist |
| E5: Security Scanning & Patches | 1.5h | Lab: Run vulnerability scan, patch systems | Security audit exam |

**Certification Requirement**:
- Successfully deploy to staging (test fix)
- Create incident response plan for 2 scenarios
- Perform database backup and full restore
- Pass all 5 exams with ≥80%
- Receive sign-off from Engineering Lead

**Post-Certification Role**:
- On-call rotation for production issues
- Infrastructure maintenance and updates
- Performance optimization
- Security patching and compliance

---

### Role: Operations Admin (Tier 2 - Operations Team 12 FTE)

**Prerequisites**: Tier 1 Platform Basics certification

**Core Learning Objectives**:
- [ ] Manage user accounts and permissions
- [ ] Generate reports and insights
- [ ] Respond to support incidents
- [ ] Maintain compliance and audit logs
- [ ] Optimize operational workflows
- [ ] Coordinate cross-team initiatives

**Curriculum**:

| Module | Duration | Hands-On | Assessment |
|--------|----------|----------|-----------|
| O1: User Management & Permissions | 1.5h | Lab: Create users, assign roles, manage access | User management exam |
| O2: Reporting & Analytics | 1.5h | Lab: Build 3 custom reports, export data | Analytics competency exam |
| O3: Incident Response & Triage | 2h | Lab: Respond to 5 simulated incidents | Incident response drill |
| O4: Compliance & Audit | 1.5h | Lab: Review audit logs, verify compliance | Compliance audit exam |
| O5: Support Tools & Ticketing | 1.5h | Lab: Resolve 10 test support tickets | Support SLA achievement |

**Certification Requirement**:
- Manage 50+ test users independently
- Create 3 production-ready reports
- Resolve 10 support tickets within SLA
- Pass all 5 exams with ≥80%
- Receive sign-off from Operations Lead

**Post-Certification Role**:
- Support team lead for user/operational issues
- Regular reporting and analytics
- Compliance monitoring
- Process optimization

---

### Tier 2 Specialization Timeline

**Week 5 (Oct 15-21): Content & Engineering Modules**
- All 10 content staff start C1-C2 (video workflow critical path)
- All 15 engineers start E1-E2 (monitoring critical)
- Morning sessions (9-11 AM JST): Live labs with instructor
- Afternoon: Self-paced review and practice

**Week 6 (Oct 22-28): Operations & Specialist Modules**
- All 12 ops staff start O1-O3 (user management critical)
- 5 specialists begin role-specific paths
- Wednesday office hours for questions
- Peer study groups form for accountability

**Week 7 (Oct 29-Nov 4): Hands-On Labs & Practice**
- All staff in intensive hands-on lab phase
- Real sandbox data for practice
- Pair programming with senior staff
- Real problem solving with guidance

**Week 8 (Nov 5-11): Certification Exams**
- Mon-Tue: Module exams 1-3
- Wed-Thu: Module exams 4-5
- Fri: Retakes for those needed
- Target: 40/42 pass, 2 retakes by Nov 11

**Week 9 (Nov 12-18): Follow-up & Advanced**
- Certified staff begin Tier 3 advanced training
- Failed exams → targeted tutoring
- Peer mentoring pairs established
- Advanced specialist modules open

---

## TIER 3: ADVANCED SPECIALIZATION CERTIFICATION
**Duration**: 12+ hours | **Delivery**: Advanced labs + mentorship | **Target**: 100% of critical roles by Nov 15

### Tier 3 Specializations (5-8 critical staff)

1. **Database Administration** (2 engineers)
   - Advanced query optimization
   - Schema design and evolution
   - Disaster recovery scenarios
   - Scaling strategies
   - Certification: Run production DB backup, recovery drill

2. **Security Operations** (3 operations staff)
   - Penetration testing basics
   - Vulnerability assessment
   - Compliance auditing (SOC 2, GDPR)
   - Incident response escalation
   - Certification: Lead simulated security incident response

3. **Performance Optimization** (2 engineers)
   - Profiling and benchmarking
   - Caching strategies
   - Database query optimization
   - API response time tuning
   - Certification: Improve system performance 10%+

4. **User Analytics** (2 product/analytics staff)
   - Advanced dashboard creation
   - Cohort analysis
   - A/B testing design
   - Business intelligence insights
   - Certification: Present strategic analytics recommendations

5. **Localization Operations** (2 content + 1 specialist)
   - Managing 8-language workflows
   - Translation vendor management
   - QA for language-specific issues
   - Cultural adaptation strategies
   - Certification: Manage end-to-end translation for new language

---

## TRAINING DELIVERY PLATFORM & TOOLS

### Learning Management System (LMS)

**Features Required**:
- [ ] Video hosting and streaming (adaptive bitrate)
- [ ] Interactive quizzes and assessments
- [ ] Progress tracking and completion certificates
- [ ] Discussion forums and Q&A
- [ ] Hands-on lab environment integration
- [ ] Mobile app for learning on-the-go
- [ ] Localization support (8+ languages)
- [ ] Accessibility features (captions, transcripts)
- [ ] Reporting and analytics

**Recommended Platforms**:
- **Moodle** ($10K-20K setup, open-source, fully customizable)
- **Teachable** ($99-299/month, managed, limited customization)
- **Thinkific** ($199-2,499/month, enterprise features)
- **Custom LMS** (built in-house, $50K-100K, maximum flexibility)

**Selected**: Moodle instance hosted on company infrastructure (cost-effective, customizable, suitable for 42 users)

### Sandbox Environments

**Requirements**:
- [ ] Staging environment replica (same data structures, smaller scale)
- [ ] Test databases with sample data
- [ ] User account provisioning for each trainee
- [ ] Monitoring sandbox (practice alert setup)
- [ ] Video upload sandbox
- [ ] API testing environment
- [ ] Reset capability for practice scenarios

**Infrastructure**: AWS EC2 instances (t3.large), replicated nightly from production

### Video Production

**Videos to Produce**:
- Tier 1: 5 videos (~60 min total)
- Tier 2: 25 videos (~100 min per role track, 25+ hours engineer time)
- Tier 3: 10 videos (~40 min total)
- Support: 5 additional review/recap videos

**Production Specs**:
- Resolution: 1920x1080 (4K future-proof)
- Format: MP4 (H.264) + WebM backup
- Subtitles: English (auto-generated), + 7 language translations
- Captions: 99% accuracy (for accessibility)
- Video host: YouTube (unlisted) + custom CDN

**Production Timeline**:
- Script development: Sep 3-10 (1 week)
- Video recording & editing: Sep 11-24 (2 weeks)
- Subtitle & translation: Sep 25-30 (1 week)
- Review & finalization: Oct 1-5 (1 week)
- Total timeline: 4 weeks, completion by Oct 5

---

## INSTRUCTOR MATERIALS & FACILITATION

### Instructor Training

**For each facilitator**:
- [ ] Attend full training as participant (4 hours Tier 1)
- [ ] Complete role specialization (if relevant)
- [ ] Attend 4-hour facilitator workshop:
  - How to deliver each module
  - Handling common questions
  - Troubleshooting delivery issues
  - Engagement techniques
  - Time management
  - Accessibility considerations
  - Technical support procedures
- [ ] Co-facilitate with experienced facilitator (1 session)
- [ ] Solo facilitation with feedback (1 session)
- [ ] Ongoing support and updates

**Facilitator Count**: 
- 1 primary (Training Coordinator)
- 2 supporting (Role leads who can facilitate)
- 5 guest instructors (specialists for deep dives)
- 8 peer mentors (for advanced roles)

### Facilitator Materials (for each module)

- Detailed instructor guide (2-3 pages)
- PowerPoint slides (30-50 slides per module)
- Timing guide (minute-by-minute)
- Q&A anticipated questions and answers
- Demo scripts with timing
- Troubleshooting guide
- Feedback templates
- Handouts and reference guides

---

## PROGRAM SUCCESS METRICS

### Completion Metrics
- **Tier 1 Completion**: 42/42 (100%) by Sep 28
- **Tier 2 Completion**: 40/42 (95%+) by Oct 31
- **Tier 3 Completion**: 100% of critical roles by Nov 15

### Quality Metrics
- **Average Quiz Score**: 85%+ (per module)
- **Pass Rate (First Attempt)**: 90%+ for Tier 2
- **Hands-On Performance**: 80%+ completing all exercises
- **Module Satisfaction**: 4.0+/5.0 (participant survey)
- **Knowledge Retention**: 85%+ on post-training assessment

### Application Metrics
- **Time to Independence**: <4 weeks average
- **Support Ticket Resolution**: Self-resolved in first week
- **Quality of Work**: 90%+ quality score on first assigned task
- **Incident Response**: <5 min for P1 issues by week 1
- **Confidence Level**: 85%+ self-reported confidence by Nov 1

---

## NEXT STEPS

1. **Sep 3-6**: Finalize video scripts and storyboards
2. **Sep 7-10**: Begin video production
3. **Sep 10-12**: Set up LMS and sandbox environments
4. **Sep 13-14**: Facilitator training
5. **Sep 15**: Launch Tier 1 training with first live session
6. **Sep 22**: Begin knowledge transfer sessions with team leads
7. **Sep 29**: Tier 1 completion verification
8. **Oct 1**: Tier 2 specialization begins
9. **Oct 31**: Tier 2 certification completion
10. **Nov 1**: Support structure operational for launch
11. **Nov 26**: Market launch with full team operational

---

**Document Status**: DRAFT  
**Created**: September 3, 2026  
**Owner**: Training Coordinator  
**Next Review**: Sep 8 (post-board decision)

---

_Generated with Claude Code_
