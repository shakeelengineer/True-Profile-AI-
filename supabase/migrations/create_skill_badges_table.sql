-- Create skill_badges table for storing verified skill badges
CREATE TABLE IF NOT EXISTS skill_badges (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    skill_name TEXT NOT NULL,
    badge_type TEXT NOT NULL DEFAULT 'verified',
    score INTEGER NOT NULL,
    earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Ensure one badge per user per skill
    CONSTRAINT unique_user_skill UNIQUE (user_id, skill_name)
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_skill_badges_user_id ON skill_badges(user_id);
CREATE INDEX IF NOT EXISTS idx_skill_badges_skill_name ON skill_badges(skill_name);

-- Enable Row Level Security
ALTER TABLE skill_badges ENABLE ROW LEVEL SECURITY;

-- Create policies for skill_badges table
CREATE POLICY "Users can view their own badges"
    ON skill_badges FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own badges"
    ON skill_badges FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own badges"
    ON skill_badges FOR UPDATE
    USING (auth.uid() = user_id);

-- Create a function to automatically update updated_at timestamp
CREATE OR REPLACE FUNCTION update_skill_badges_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create a trigger to call the function before update
CREATE TRIGGER set_skill_badges_updated_at
    BEFORE UPDATE ON skill_badges
    FOR EACH ROW
    EXECUTE FUNCTION update_skill_badges_updated_at();

-- Add comment to the table
COMMENT ON TABLE skill_badges IS 'Stores verified skill badges earned by users through skill assessments';
