# Skills Verification Service Update - Implementation Guide

## Overview
The skills verification service has been updated with the following features:
1. ✅ Input field for users to enter any skill (one at a time)
2. ✅ Generates 10 relevant quiz questions per skill
3. ✅ Quiz questions from comprehensive skill-specific question banks
4. ✅ 80% passing criteria for badge awarding
5. ✅ Results stored in History & Integrity section
6. ✅ Verified badges displayed on user profile

## Changes Made

### Backend (Python/FastAPI)

#### 1. Quiz Generator Service (`backend/ats_service/utils/quiz_generator.py`)
- Created a comprehensive quiz generation service
- Supports 10+ skills: Python, JavaScript, Java, Flutter, React, Node.js, Data Science, Machine Learning, SQL, AWS
- Each skill has 10+ curated questions with multiple-choice answers
- Questions are randomized for variety
- Returns structured quiz data with passing score (80%)

#### 2. API Endpoint (`backend/ats_service/main.py`)
- Added POST `/generate-quiz` endpoint
- Accepts skill name and returns 10 questions
- Includes error handling and validation

**Endpoint Usage:**
```bash
POST http://localhost:8000/generate-quiz
Content-Type: application/json

{
  "skill": "Python",
  "num_questions": 10
}
```

**Response:**
```json
{
  "status": "success",
  "skill": "Python",
  "total_questions": 10,
  "passing_score": 80,
  "questions": [
    {
      "question": "What is...",
      "options": ["A", "B", "C", "D"],
      "answer": 1,
      "skill": "Python"
    }
  ]
}
```

### Flutter Frontend

#### 1. Quiz Service (`lib/features/skills/services/skill_quiz_service.dart`)
- Dart service to communicate with backend
- Handles API calls with proper error handling
- Configurable timeout (30 seconds)

#### 2. Updated Skill Verification Screen (`lib/features/skills/screens/skill_verification_screen.dart`)
**Features:**
- Text input field for skill entry
- Loading state while generating quiz
- 10 questions with progress tracking
- Score calculation and badge awarding logic
- Results screen with pass/fail feedback
- Option to test another skill or return to dashboard

**Passing Criteria:**
- Score ≥ 80% → Badge awarded + saved to profile
- Score < 80% → Score recorded, no badge

#### 3. Skill Badges Widget (`lib/features/skills/widgets/skill_badges_widget.dart`)
- Displays verified skill badges on profile
- Badge levels based on score:
  - 95%+ → Gold badge (🏆)
  - 90-94% → Silver badge (🎖️)
  - 80-89% → Standard badge (✓)
- Empty state for users with no badges yet

#### 4. Profile Screen Update
- Added "Verified Badges" section
- Displays all earned badges with scores
- Badges are sorted by most recent first

### Database

#### New Table: `skill_badges`
Created migration file: `supabase/migrations/create_skill_badges_table.sql`

**Schema:**
```sql
- id (UUID, Primary Key)
- user_id (UUID, Foreign Key to auth.users)
- skill_name (TEXT)
- badge_type (TEXT, default 'verified')
- score (INTEGER)
- earned_at (TIMESTAMP)
- Constraint: UNIQUE(user_id, skill_name)
```

**Features:**
- Row Level Security (RLS) enabled
- Users can only view/modify their own badges
- Automatic timestamp updates
- Prevents duplicate badges per skill (updates if score improves)

#### Updated Table: `verification_results`
Stores quiz attempt history with:
- Skill name
- Score percentage
- Pass/fail status
- Detailed feedback
- Attempt timestamp

## Setup Instructions

### 1. Apply Database Migration

**Option A: Using Supabase CLI**
```bash
cd supabase
supabase db reset
```

**Option B: Manual SQL Execution**
1. Go to Supabase Dashboard → SQL Editor
2. Copy contents of `supabase/migrations/create_skill_badges_table.sql`
3. Execute the SQL

### 2. Update Backend Dependencies

The quiz generator uses only Python standard library, so no new dependencies needed!

### 3. Restart Backend Server

```bash
cd backend/ats_service
python main.py
```

Server should show:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete.
```

### 4. Update Flutter App

**Install dependencies** (if using http package):
```bash
flutter pub get
```

**Update backend URL** in `lib/features/skills/services/skill_quiz_service.dart`:
- For local testing: `http://localhost:8000`
- For physical device: `http://YOUR_IP:8000`
- For deployed backend: `https://your-backend-url.com`

### 5. Run Flutter App

```bash
flutter run
```

## How It Works - User Flow

1. **Navigate to Skills Verification**
   - User goes to Skills section from dashboard
   
2. **Enter Skill**
   - User types any skill name (e.g., "Python", "React", "Flutter")
   - Clicks "GENERATE QUIZ" button
   
3. **Quiz Generation**
   - App shows loading indicator
   - Backend generates 10 relevant questions
   - Quiz starts automatically

4. **Take Quiz**
   - 10 multiple-choice questions
   - Progress bar shows completion
   - No time limit
   - Can cancel anytime

5. **View Results**
   - Score displayed as percentage
   - If ≥80%: "BADGE EARNED!" with trophy icon
   - If <80%: "ASSESSMENT COMPLETE" with encouragement
   
6. **Badge Storage**
   - If passed: Badge saved to `skill_badges` table
   - If already have badge: Updates only if new score is higher
   - All attempts saved to `verification_results` for history

7. **Profile Display**
   - Earned badges appear in "Verified Badges" section
   - Shows skill name and score percentage
   - Color-coded by performance level

## Supported Skills

The quiz generator includes question banks for:
- **Programming Languages:** Python, JavaScript, Java
- **Frameworks:** Flutter, React, Node.js
- **Data & AI:** Data Science, Machine Learning, SQL
- **Cloud:** AWS
- **Generic:** Any other skill (generates basic questions)

## Adding New Skills

To add more skill-specific questions:

1. Edit `backend/ats_service/utils/quiz_generator.py`
2. Add a new method like `_get_yourskill_questions()`
3. Create 10+ questions in the format:
```python
{
    'question': 'Your question?',
    'options': ['A', 'B', 'C', 'D'],
    'answer': 0,  # Index of correct answer (0-3)
    'skill': 'YourSkill'
}
```
4. Add mapping in `generate_questions_from_hf()` method
5. Restart backend

## Testing

### Test Quiz Generation API
```bash
curl -X POST http://localhost:8000/generate-quiz \
  -H "Content-Type: application/json" \
  -d '{"skill": "Python", "num_questions": 10}'
```

### Test in Flutter App
1. Open Skills Verification screen
2. Enter "Python"
3. Click "GENERATE QUIZ"
4. Answer all 10 questions
5. Check results screen
6. Navigate to Profile → should see badge if passed

## Troubleshooting

### Backend Issues

**Problem:** "Module not found: quiz_generator"
- **Solution:** Ensure file exists at `backend/ats_service/utils/quiz_generator.py`
- Restart Python server

**Problem:** "Connection refused"
- **Solution:** Check backend is running on port 8000
- For physical devices, use IP address instead of localhost

### Flutter Issues

**Problem:** "TimeoutException"
- **Solution:** 
  - Verify backend is running
  - Check URL in `skill_quiz_service.dart`
  - For Android emulator: use `10.0.2.2:8000` instead of `localhost:8000`

**Problem:** Database error when saving badges
- **Solution:** Apply the SQL migration to create `skill_badges` table

**Problem:** Badges not showing on profile
- **Solution:** 
  - Check if badges exist in database (Supabase Dashboard → Table Editor)
  - Verify RLS policies are applied
  - Check user is authenticated

## Future Enhancements (Optional)

1. **Hugging Face Integration**
   - Use actual Hugging Face datasets for dynamic question generation
   - Add API key configuration
   - Implement question caching

2. **Timed Quizzes**
   - Add countdown timer
   - Different difficulty levels

3. **Leaderboards**
   - Show top scorers per skill
   - Global rankings

4. **Badge Sharing**
   - Generate shareable badge images
   - Social media integration

5. **Skill Recommendations**
   - Suggest related skills based on completed assessments

## Notes

- **Question Quality:** Current questions are curated and skill-specific. For production, consider integrating with Hugging Face datasets API for dynamic question generation.
- **Scalability:** The current implementation uses in-memory question banks. For thousands of skills, consider database storage or external API.
- **Security:** The backend validates skill input to prevent injection attacks.
- **User Experience:** Users can retake quizzes to improve their score. Only the highest score is displayed on the profile.

## Summary

✅ **Input Field:** Users enter any skill name
✅ **10 Questions:** Each quiz has 10 relevant questions
✅ **80% Passing:** Must score 8/10 or higher to earn badge
✅ **Badge System:** Verified badges appear on profile
✅ **History:** All attempts saved in verification_results
✅ **Integrity:** RLS ensures users only see their own data

The system is now ready for testing! Users can verify their skills and earn badges to showcase on their profiles.
