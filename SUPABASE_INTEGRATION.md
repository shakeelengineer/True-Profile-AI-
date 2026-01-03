# 🚀 Next Steps: Supabase Integration

## 📋 Implementation Checklist

### Phase 1: Database Setup (Supabase)

#### 1. Create Tables

**profiles table:**
```sql
create table profiles (
  id uuid references auth.users primary key,
  email text,
  full_name text,
  phone text,
  bio text,
  avatar_url text,
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Enable RLS
alter table profiles enable row level security;

-- Policies
create policy "Users can view own profile"
  on profiles for select
  using (auth.uid() = id);

create policy "Users can update own profile"
  on profiles for update
  using (auth.uid() = id);
```

**verification_results table:**
```sql
create table verification_results (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users not null,
  verification_type text not null, -- 'identity', 'resume', 'skills'
  status text not null, -- 'pending', 'completed', 'rejected', 'not_started'
  score integer,
  data jsonb, -- Store type-specific data
  feedback text[],
  created_at timestamp with time zone default timezone('utc'::text, now()),
  updated_at timestamp with time zone default timezone('utc'::text, now())
);

-- Enable RLS
alter table verification_results enable row level security;

-- Policies
create policy "Users can view own verifications"
  on verification_results for select
  using (auth.uid() = user_id);

create policy "Users can insert own verifications"
  on verification_results for insert
  with check (auth.uid() = user_id);
```

**skill_assessments table:**
```sql
create table skill_assessments (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid references auth.users not null,
  skill_name text not null,
  score integer not null,
  total_questions integer not null,
  correct_answers integer not null,
  level text, -- 'beginner', 'intermediate', 'advanced'
  certificate_url text,
  created_at timestamp with time zone default timezone('utc'::text, now())
);

-- Enable RLS
alter table skill_assessments enable row level security;

create policy "Users can view own assessments"
  on skill_assessments for select
  using (auth.uid() = user_id);
```

#### 2. Storage Buckets

Create buckets in Supabase Storage:
- `avatars` - For profile pictures
- `resumes` - For resume files
- `identity-photos` - For verification photos
- `certificates` - For skill certificates

---

### Phase 2: Create Services

#### 1. Profile Service (`lib/features/profile/services/profile_service.dart`)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Get user profile
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return response;
  }

  // Update profile
  Future<void> updateProfile({
    required String userId,
    required String fullName,
    required String phone,
    required String bio,
  }) async {
    await _supabase.from('profiles').upsert({
      'id': userId,
      'full_name': fullName,
      'phone': phone,
      'bio': bio,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // Upload avatar
  Future<String> uploadAvatar(String userId, String filePath) async {
    final file = File(filePath);
    final fileName = '$userId-${DateTime.now().millisecondsSinceEpoch}';
    
    await _supabase.storage
        .from('avatars')
        .upload(fileName, file);
    
    return _supabase.storage.from('avatars').getPublicUrl(fileName);
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});
```

#### 2. Verification Service (`lib/features/verification/services/verification_service.dart`)

```dart
class VerificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Save verification result
  Future<void> saveVerification({
    required String userId,
    required String type,
    required String status,
    int? score,
    Map<String, dynamic>? data,
    List<String>? feedback,
  }) async {
    await _supabase.from('verification_results').insert({
      'user_id': userId,
      'verification_type': type,
      'status': status,
      'score': score,
      'data': data,
      'feedback': feedback,
    });
  }

  // Get all verifications for user
  Future<List<Map<String, dynamic>>> getVerifications(String userId) async {
    final response = await _supabase
        .from('verification_results')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Get verification by type
  Future<Map<String, dynamic>?> getVerificationByType(
    String userId,
    String type,
  ) async {
    final response = await _supabase
        .from('verification_results')
        .select()
        .eq('user_id', userId)
        .eq('verification_type', type)
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return response;
  }
}
```

#### 3. Skill Service (`lib/features/skills/services/skill_service.dart`)

```dart
class SkillService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Save skill assessment
  Future<void> saveAssessment({
    required String userId,
    required String skillName,
    required int score,
    required int totalQuestions,
    required int correctAnswers,
    required String level,
  }) async {
    await _supabase.from('skill_assessments').insert({
      'user_id': userId,
      'skill_name': skillName,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': correctAnswers,
      'level': level,
    });
  }

  // Get all assessments
  Future<List<Map<String, dynamic>>> getAssessments(String userId) async {
    final response = await _supabase
        .from('skill_assessments')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }
}
```

---

### Phase 3: Update Screens

#### Profile Screen Updates:
```dart
// Load profile on init
@override
void initState() {
  super.initState();
  _loadProfile();
}

Future<void> _loadProfile() async {
  final user = ref.read(authServiceProvider).currentUser;
  if (user != null) {
    final profile = await ref.read(profileServiceProvider).getProfile(user.id);
    if (profile != null) {
      setState(() {
        _nameController.text = profile['full_name'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _bioController.text = profile['bio'] ?? '';
      });
    }
  }
}

// Save profile
Future<void> _saveProfile() async {
  final user = ref.read(authServiceProvider).currentUser;
  if (user != null) {
    await ref.read(profileServiceProvider).updateProfile(
      userId: user.id,
      fullName: _nameController.text,
      phone: _phoneController.text,
      bio: _bioController.text,
    );
  }
}
```

#### Results Screen Updates:
```dart
// Load results on init
late Future<List<Map<String, dynamic>>> _verificationsFuture;

@override
void initState() {
  super.initState();
  _loadResults();
}

void _loadResults() {
  final user = ref.read(authServiceProvider).currentUser;
  if (user != null) {
    _verificationsFuture = ref
        .read(verificationServiceProvider)
        .getVerifications(user.id);
  }
}

// Use FutureBuilder in build
FutureBuilder<List<Map<String, dynamic>>>(
  future: _verificationsFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }
    
    if (snapshot.hasError) {
      return Center(child: Text('Error loading results'));
    }
    
    final verifications = snapshot.data ?? [];
    return _buildResultsList(verifications);
  },
)
```

---

### Phase 4: AI Integration (Optional)

#### Setup Edge Functions:

1. **Face Verification:**
```typescript
// supabase/functions/verify-identity/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { images, userId } = await req.json()
  
  // Call face recognition API
  // Compare images
  // Return verification result
  
  return new Response(
    JSON.stringify({ verified: true, confidence: 0.95 }),
    { headers: { "Content-Type": "application/json" } },
  )
})
```

2. **Resume Analysis:**
```typescript
// supabase/functions/analyze-resume/index.ts
serve(async (req) => {
  const { resumeText, userId } = await req.json()
  
  // Call OpenAI/Gemini for analysis
  // Calculate ATS score
  // Generate feedback
  
  return new Response(
    JSON.stringify({ 
      score: 85, 
      feedback: [...],
    }),
    { headers: { "Content-Type": "application/json" } },
  )
})
```

3. **Quiz Generation:**
```typescript
// supabase/functions/generate-quiz/index.ts
serve(async (req) => {
  const { skill, difficulty } = await req.json()
  
  // Generate questions using AI
  
  return new Response(
    JSON.stringify({ questions: [...] }),
    { headers: { "Content-Type": "application/json" } },
  )
})
```

---

### Phase 5: Real-time Updates

Add realtime subscriptions:

```dart
// Listen to verification updates
void _subscribeToVerifications() {
  final user = ref.read(authServiceProvider).currentUser;
  if (user != null) {
    _supabase
        .from('verification_results')
        .stream(primaryKey: ['id'])
        .eq('user_id', user.id)
        .listen((data) {
          // Update UI when verification status changes
          setState(() {
            // Refresh data
          });
        });
  }
}
```

---

### Phase 6: Testing

#### Manual Tests:
- [ ] Create account and verify profile creation
- [ ] Update profile information
- [ ] Upload identity photos
- [ ] Upload and analyze resume
- [ ] Complete skill quiz
- [ ] View results on results screen
- [ ] Check real-time updates
- [ ] Logout and login to verify persistence

#### Edge Cases:
- [ ] Network errors
- [ ] Invalid file uploads
- [ ] Concurrent updates
- [ ] Missing data handling

---

### Phase 7: Production Preparation

1. **Environment Variables:**
   - Move Supabase keys to environment variables
   - Use different projects for dev/prod

2. **Error Tracking:**
   - Integrate Sentry or similar
   - Log API errors

3. **Analytics:**
   - Track user flows
   - Monitor feature usage

4. **Performance:**
   - Optimize image uploads
   - Cache profile data
   - Implement pagination

---

## 🎯 Quick Start Implementation Order

1. ✅ **Week 1:** Database setup + Profile service
2. ✅ **Week 2:** Verification service + Identity flow
3. ✅ **Week 3:** Resume analysis integration
4. ✅ **Week 4:** Skills quiz + Results screen
5. ✅ **Week 5:** Testing + Polish
6. ✅ **Week 6:** Production deployment

---

## 📚 Resources

- [Supabase Docs](https://supabase.com/docs)
- [Flutter Supabase Package](https://pub.dev/packages/supabase_flutter)
- [Riverpod Docs](https://riverpod.dev/)
- [Go Router Guide](https://pub.dev/packages/go_router)

---

**Ready to connect your app to Supabase? Start with Phase 1! 🚀**
