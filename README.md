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

### 4. Monorepo & Cloud Deployment (E2E)

The easiest way to deploy this monorepo to free online resources (like **Railway**, **Koyeb**, or **Render**) is using the provided Docker configuration.

#### Using Docker Compose (Local Testing)
If you have Docker installed, you can run the whole stack with one command:
```bash
docker-compose up --build
```
- Frontend: `http://localhost:8080`
- Backend: `http://localhost:8000`

#### Deploying to Railway/Render (Free)
1.  **Push to GitHub**: Push the entire folder (with `backend/` and `frontend/` and `docker-compose.yml`).
2.  **Add Services**:
    -   On **Railway**: Click "New Project" -> "GitHub Repo". Railway will detect the `docker-compose.yml` or the sub-directories automatically.
    -   On **Render**: Create two "Web Services". 
        -   **Backend**: Set "Root Directory" to `backend`. Render will use the `Dockerfile` inside.
        -   **Frontend**: Set "Root Directory" to `frontend`. Render will use the `Dockerfile` inside.
3.  **Configure `.env`**: In the platform's dashboard, add your `SUPABASE_URL` and `SUPABASE_KEY` as environment variables for the backend service.
4.  **Update Base URL**: Ensure the `baseUrl` in `frontend/lib/providers/task_provider.dart` points to your *deployed* backend URL.

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
