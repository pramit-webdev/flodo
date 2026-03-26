# 📝 Flodo Task Manager

[![Live App](https://img.shields.io/badge/Live-GitHub%20Pages-success?style=for-the-badge&logo=github)](https://pramit-webdev.github.io/flodo/)
[![Backend API](https://img.shields.io/badge/API-FastAPI%20(Render)-blue?style=for-the-badge&logo=fastapi)](https://flodo-backend.onrender.com)

A visually polished, full-stack Task Management application built to demonstrate clean architecture, robust state management, and seamless E2E integration.

---

## 🏗️ Project Overview

*   **Track**: Track A (The Full-Stack Builder)
*   **Stretch Goal**: Persistent Drag-and-Drop
*   **Tech Stack**:
    *   **Frontend**: Flutter (Material 3, Riverpod for State Management)
    *   **Backend**: Python (FastAPI)
    *   **Database**: Supabase (PostgreSQL)
    *   **CI/CD**: GitHub Actions (Frontend) & Render (Backend)

---

## ✨ Features

### Core Requirements
-   **Full CRUD**: Create, read, update, and delete tasks with ease.
-   **Network Resilience**: Simulated 2-second backend delay with active loading states and button disabling to prevent double-submissions.
-   **Draft Persistence**: Real-time saving of unfinished tasks to `shared_preferences`. Your work is restored even if you close the app.
-   **Blocked Task Logic**: Tasks "Blocked By" an incomplete task are visually greyed out and locked 🔒 until the dependency is marked as "Done".
-   **Search & Filter**: 
    -   Instant text search (debounced at 300ms).
    -   Status filtering (To-Do, In Progress, Done) via interactive chips.

### Stretch Goal: Persistent Drag-and-Drop
-   Users can reorder tasks by long-pressing and dragging.
-   The custom priority order is saved to the PostgreSQL database and persists across all devices and sessions.

---

## 🚀 Setup & Installation

### 1. Database Configuration (Supabase)
1.  Create a project on [Supabase.com](https://supabase.com/).
2.  Navigate to the **SQL Editor** and execute the script found in `backend/supabase_schema.sql`.

### 2. Backend Setup (FastAPI)
1.  Navigate to `/backend`.
2.  Install dependencies: `pip install -r requirements.txt`.
3.  Create a `.env` file from the `.env.example` template:
    ```env
    SUPABASE_URL=your_project_url
    SUPABASE_KEY=your_anon_key
    ```
4.  Launch the server: `python main.py`.

### 3. Frontend Setup (Flutter)
1.  Navigate to `/frontend`.
2.  Get packages: `flutter pub get`.
3.  (Optional) Update `baseUrl` in `lib/providers/task_provider.dart` to point to your local backend.
4.  Run: `flutter run -d chrome`.

### 🐳 Docker Setup (One Command)
Run the entire stack (Frontend + Backend) instantly:
```bash
docker-compose up --build
```
-   **Frontend**: `http://localhost:8080`
-   **Backend**: `http://localhost:8000`

---

## 🏛️ Architecture & Decisions

-   **Riverpod (Frontend)**: Chosen for its robust provider-based state management, making the "Blocked By" logic and Draft recovery extremely clean and reactive.
-   **FastAPI (Backend)**: Selected for its high performance and automatic validation via Pydantic.
-   **Supabase (Database)**: Used to provide a production-grade PostgreSQL database with zero setup time.
-   **Search Highlighting**: Implemented a custom `RichText` span generator to provide visual feedback during searches.

---

## 🤖 AI Usage Report

-   **Prompt Success**: Used AI to scaffold the initial Pydantic models and the complex `ReorderableListView` handling.
-   **The Fix**: Initially, the AI suggested using `allow_credentials=True` with `allow_origins=["*"]` in CORS settings, which is unsupported by browsers. I manually fixed this by setting `allow_credentials=False` to ensure cross-origin requests from GitHub Pages succeeded.
-   **Refinement**: Used AI to polish the Material 3 styling, specifically the staggered animations and custom choice chips.

---

## 🎥 Demo Video
[Link to Demo Video (Google Drive)](https://drive.google.com/your-video-link-here)
*Note: View access has been granted to nilay@flodo.ai*

---

**Built with ❤️ for the Flodo AI Assignment.**
