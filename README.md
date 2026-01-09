# 🤱 MamaCare Butler

> Your AI-powered maternal health companion - Built for Kenyan mothers

[![Flutter](https://img.shields.io/badge/Flutter-3.5+-02569B?logo=flutter)](https://flutter.dev)
[![Serverpod](https://img.shields.io/badge/Serverpod-3.1.1-orange)](https://serverpod.dev)
[![Gemini](https://img.shields.io/badge/Gemini-1.5%20Flash-4285F4?logo=google)](https://ai.google.dev/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**🏆 Built for:** [Flutter Butler with Serverpod Hackathon 2026](https://serverpod-flutter-hackathon.devpost.com/)  
**🛠️ Tech Stack:** Flutter + Serverpod + Gemini AI + PostgreSQL

---

## 🎯 The Problem

In Kenya:
- **342 maternal deaths** per 100,000 live births
- **70% of complications** are preventable with early detection
- Poor medication adherence - mothers forget prenatal vitamins
- Most mothers only see healthcare providers **once per month**
- Medical information is often **confusing and inaccessible**
- Limited access to continuous health monitoring

---

## 💡 Our Solution

**MamaCare Butler** is a mobile app that acts as a **personal health companion available 24/7**, helping pregnant mothers:

- 🩺 Monitor their health weekly with AI-powered risk analysis
- 💊 Track medications with scheduled reminders
- 🔬 Understand ultrasound reports in simple language
- 🚨 Detect warning signs early with Gemini AI
- 📊 Visualize health trends (BP, weight, fetal movements)
- 🆘 Get emergency help with one-tap SOS
- 👶 Monitor baby's kicks with AI pattern detection

---

## ✨ Core Features

### 🤖 AI Weekly Health Check-ins
- **Gemini-powered symptom analysis** for pre-eclampsia detection
- Risk assessment (LOW/MEDIUM/HIGH) with personalized advice
- Tracks warning signs: severe headache, vision changes, swelling, reduced fetal movement
- Blood pressure and weight monitoring
- Complete check-in history with AI insights

**How it works:**
1. Answer 8 symptom questions + optional measurements
2. Gemini AI analyzes your responses
3. Get instant risk assessment and recommendations
4. Track trends over time

### 🔬 Ultrasound Translator
- **Gemini Vision** extracts measurements from ultrasound images
- Converts medical jargon to simple explanations
- Tracks baby's growth across multiple scans
- Smart reminders for next ultrasound appointments
- Scan history with photo viewer

**Supported measurements:** BPD, FL, HC, AC, EFW, AFI

### 👣 Smart Kick Counter
- Easy one-tap kick recording
- **AI pattern analysis** detects anomalies
- Time-to-10-kicks tracking
- Visual analytics with trend charts
- Session history with Gemini insights

### 💊 Medication Tracker
- Add medications with dosage and frequency
- **Scheduled notifications** for reminder times
- Pause/activate medications
- View complete medication history
- Active/inactive status tracking

**Supports:** Daily, twice daily, three times daily, weekly schedules

### 🚨 Emergency SOS
- **One-tap emergency alert**
- Sends SMS with GPS location to emergency contacts
- Includes pregnancy week for medical context
- Works instantly without internet for SMS

### 📊 Health Trends Dashboard
- **Visual charts** for blood pressure, weight, kick counter
- Period filters: 1 week, 2 weeks, 1 month, 3 months, all time
- Interactive graphs with fl_chart
- Empty states with helpful guidance

### 👤 Profile Management
- Pregnancy progress tracking (week X of 40)
- Due date countdown
- Personal and medical information
- Emergency contact details
- **Edit profile** functionality

### ⚙️ Settings & Notifications
- **Master notification toggle** (enable/disable all)
- Individual controls for each notification type:
  - Ultrasound reminders
  - Weekly health check-ins
  - Kick counter reminders
  - Medication reminders
- View all scheduled reminders
- Notification count badge

### 💁 Help & Support
- **Emergency hotlines** (999, 15999 Kenya)
- Contact support via email/phone
- Comprehensive **FAQs** about app features
- Helpful resources (Ministry of Health, WHO)
- App version info

---

## 🏗️ Architecture
```
mamacare-butler/
├── mamacare_server/        
│   ├── lib/src/
│   │   ├── endpoints/       
│   │   │   ├── v1_auth_endpoint.dart
│   │   │   ├── v1_maternal_profile_endpoint.dart
│   │   │   ├── v1_health_checkin_endpoint.dart
│   │   │   ├── v1_ultrasound_endpoint.dart
│   │   │   ├── v1_kick_counter_endpoint.dart
│   │   │   └── v1_medication_endpoint.dart
│   │   ├── protocol/       
│   │   │   ├── user.yaml
│   │   │   ├── maternal_profile.yaml
│   │   │   ├── health_checkin.yaml
│   │   │   ├── ultrasound_scan.yaml
│   │   │   ├── kick_session.yaml
│   │   │   └── medication.yaml
│   │   └── services/        
│   │       ├── gemini_service.dart
│   │       └── notification_service.dart
│   └── migrations/          
├── mamacare_client/          
├── mamacare_flutter/     
│   ├── lib/
│   │   ├── screens/      
│   │   ├── services/        
│   │   └── widgets/        
│   └── android/
└── README.md
```

### Tech Stack

**Frontend:**
- **Flutter 3.5+** (cross-platform mobile)
- **flutter_screenutil** (responsive design)
- **fl_chart** (beautiful charts)
- **flutter_local_notifications** (scheduled reminders)
- **geolocator** (GPS for emergency)
- **telephony** (SMS integration)
- **intl** (date formatting)

**Backend:**
- **Serverpod 3.1.1** (Dart backend framework)
- **PostgreSQL** (database)
- **6 custom REST endpoints**
- **Database migrations** with Liquibase

**AI Integration:**
- **Google Gemini 1.5 Flash** (text analysis)
- **Gemini Vision** (image OCR)
- Structured JSON responses
- Medical prompt engineering

**Features:**
- **Authentication** (phone + PIN + biometric)
- **Timezone support** (Africa/Nairobi)
- **Emergency SMS** (Android telephony)
- **GPS location** (geolocator)
- **Local notifications** (flutter_local_notifications)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.5+
- Dart SDK 3.0+
- Serverpod CLI 3.1+
- PostgreSQL 14+
- Android Studio / VS Code
- Gemini API key

### Installation

#### 1. Clone Repository
```bash
git clone https://github.com/its-kios09/mamacare-butler.git
cd mamacare-butler
```

#### 2. Setup Backend
```bash
cd mamacare_server

# Create .env file
nano .env
```

Add:
```env
GEMINI_API_KEY=your_gemini_api_key_here
```
```bash
dart pub get

serverpod generate

docker run -d \
  --name mamacare-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=mamacare \
  -p 8090:5432 \
  postgres:14

dart bin/main.dart --apply-migrations

# Start server
dart bin/main.dart
```

Server will run on `http://localhost:8083`

#### 3. Setup Flutter App
```bash
cd ../mamacare_flutter

# Install dependencies
flutter pub get

# Update server URL in lib/main.dart
# Change: Client('http://localhost:8083')
# Or: Client('http://10.0.2.2:8083') for Android emulator

# Run app
flutter run
```

#### 4. Test Features
1. **Sign up** with phone number
2. **Create profile** (name, due date, emergency contact)
3. **Complete health check-in** → See AI risk assessment
4. **Upload ultrasound** image → See Gemini extract measurements
5. **Track kicks** → Get AI pattern analysis
6. **Add medication** → Get notifications
7. **Test emergency SOS** → Check SMS sent
8. **View health trends** → See charts

---

## 📱 Screenshots

### Authentication Flow
- Phone input screen
- PIN setup/login
- Biometric authentication

### Onboarding
- Maternal profile setup
- Due date calculator
- Emergency contacts

### Home Dashboard
- Pregnancy week tracker
- Quick actions (Check-in, Ultrasound, Kick Counter, Medications)
- Health trends preview
- Emergency SOS button

### Health Check-in
- Multi-step form (symptoms, measurements, additional info)
- AI risk assessment results (GREEN/ORANGE/RED)
- Check-in history with cards

### Ultrasound Translator
- Camera upload interface
- Gemini Vision measurement extraction
- Simple explanation display
- Scan history with photos

### Kick Counter
- One-tap kick tracker
- Session timer
- Kick history
- AI pattern analysis

### Health Trends
- Line charts (kicks, BP, weight)
- Period filters
- Interactive tooltips

### Profile & Settings
- Pregnancy progress bar
- Edit profile form
- Notification toggles
- Help & Support

_Full screenshots coming in demo video!_

---

## 🎥 Demo Video

---

## 🏆 Hackathon Submission

### Innovation ⭐
**First AI-powered maternal health assistant built specifically for Kenyan mothers**, combining:
- ✅ Local context (Kenya timezone, emergency numbers, SMS integration)
- ✅ Cutting-edge AI (Gemini 1.5 Flash + Vision)
- ✅ Comprehensive health tracking (10+ features)
- ✅ Professional healthcare experience (KenyaEMR, mChanjo deployments)

### Technical Excellence 💻
- ✅ **Flutter + Serverpod** full-stack implementation
- ✅ **Gemini AI** for intelligent health analysis
- ✅ **Database migrations** with PostgreSQL
- ✅ **Real-time notifications** (4 types)
- ✅ **Emergency SMS + GPS** integration
- ✅ **Chart visualizations** with fl_chart
- ✅ **Responsive design** (flutter_screenutil)

### Impact 🌍

**Lives Saved:**
- ✅ Early detection of pre-eclampsia → prevent maternal death
- ✅ Medication tracking → reduce anemia, prevent neural tube defects
- ✅ Kick pattern monitoring → detect fetal distress
- ✅ Emergency SOS → faster response times

**Scale Potential:**
- **1.5M+ pregnancies/year** in Kenya
- **47 counties** ready for deployment
- **Integration-ready** with KenyaEMR/mChanjo (600+ facilities)
- **B2C + B2B** model (individuals + county governments)

**Measurable Metrics:**
- Medication adherence tracking
- Health check-in completion rate
- Emergency response time
- Risk detection accuracy

---

## 🌍 Social Impact

**UN Sustainable Development Goals:**
- ✅ SDG 3: Good Health and Well-being
- ✅ SDG 5: Gender Equality
- ✅ SDG 10: Reduced Inequalities

**Alignment with:**
- ✅ Kenya Vision 2030 (healthcare pillar)
- ✅ WHO Safe Motherhood Initiative
- ✅ Ministry of Health Kenya maternal health strategy

---

## 🔮 What's Next

**Immediate (Q1 2026):**
- [ ] Deploy to Google Cloud Platform / Railway
- [ ] WhatsApp Business API integration for medication reminders
- [ ] Educational content (week-by-week pregnancy tips)
- [ ] Pilot with Nairobi County Health Department

**Short-term (Q2-Q3 2026):**
- [ ] FHIR compliance for KenyaEMR integration
- [ ] Multi-language support (Swahili, Kikuyu, Luo)
- [ ] Offline-first with SQLite
- [ ] Telemedicine consultations

**Long-term (2027+):**
- [ ] Expand to all 47 Kenya counties
- [ ] Uganda, Tanzania, Rwanda deployment
- [ ] Community health worker dashboard
- [ ] Partnership with Gates Foundation / USAID

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

---

## 👨‍💻 Author

**Fredrick Kioko Kilonzo** ([@its-kios09](https://github.com/its-kios09))

Healthcare software developer with 5+ years specializing in:
- **OpenMRS/KenyaEMR** - Deployed systems serving **100,000+ patients**
- **mChanjo** - Immunization tracking across **50+ Kenyan counties**
- **FHIR integration** for healthcare interoperability
- **Digital health solutions** for underserved populations

*Built as a new father who wants every mother to have a safe pregnancy.* ❤️

---

## 🙏 Acknowledgments

- **Serverpod Team** - For the amazing framework and hackathon opportunity
- **Google AI** - For Gemini API access
- **Kenya Ministry of Health** - For the opportunity to serve
- **My wife** - For the inspiration and user testing ❤️

---

## 📞 Contact

- **GitHub:** [@its-kios09](https://github.com/its-kios09)
- **Email:** kilonzokioko10@gmail.com
- **LinkedIn:** [Fredrick Kioko](https://www.linkedin.com/in/fredrick-kioko-506550171/)

---


**⭐ Star this repo if you believe technology can save lives!**

---

<p align="center">
  <i>Every mother deserves a safe pregnancy</i><br>
  <i>Every baby deserves a fighting chance</i><br>
  <i>Technology can bridge the gap</i>
</p>
