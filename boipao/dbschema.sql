-- ==========================================
-- BOIPAO SUPABASE POSTGRESQL SCHEMA
-- ==========================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ==========================================
-- CUSTOM ENUMS
-- ==========================================
CREATE TYPE user_role AS ENUM ('user', 'admin');
CREATE TYPE verification_status AS ENUM ('pending', 'approved', 'rejected');
CREATE TYPE exam_type AS ENUM ('SSC', 'HSC', 'Other');
CREATE TYPE material_condition AS ENUM ('new', 'like_new', 'good', 'fair', 'poor');
CREATE TYPE material_status AS ENUM ('available', 'pending', 'claimed');
CREATE TYPE claim_status AS ENUM ('pending', 'approved', 'rejected', 'completed');


-- ==========================================
-- 1. PROFILES TABLE
-- Extends the default Supabase auth.users table
-- ==========================================
CREATE TABLE profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    role user_role DEFAULT 'user'::user_role NOT NULL,
    is_verified BOOLEAN DEFAULT false NOT NULL,
    location TEXT DEFAULT '',
    points INTEGER DEFAULT 0 NOT NULL,
    donations_count INTEGER DEFAULT 0 NOT NULL,
    claims_count INTEGER DEFAULT 0 NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Trigger to automatically create a profile when a new user signs up in Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, display_name)
  VALUES (new.id, new.email, split_part(new.email, '@', 1));
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();


-- ==========================================
-- 2. STUDENT VERIFICATIONS TABLE (Phase 3 & 7)
-- ==========================================
CREATE TABLE student_verifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    school_name TEXT NOT NULL,
    class_level TEXT NOT NULL,
    roll_number TEXT,
    id_card_image_url TEXT NOT NULL, -- URL to Supabase Storage
    status verification_status DEFAULT 'pending'::verification_status NOT NULL,
    reviewed_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);


-- ==========================================
-- 3. MATERIALS TABLE (Phase 5)
-- ==========================================
CREATE TABLE materials (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    donor_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    exam_type exam_type NOT NULL,
    subject TEXT NOT NULL,
    year TEXT,
    condition material_condition NOT NULL,
    location TEXT NOT NULL,
    image_urls TEXT[] DEFAULT '{}'::TEXT[], -- Array of Supabase Storage URLs
    status material_status DEFAULT 'available'::material_status NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);


-- ==========================================
-- 4. CLAIMS TABLE (Phase 8)
-- ==========================================
CREATE TABLE claims (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    material_id UUID REFERENCES materials(id) ON DELETE CASCADE NOT NULL,
    requester_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    status claim_status DEFAULT 'pending'::claim_status NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(material_id, requester_id) -- A user can only request a specific material once
);


-- ==========================================
-- 5. MESSAGES TABLE (Phase 9)
-- ==========================================
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    claim_id UUID REFERENCES claims(id) ON DELETE CASCADE NOT NULL,
    sender_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    receiver_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
    content TEXT NOT NULL,
    is_read BOOLEAN DEFAULT false NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);


-- ==========================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ==========================================
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE student_verifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE claims ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- PROFILES RLS
CREATE POLICY "Profiles are viewable by everyone" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

-- VERIFICATIONS RLS
CREATE POLICY "Users can view own verifications" ON student_verifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own verifications" ON student_verifications FOR INSERT WITH CHECK (auth.uid() = user_id);
-- Admins will need a specific policy or bypass RLS entirely to view/update all verifications

-- MATERIALS RLS
CREATE POLICY "Materials viewable by everyone" ON materials FOR SELECT USING (true);
CREATE POLICY "Donors can insert own materials" ON materials FOR INSERT WITH CHECK (auth.uid() = donor_id);
CREATE POLICY "Donors can update own materials" ON materials FOR UPDATE USING (auth.uid() = donor_id);
CREATE POLICY "Donors can delete own materials" ON materials FOR DELETE USING (auth.uid() = donor_id);

-- CLAIMS RLS
CREATE POLICY "Users can see own claims" ON claims FOR SELECT USING (auth.uid() = requester_id);
CREATE POLICY "Donors can see claims on their materials" ON claims FOR SELECT USING (
    auth.uid() IN (SELECT donor_id FROM materials WHERE id = material_id)
);
CREATE POLICY "Users can insert claims" ON claims FOR INSERT WITH CHECK (auth.uid() = requester_id);

-- MESSAGES RLS
CREATE POLICY "Users can see own messages" ON messages FOR SELECT USING (auth.uid() = sender_id OR auth.uid() = receiver_id);
CREATE POLICY "Users can insert messages" ON messages FOR INSERT WITH CHECK (auth.uid() = sender_id);


-- Storage Bucket policy (run this after creating a new public bucket called 'materials')
-- Allow authenticated users to upload files to the 'materials' bucket
CREATE POLICY "Allow authenticated uploads"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'materials');

-- Allow authenticated users to update or delete their own files
CREATE POLICY "Allow authenticated deletes"
ON storage.objects
FOR DELETE
TO authenticated
USING (bucket_id = 'materials' AND auth.uid() = owner);

-- Allow anyone to read files from the 'materials' bucket
CREATE POLICY "Allow public reads"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'materials');
