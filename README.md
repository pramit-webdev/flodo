# Flodo Task Manager

A visually polished, full-stack Task Management app built with Flutter (Frontend) and FastAPI (Backend) with Supabase PostgreSQL (Database).

## Track Chosen: Track A (The Full-Stack Builder)
## Stretch Goal: Persistent Drag-and-Drop (with Search Highlighting)

---

## 🚀 Setup Instructions

### 1. Database Setup (Supabase)
1. Create a free project on [Supabase](https://supabase.com/).
2. Go to the **SQL Editor** in your Supabase dashboard.
3. Copy the contents of `backend/supabase_schema.sql` and run it to create the `tasks` table and indexes.

### 2. Backend Setup (FastAPI)
1. Navigate to the `backend` directory:
   ```bash
   cd backend
   ```
2. Create a virtual environment and install dependencies:
   ```bash
   python3 -m venv venv
   source venv/bin/activate  # On Windows use `venv\Scripts\activate`
   pip install -r requirements.txt
   ```
3. Create a `.env` file based on `.env.example` and add your Supabase credentials:
   ```env
   SUPABASE_URL=your_supabase_project_url
   SUPABASE_KEY=your_supabase_anon_key
   ```
4. Run the backend server:
   ```bash
   python main.py
   ```
   The server will start at `http://localhost:8000`.

### 3. Frontend Setup (Flutter)
1. Navigate to the `frontend` directory:
   ```bash
   cd frontend
   ```
2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. (Optional) Update the `baseUrl` in `lib/providers/task_provider.dart` if your backend is hosted elsewhere.
4. Run the app:
   ```bash
   flutter run -d chrome  # Or your preferred device/emulator
   ```

---

## ✨ Features Implemented

- **Core Requirements**:
  - Full CRUD functionality for Tasks.
  - Form validation and 2-second simulated delay on Save/Update.
  - Loading states and button disabling to prevent double-submissions.
  - **Draft Persistence**: If you leave the creation screen, your title and description are saved locally and restored.
  - **Blocked Logic**: Tasks "Blocked By" another task are visually greyed out and show a lock icon until the blocker is marked as "Done".
  - **Search & Filter**: Real-time debounced search by title and filtering by status.

- **Stretch Goal & Polish**:
  - **Persistent Drag-and-Drop**: Reorder tasks by dragging them. The order index is saved to Supabase and persists.
  - **Search Highlighting**: Matching search text is highlighted in yellow within the task titles.
  - **Staggered Animations**: Lists and cards animate in smoothly.
  - **Material 3 Design**: Using modern Flutter UI components.

## 🤖 AI Usage Report
- **Prompts**: Used prompts to generate the initial Riverpod provider structure and the highlight logic for `RichText`.
- **Bad Code/Hallucination**: Initially, the AI suggested a simple `ReorderableListView` without handling the `newIndex` adjustment correctly (off-by-one error when dragging down). Fixed it by manual adjustment: `if (newIndex > oldIndex) newIndex -= 1;`.
- **Optimization**: AI helped in choosing `AsyncNotifierProvider` for better asynchronous state handling.

---

## 🎥 Demo Video
[Link to your demo video here]
*Note: Ensure view access is given to nilay@flodo.ai*
