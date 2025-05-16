# SmartCare - Health Management System

![SmartCare Logo](https://via.placeholder.com/150) <!-- Replace with actual logo -->

SmartCare is a comprehensive health management platform consisting of a mobile app for patients and a web dashboard for healthcare providers.

## Table of Contents
- [Features](#features)
- [Installation](#installation)
- [Project Structure](#project-structure)
- [License](#license)

## Features

### Mobile Application (Patient)
- **Health Reports**: View and manage ECG and other health reports
- **AI Chatbot**: Get instant health advice via integrated AI
- **Doctor & Patient Details**: Access doctor information and manage your profile
- **Notifications**: Receive alerts for new reports and doctor suggestions
- **Secure Data**: End-to-end encryption for all health information

### Web Dashboard (Healthcare Providers)
- **Hospital Dashboard**: Manage smart holter monitors and device assignments
- **Admin Panel**: Register hospitals/doctors and manage system operations
- **Doctor Portal**: 
  - Manage patient lists and assign devices
  - Generate detailed health reports
- **AI Assistance**: 
  - AI-powered report suggestions
  - Anomaly detection from ML models
- **Patient Management**: 
  - Track patient status
  - View historical data
  - Manage emergency contacts

## Installation

### Mobile App (Flutter)

1. **Install Flutter**  
   Follow the official [Flutter Installation Guide](https://flutter.dev/docs/get-started/install)

2. **Clone the repository**
   ```bash
   git clone https://github.com/your-repo/smartcare.git
   cd smartcare/mobile_app
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Web Dashboard (Next.js)

1. **Install Node.js**  
   Download from [Node.js Official Site](https://nodejs.org/)

2. **Clone the repository**
   ```bash
   git clone https://github.com/your-repo/smartcare.git
   cd smartcare/web
   ```

3. **Install dependencies**
   ```bash
   npm install
   # or
   yarn install
   ```

4. **Run the app**
   ```bash
   npm run dev
   # or
   yarn dev
   ```

5. **Access the dashboard**  
   Open `http://localhost:3000` in your browser

## Project Structure

```
smartcare/
├── mobile_app/          # Flutter mobile application
│   ├── lib/             # Application source code
│   ├── assets/          # Static files
│   └── ...              
│
├── web/                 # Next.js web application
│   ├── components/      # React components
│   ├── pages/           # Application routes
│   └── ...              
│
├── LICENSE
└── README.md
```

## License

This project is for educational and research purposes. Please contact the authors for commercial use.

For more details, see the respective `README.md` files in each subdirectory.

---

**Contact**: team@smartcare.example.com  
**Version**: 1.0.0
