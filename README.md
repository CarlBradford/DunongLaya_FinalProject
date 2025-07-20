<div align="center">

# DunongLaya
**A Student Publication Platform for The AXIS with Integrated Data Analytics**

</div>

<div align="center">
  <img src="https://img.shields.io/badge/BSU-TNEU%20Alangilan-1f3a34?style=for-the-badge&labelColor=1f3a34&color=c9a44a" alt="BSU TNEU Alangilan"/>
  <img src="https://img.shields.io/badge/Flutter-3.32-1f3a34?style=for-the-badge&logo=flutter&logoColor=fdfff1&labelColor=1f3a34&color=c9a44a" alt="Flutter 3.32"/>
  <img src="https://img.shields.io/badge/Final%20Project-IT%20331%20%7C%20IT%20332-1f3a34?style=for-the-badge&labelColor=1f3a34&color=c9a44a" alt="Final Project"/>
  <img src="https://img.shields.io/badge/Status-Complete-1f3a34?style=for-the-badge&labelColor=1f3a34&color=c9a44a" alt="Complete"/>
</div>

---

## 📖 Overview

<div align="justify">

DunongLaya is a digital platform developed for **The AXIS**, the official student publication of Batangas State University – TNEU Alangilan Campus. The AXIS serves the university community by covering campus news, student activities, and academic developments through their annual print edition and digital content.

The platform addresses problems with social media publishing: limited content access, fragmented reading, and the lack of engagement tools. DunongLaya replaces this approach with a centralized digital system that complements their print edition, providing enhanced content management, detailed analytics, and improved reader interaction.

The platform serves as both a content management system for publication staff and an engaging reading experience for the university community.

</div>

## 🎯 Problem & Solution

**The Problem:**
The AXIS publishes an annual print edition but used social media platforms for digital content, which caused several issues:

- Digital articles were mixed with other posts, making them hard to find and organize
- No cohesive bridge between their print publication and digital presence 
- Limited analytics compared to dedicated publishing platforms
- Difficulty in building a professional digital archive that complements their print legacy

**The Solution:**
DunongLaya provides a dedicated digital platform that:

- Complements their annual print edition with professional digital presence
- Organizes all digital content in a searchable, publication-focused environment
- Provides detailed analytics specifically designed for publication needs
- Builds a permanent digital archive that enhances their established print tradition

## ✨ Features

### 🔧 For Administrators
- Full access to article management
- Access to analytics dashboard
- Manage publication staff accounts
- Supervise all platform operations

### 📝 For Publication Staff
- Secure login with role-based access
- Create, edit, delete, publish, and archive articles
- Access analytics dashboard with performance metrics
- Manage content workflow

### 👥 For Readers  
- Browse articles organized by categories
- Search articles by keywords
- Like, comment, save, and share articles
- Mobile and web responsive design

## 🏗️ System Architecture & Development

<div align="justify">

The platform operates with three user types designed for publication workflow:

- **Admins** supervise all platform operations
- **Publication Staff** control the article workflow and track performance data 
- **Readers** interact with published content

Built using **Agile Development Model** with iterative development cycles, allowing the team to adapt to changes and get feedback throughout the project. This approach was needed given the changing needs of student journalists and readers, unlike other models that require setting all requirements first and limit user feedback until the end.

</div>

## 💻 Technology Stack

<div align="justify">

- **Flutter SDK 3.32** for cross-platform development (Android and Web)
- **Mobile-first responsive design** ensuring accessibility across devices
- Chosen for rapid prototyping and single codebase deployment

Flutter was selected because it allowed the team to create both mobile and web versions simultaneously, crucial for reaching The AXIS's diverse readership across different devices and platforms.

</div>

## 🚀 Installation

### Prerequisites
- Flutter SDK 3.32 or higher
- VS Code with Flutter extensions
- Chrome browser (for web development)
- Git

### Setup Steps
```bash
# Clone repository
git clone https://github.com/memelll/DunongLaya.git
cd DunongLaya

# Install dependencies
flutter pub get

# Check Flutter setup
flutter doctor

# Run application
flutter run                 # Android
flutter run -d chrome       # Web

# Build for production
flutter build apk           # Android
flutter build web           # Web
```

### Troubleshooting
- Run `flutter doctor` to check for any missing dependencies
- Ensure Android emulator is running or device is connected for Android testing
- For web development, ensure Chrome is installed and set as default browser

## 🧪 Testing & Results

<div align="justify">

Completed comprehensive User Acceptance Testing with 16 test scenarios covering:

- Landing page and login functionality
- User and article management systems
- Analytics dashboard functionality  
- Reader interaction features (search, filter, like, comment, save, share)
- Gallery, About Us, and Contact Us sections
- Responsive design across mobile and web devices

**Result**: 100% pass rate across all test scenarios

The testing validated that DunongLaya successfully addresses the original problems with social media publishing, providing enhanced features for both content creators and readers.

</div>

## 👨‍💻 Development Team

<div align="center">

**IT 331 & IT 332 Final Project - Group 8**

</div>

<div align="justify">

This project represents the completion of Application Development and Emerging Technologies (IT 331) and Integrative Programming and Technologies (IT 332) coursework, demonstrating practical application of software development principles in solving real-world problems for student journalism.

</div>

<div align="center">

| Name | SR Code | Role |
|------|------------|--------|
| De Sagun, Carl Bradford M. | 22-06966 | Lead Developer |
| Lucero, Gio Kervin P. | 22-03412 | Lead Developer |
| Magnaye, Maria Lourdes M. | 22-03152 | Lead Developer |

**Instructors:** Mr. Jhon Glenn L. Manalo, Mr. Edbert Ocampo

</div>

---

<div align="center">
  <strong>© 2025 DunongLaya - The AXIS Student Publication Platform</strong><br>
  <em>Batangas State University - College of Informatics and Computing Sciences</em><br><br>
  
  [![BSU](https://img.shields.io/badge/Batangas%20State%20University-TNEU%20Alangilan-1f3a34?style=flat-square&labelColor=1f3a34&color=c9a44a)](https://www.batangas-state-university.edu.ph/)
  [![CICS](https://img.shields.io/badge/College%20of-Informatics%20%26%20Computing%20Sciences-1f3a34?style=flat-square&labelColor=1f3a34&color=c9a44a)](https://www.batangas-state-university.edu.ph/)
</div>
