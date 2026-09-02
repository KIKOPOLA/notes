-- ======================
-- USERS TABLE
-- ======================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  name TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ======================
-- NOTES TABLE
-- ======================
CREATE TABLE IF NOT EXISTS notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT,
  is_archived BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ======================
-- INDEX
-- ======================
CREATE INDEX IF NOT EXISTS notes_user_id_idx ON notes(user_id);
CREATE INDEX IF NOT EXISTS notes_is_archived_idx ON notes(is_archived);

-- ======================
-- ENABLE RLS
-- ======================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- ======================
-- DROP OLD POLICY (BIAR GA TABRAKAN)
-- ======================
DROP POLICY IF EXISTS "Users can see own data" ON users;
DROP POLICY IF EXISTS "Users can create own data" ON users;
DROP POLICY IF EXISTS "Users can update own data" ON users;

DROP POLICY IF EXISTS "Users can see own notes" ON notes;
DROP POLICY IF EXISTS "Users can create own notes" ON notes;
DROP POLICY IF EXISTS "Users can update own notes" ON notes;
DROP POLICY IF EXISTS "Users can delete own notes" ON notes;

-- ======================
-- USERS POLICY (FIXED)
-- ======================

-- SELECT
CREATE POLICY "users_select_own"
ON users FOR SELECT
USING (auth.uid() = id);

-- INSERT (INI YANG PENTING)
CREATE POLICY "users_insert_own"
ON users FOR INSERT
WITH CHECK (auth.uid() = id);

-- UPDATE
CREATE POLICY "users_update_own"
ON users FOR UPDATE
USING (auth.uid() = id);

-- ======================
-- NOTES POLICY
-- ======================

CREATE POLICY "notes_select_own"
ON notes FOR SELECT
USING (user_id = auth.uid());

CREATE POLICY "notes_insert_own"
ON notes FOR INSERT
WITH CHECK (user_id = auth.uid());

CREATE POLICY "notes_update_own"
ON notes FOR UPDATE
USING (user_id = auth.uid());

CREATE POLICY "notes_delete_own"
ON notes FOR DELETE
USING (user_id = auth.uid());

-- ======================
-- AUTO UPDATE TIMESTAMP
-- ======================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- USERS TRIGGER
DROP TRIGGER IF EXISTS update_users_updated_at ON users;
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- NOTES TRIGGER
DROP TRIGGER IF EXISTS update_notes_updated_at ON notes;
CREATE TRIGGER update_notes_updated_at
BEFORE UPDATE ON notes
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();