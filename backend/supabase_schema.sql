-- Create tasks table
CREATE TABLE IF NOT EXISTS tasks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    due_date TIMESTAMP WITH TIME ZONE NOT NULL,
    status TEXT NOT NULL DEFAULT 'To-Do' CHECK (status IN ('To-Do', 'In Progress', 'Done')),
    blocked_by_id UUID REFERENCES tasks(id) ON DELETE SET NULL,
    order_index INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for searching by title
CREATE INDEX IF NOT EXISTS idx_tasks_title ON tasks USING GIN (to_tsvector('english', title));

-- Index for filtering by status
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks (status);

-- Enable Row Level Security (RLS) if needed, but for this assignment, we'll keep it simple
-- ALTER TABLE tasks ENABLE ROW LEVEL SECURITY;
-- CREATE POLICY "Allow public access" ON tasks FOR ALL USING (true);
