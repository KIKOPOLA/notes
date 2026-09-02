-- ======================
-- NOTE_MEDIA TABLE
-- ======================
CREATE TABLE IF NOT EXISTS note_media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  note_id UUID NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  media_type TEXT NOT NULL CHECK (media_type IN ('image', 'video', 'audio')),
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  file_url TEXT NOT NULL,
  file_size INTEGER,
  duration INTEGER CHECK (
    (media_type = 'image' AND duration IS NULL) OR 
    (media_type IN ('video', 'audio') AND duration IS NOT NULL AND duration > 0)
  ),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ======================
-- INDEX
-- ======================
CREATE INDEX IF NOT EXISTS note_media_note_id_idx ON note_media(note_id);
CREATE INDEX IF NOT EXISTS note_media_user_id_idx ON note_media(user_id);
CREATE INDEX IF NOT EXISTS note_media_type_idx ON note_media(media_type);

-- ======================
-- ENABLE RLS
-- ======================
ALTER TABLE note_media ENABLE ROW LEVEL SECURITY;

-- ======================
-- DROP OLD POLICY
-- ======================
DROP POLICY IF EXISTS "note_media_select_own" ON note_media;
DROP POLICY IF EXISTS "note_media_insert_own" ON note_media;
DROP POLICY IF EXISTS "note_media_update_own" ON note_media;
DROP POLICY IF EXISTS "note_media_delete_own" ON note_media;

-- ======================
-- NOTE_MEDIA POLICY
-- ======================

-- SELECT
CREATE POLICY "note_media_select_own"
ON note_media FOR SELECT
USING (user_id = auth.uid());

-- INSERT
CREATE POLICY "note_media_insert_own"
ON note_media FOR INSERT
WITH CHECK (user_id = auth.uid());

-- UPDATE
CREATE POLICY "note_media_update_own"
ON note_media FOR UPDATE
USING (user_id = auth.uid());

-- DELETE
CREATE POLICY "note_media_delete_own"
ON note_media FOR DELETE
USING (user_id = auth.uid());

-- ======================
-- AUTO UPDATE TIMESTAMP
-- ======================
DROP TRIGGER IF EXISTS update_note_media_updated_at ON note_media;
CREATE TRIGGER update_note_media_updated_at
BEFORE UPDATE ON note_media
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
