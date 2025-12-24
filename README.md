# 🤱 MamaCare Butler

> Your AI-powered maternal health companion - Built for Kenyan mothers

[![Flutter](https://img.shields.io/badge/Flutter-3.32+-02569B?logo=flutter)](https://flutter.dev)
[![Serverpod](https://img.shields.io/badge/Serverpod-3.1+-orange)](https://serverpod.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**🏆 Built for:** [Flutter Butler with Serverpod Hackathon](https://serverpod-flutter-hackathon.devpost.com/)  
**🛠️ Tech Stack:** Flutter + Serverpod + Gemini AI + FHIR + WhatsApp Business API

---

## 🎯 The Problem

In Kenya:
- **342 maternal deaths** per 100,000 live births
- **70% of complications** are preventable with early detection
- **Poor medication adherence**: Many mothers forget prenatal vitamins
- Most mothers only see healthcare providers **once per month**
- Medical information is often **confusing and inaccessible**
- **Paper-based records** are easily lost or damaged

---

## 💡 Our Solution

**MamaCare Butler** is a mobile app that acts as a **personal midwife available 24/7**, helping pregnant mothers:

- �� Monitor their health daily with AI-powered analysis
- 💊 Never miss medication with WhatsApp reminders
- 🔬 Understand medical reports in simple language
- 🚨 Detect warning signs early
- 📚 Learn about pregnancy week-by-week
- 🏥 Track all clinic visits and tests
- 👶 Monitor baby's movements and patterns

---

## ✨ Core Features

### 💊 WhatsApp Medication Reminders ⭐ NEW!
- **Daily WhatsApp messages** for medication reminders
- Folic acid, iron tablets, antimalarials
- **Two-way interaction**: Reply to confirm taken
- Personalized timing (morning/evening)
- Streak tracking & encouragement
- Works even without app installed!

**Example WhatsApp Message:**
```
🤱 MamaCare Reminder

Good morning Mama! 

💊 Time for your medications:
✓ Folic acid (1 tablet)
✓ Iron tablet (1 tablet)

Reply "DONE" when taken
Reply "SKIP" if already taken
Reply "HELP" for assistance

Your streak: 12 days! 🔥
Keep it up mama! 💪
```

### 🤖 AI Weekly Health Check-ins
- Gemini-powered symptom analysis
- Pre-eclampsia risk detection
- Gestational diabetes screening
- Personalized recommendations
- Emergency detection & alerts

### 🔬 Ultrasound Translator
- Scan medical reports with camera
- AI extracts measurements (BPD, FL, HC, AC)
- Converts medical jargon to simple Swahili/English
- Tracks baby's growth over time
- Percentile charts & growth curves

### 👣 Smart Kick Counter
- Easy one-tap kick recording
- AI pattern detection
- Declining movement alerts
- Visual analytics dashboard
- Session-based tracking

### 🚨 Emergency SOS
- One-tap emergency alert
- Auto-notifies emergency contacts via SMS & WhatsApp
- GPS location sharing
- Navigate to nearest hospital
- Direct call to emergency services

### 📚 Educational Hub
- Week-by-week pregnancy guide
- Nutrition advice (local Kenyan foods: sukuma wiki, ugali, etc.)
- Warning signs education
- Danger sign recognition
- Available in Swahili & English
- Voice narration for low-literacy users

### 📋 ANC Visit Tracker
- Track all 8 WHO-recommended visits
- Pre-visit checklists
- Store test results (blood, urine, ultrasound)
- Medication prescriptions
- QR code for data sharing with doctors
- Integration-ready with KenyaEMR/mChanjo

### 📱 Multi-Channel Notifications
- **In-app notifications** (push notifications)
- **SMS notifications** (for feature phones)
- **WhatsApp messages** (most preferred in Kenya)
- Offline-capable (queues when no internet)

---

## 🏗️ Architecture
```
mamacare-butler/
├── mamacare_server/     
│   ├── endpoints/       
│   ├── protocols/        
│   ├── services/         
│   └── scheduled/       
├── mamacare_client/     
├── mamacare_flutter/     
├── docs/                 
```

### Tech Stack

**Frontend:**
- Flutter 3.32+ (cross-platform: Android, iOS, Web)
- Riverpod (state management)
- SQLite (offline storage)
- Camera, GPS, local notifications

**Backend:**
- Serverpod 3.1+ (Dart backend framework)
- PostgreSQL (primary database)
- Redis (caching & job queue)
- FHIR-compliant data models

**AI/ML:**
- Gemini AI (symptom analysis, OCR, risk assessment)
- Statistical algorithms (kick patterns, trend detection)

**Integrations:**
- **WhatsApp Business API** (medication reminders)
- **Africa's Talking** (SMS gateway)
- Google Maps API (location services)
- Firebase Cloud Messaging (push notifications)


---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.32+
- Dart SDK 3.8+
- Serverpod CLI 3.1+
- PostgreSQL 14+
- Android Studio / VS Code / IntelliJ IDEA
- WhatsApp Business Account (optional for testing)

### Installation
```bash
# Clone repository
git clone git@github.com:its-kios09/mamacare-butler.git

cd mamacare-butler

# Setup backend
cd mamacare_server
cp .env.example .env

# Edit .env with your API keys
dart pub get
serverpod generate

# Setup Flutter app
cd ../mamacare_flutter
flutter pub get
flutter run

```
---

## 📱 Screenshots

_Coming soon..._

---

## 🎥 Demo Video

_Coming soon..._

---

## 🏆 Hackathon Submission

### Innovation
**First AI-powered maternal health assistant specifically designed for African mothers**, combining:
- Local context (Swahili language, Kenyan foods, healthcare system)
- Cutting-edge AI (Gemini for risk assessment)
- **WhatsApp integration** (most-used platform in Kenya)
- Offline-first architecture (works in rural areas)

### Technical Excellence
- ✅ Flutter + Serverpod full-stack implementation
- ✅ Gemini AI for intelligent health analysis
- ✅ FHIR-compliant data models (healthcare standard)
- ✅ Offline-first with background sync
- ✅ Real-time emergency response
- ✅ Multi-channel notifications (WhatsApp, SMS, Push)
- ✅ Statistical ML for pattern detection

### Impact

**Lives Saved:**
- Early detection of pre-eclampsia → prevent maternal death
- Medication adherence → reduce anemia, prevent neural tube defects
- Kick pattern monitoring → detect fetal distress → prevent stillbirth
- Emergency SOS → faster response times

**Healthcare Improved:**
- Better-informed patients → better decisions
- Complete medical records → better care continuity
- Reduced unnecessary ER visits → cost savings
- More completed ANC visits → better outcomes

**Scale Potential:**
- **1.5M+ pregnancies/year** in Kenya
- **50M+ women** in reproductive age in East Africa
- Can adapt to other countries
- B2C + B2B model (individuals + counties/NGOs)

**Measurable Metrics:**
- Medication adherence rate
- ANC visit completion rate
- Emergency response time
- Maternal mortality reduction

---

## 🌍 Social Impact

**UN Sustainable Development Goals:**
- SDG 3: Good Health and Well-being
- SDG 5: Gender Equality
- SDG 10: Reduced Inequalities

**Alignment with:**
- Kenya Vision 2030 (healthcare pillar)
- WHO Safe Motherhood Initiative
- Bill & Melinda Gates Foundation priorities

---


## 📄 License

MIT License - See [LICENSE](LICENSE) file for details

---

## 👨‍�� Author

**Fredrick Kioko Kilonzo** ([@its-kios09](https://github.com/its-kios09))

Healthcare software developer specializing in:
- **KenyaEMR** (Electronic Medical Records) - 100K+ patient records
- **mChanjo** (Immunization system) - 50+ counties
- **FHIR integration** for interoperability
- **OpenMRS/Bahmni** implementations
- **DigiHMIS** development

*Built as a new father who wants every mother to have a safe pregnancy.* ❤️

---

## 🙏 Acknowledgments

- **Serverpod Team** - For the amazing backend framework and hackathon
- **Google** - For Gemini AI credits
- **Kenya Ministry of Health** - For the opportunity to serve

---

## 📞 Contact

- GitHub: [@its-kios09](https://github.com/its-kios09)
- Email: legacyitsolution@gmail.com
- Devpost: [MamaCare Butler](https://devpost.com/software/mamacare-butler)
- LinkedIn: [Kioko Kilonzo](https://www.linkedin.com/in/fredrick-kioko-506550171/)

---


**⭐ Star this repo if you believe technology can save lives!**

---

<p align="center">
  <i>Every mother deserves a safe pregnancy</i><br>
  <i>Every baby deserves a fighting chance</i><br>
  <i>Technology can bridge the gap</i>
</p>
