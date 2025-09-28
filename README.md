# 🧘 Sahaayak: Mental Wellness Companion for Students 
🌐 Cross-Platform Mobile Application | Mental Health Tech | Supabase & Gemini AI

## 🎯 Project Overview & Mission

**Sahayaak** (meaning 'Helper') is a dedicated mobile application built to provide accessible and proactive mental health support for university students in India.

This project demonstrates expertise in building a **data-driven, full-stack mobile application** utilizing Flutter's UI capabilities and Supabase's robust backend services. It uniquely integrates Google's **Gemini AI** for context-aware conversational support.

### Key Features Implemented

| Feature Area | Functionality Demonstrated | Keywords for Recruiters |
| :--- | :--- | :--- |
| **Authentication & UX** | Secure login/signup, session management via Supabase, and a custom animated splash screen. | Secure Auth, Session Management, UI/UX, State Handling |
| **AI Chat Assistance** | Integrated **Gemini API** for context-aware chat. Uses a **System Prompt** for persona fine-tuning (warm tone, scope control), eliminating boilerplate responses. | Conversational AI, Prompt Engineering, API Integration, Custom Chat UI |
| **Wellness Resources Hub** | Dynamic display of **Articles, Videos (YouTube), and Audio** content. Includes robust filtering, searching, and featured content highlighting. | Dynamic Data Fetching, Filtering Logic, REST API, Content Management |
| **Support & Tracking** | **Mood Logging** (5-level scale) and a visual **Mood Trends Tracker** (GitHub contribution calendar style) for longitudinal analysis. | Data Visualization, Behavioral Tracking, Health Tech, Data Modeling |
| **Peer Connectivity** | Hardcoded, clickable Google Meet links within peer groups, establishing a simple pathway for social support sessions. | Real-time Communication (Placeholder), External Service Integration |

-----

## 🛠️ Tech Stack & Architecture

This application is built using a modern, scalable **TALL Stack** approach for mobile development (Tailwind CSS/Alpine.js/Laravel/Livewire concept adapted for mobile):

### Frontend

  * **Framework:** **Flutter** (Dart)
  * **UI/UX:** Custom theming with the main colors set to a professional green palette.
  * **State Management:** Standard Flutter `StatefulWidget` and component-level state for simplicity and performance.

### Backend & Services

  * **Backend as a Service (BaaS):** **Supabase** (PostgreSQL)
      * **Data Models:** `wellness_resources` (for content) and `mood_logs` (for user tracking).
      * **Auth:** Handles user signup, login, and session persistence.
  * **AI Integration:** **Gemini API** (Google)
  * **Video Playback:** **YouTube Player Flutter** package.
  * **Networking/Caching:** `supabase_flutter`, `cached_network_image`.

### Architecture Highlights

The app utilizes the **AppShell Architecture** in `main.dart` to provide a persistent, clean `BottomNavigationBar` that manages five distinct screens, ensuring a smooth, single-activity mobile experience.

-----

## 🚀 Getting Started

Follow these instructions to get Sahayaak up and running on your local machine.

### Prerequisites

1.  **Flutter SDK** (Latest stable channel recommended)
2.  **Git**
3.  **Supabase Account** (For URL and Anon Key)
4.  **Gemini API Key** (For the Chat feature)

### 1\. Setup & Installation

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
cd sahaayak

# Install Flutter dependencies
flutter pub get
```

### 2\. Configure Environment

  * **Supabase:** Update the `main.dart` file with your project credentials:
    ```dart
    await Supabase.initialize(
      url: 'YOUR_SUPABASE_URL',
      anonKey: 'YOUR_SUPABASE_ANON_KEY',
    );
    ```
  * **Gemini API:** Update the `chat_page.dart` file with your API key:
    ```dart
    const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
    ```

### 3\. Run the Application

```bash
# Build and run the app on a connected device or emulator
flutter run
```

-----

## 📸 Screenshots & Visuals

<p float="left">
  <img src="https://github.com/user-attachments/assets/d88bc540-0901-4ad9-aa4b-d617ce83b04c" width="220" />
  <img src="https://github.com/user-attachments/assets/f529a133-8625-473b-9e29-68daa6ac15ba" width="220" />
  <img src="https://github.com/user-attachments/assets/cdd1debe-b392-423c-8087-b2609c49b90c" width="220" />
</p>

<p float="left">
  <img src="https://github.com/user-attachments/assets/0aef4f88-869b-4053-b387-977e9ad18033" width="220" />
  <img src="https://github.com/user-attachments/assets/f6a14cbf-5ef8-4281-8014-29964cbc329b" width="220" />
  <img src="https://github.com/user-attachments/assets/3d2ca2be-a719-4ee3-81a6-86a0ee67d994" width="220" />
</p>

-----

## 💡 Learning & Development Showcase

This project served as a comprehensive exploration of key development challenges:

  * **Complex Navigation:** Successfully implemented the **AppShell Pattern** to manage the `BottomNavigationBar` and inter-page routing cleanly.
  * **Asynchronous Data Handling:** Managed state and UI updates using `FutureBuilder` to handle data retrieval from Supabase in the background (Resources and Moods).
  * **API Syntax Migration:** Successfully adapted to changes in the `supabase-flutter` package, removing the deprecated `.execute()` call.
  * **UX/Branding:** Designed and implemented a custom, symbolic logo and applied consistent theming.

-----

## 🤝 Contribution & License

Contributions are welcome\! Please feel free to open issues or submit pull requests.
