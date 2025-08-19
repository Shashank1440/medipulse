-- Location: supabase/migrations/20250819052324_medipulse_auth_setup.sql
-- Schema Analysis: Fresh project - no existing schema
-- Integration Type: Complete authentication module setup
-- Dependencies: None (fresh project)

-- Extensions (already available in Supabase)
-- uuid-ossp, pgcrypto are pre-installed

-- 1. Create enums first
CREATE TYPE public.user_role AS ENUM ('admin', 'patient', 'caregiver');
CREATE TYPE public.profile_status AS ENUM ('active', 'inactive', 'pending');

-- 2. Core user profiles table (critical intermediary table for PostgREST compatibility)
CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL UNIQUE,
    phone TEXT UNIQUE,
    full_name TEXT NOT NULL,
    date_of_birth DATE,
    gender TEXT CHECK (gender IN ('male', 'female', 'other')),
    role public.user_role DEFAULT 'patient'::public.user_role,
    status public.profile_status DEFAULT 'active'::public.profile_status,
    avatar_url TEXT,
    emergency_contact_name TEXT,
    emergency_contact_phone TEXT,
    medical_conditions TEXT[],
    allergies TEXT[],
    current_medications TEXT[],
    preferred_language TEXT DEFAULT 'en',
    timezone TEXT DEFAULT 'UTC',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. User sessions for tracking login activity
CREATE TABLE public.user_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    device_info JSONB,
    ip_address INET,
    login_method TEXT CHECK (login_method IN ('email', 'phone_otp', 'oauth')),
    login_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    logout_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT true
);

-- 4. OTP verification table for mobile login
CREATE TABLE public.otp_verifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone TEXT NOT NULL,
    otp_code TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    attempts INTEGER DEFAULT 0,
    max_attempts INTEGER DEFAULT 3,
    verified BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 5. Essential indexes for performance
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_user_profiles_phone ON public.user_profiles(phone);
CREATE INDEX idx_user_profiles_role ON public.user_profiles(role);
CREATE INDEX idx_user_profiles_status ON public.user_profiles(status);
CREATE INDEX idx_user_sessions_user_id ON public.user_sessions(user_id);
CREATE INDEX idx_user_sessions_active ON public.user_sessions(user_id, is_active);
CREATE INDEX idx_otp_verifications_phone ON public.otp_verifications(phone);
CREATE INDEX idx_otp_verifications_expires ON public.otp_verifications(expires_at);

-- 6. Enable RLS on all tables
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.otp_verifications ENABLE ROW LEVEL SECURITY;

-- 7. Helper functions for authentication (MUST be before RLS policies)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
    user_phone TEXT;
    user_full_name TEXT;
BEGIN
    -- Extract phone and full name from metadata
    user_phone := COALESCE(NEW.raw_user_meta_data->>'phone', NEW.phone);
    user_full_name := COALESCE(
        NEW.raw_user_meta_data->>'full_name',
        NEW.raw_user_meta_data->>'name',
        split_part(NEW.email, '@', 1)
    );

    -- Insert into user_profiles
    INSERT INTO public.user_profiles (
        id, email, phone, full_name, role
    ) VALUES (
        NEW.id,
        NEW.email,
        user_phone,
        user_full_name,
        COALESCE((NEW.raw_user_meta_data->>'role')::public.user_role, 'patient'::public.user_role)
    );
    RETURN NEW;
END;
$$;

-- Function to clean up expired OTP codes
CREATE OR REPLACE FUNCTION public.cleanup_expired_otps()
RETURNS void
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM public.otp_verifications
    WHERE expires_at < CURRENT_TIMESTAMP;
END;
$$;

-- Function for OTP verification
CREATE OR REPLACE FUNCTION public.verify_otp(phone_number TEXT, otp_input TEXT)
RETURNS BOOLEAN
SECURITY DEFINER
LANGUAGE plpgsql
AS $$
DECLARE
    otp_record RECORD;
BEGIN
    -- Find valid OTP record
    SELECT * INTO otp_record
    FROM public.otp_verifications
    WHERE phone = phone_number 
    AND otp_code = otp_input
    AND expires_at > CURRENT_TIMESTAMP
    AND verified = false
    AND attempts < max_attempts
    ORDER BY created_at DESC
    LIMIT 1;

    IF NOT FOUND THEN
        -- Increment attempts for failed verification
        UPDATE public.otp_verifications
        SET attempts = attempts + 1
        WHERE phone = phone_number 
        AND expires_at > CURRENT_TIMESTAMP
        AND verified = false;
        
        RETURN false;
    END IF;

    -- Mark OTP as verified
    UPDATE public.otp_verifications
    SET verified = true
    WHERE id = otp_record.id;

    RETURN true;
END;
$$;

-- 8. RLS Policies using Pattern 1 (Core User Tables)
-- Pattern 1: Core user table - Simple, direct column reference
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for sessions
CREATE POLICY "users_manage_own_sessions"
ON public.user_sessions
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Pattern 4: Public read for OTP (needed for verification process)
CREATE POLICY "public_read_otp_for_verification"
ON public.otp_verifications
FOR SELECT
TO public
USING (true);

CREATE POLICY "public_insert_otp"
ON public.otp_verifications
FOR INSERT
TO public
WITH CHECK (true);

CREATE POLICY "public_update_otp_verification"
ON public.otp_verifications
FOR UPDATE
TO public
USING (true)
WITH CHECK (true);

-- 9. Triggers
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 10. Mock Data for Testing
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    patient_uuid UUID := gen_random_uuid();
BEGIN
    -- Create complete auth.users records for testing
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@medipulse.com', crypt('AdminPass123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Dr. Admin User", "phone": "+1234567890", "role": "admin"}'::jsonb, 
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, '+1234567890', '', '', null),
        (patient_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'patient@medipulse.com', crypt('PatientPass123!', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Patient", "phone": "+1987654321", "role": "patient"}'::jsonb,
         '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, '+1987654321', '', '', null);

    -- Add sample OTP for testing
    INSERT INTO public.otp_verifications (phone, otp_code, expires_at)
    VALUES 
        ('+1234567890', '123456', CURRENT_TIMESTAMP + INTERVAL '10 minutes'),
        ('+1987654321', '654321', CURRENT_TIMESTAMP + INTERVAL '10 minutes');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error during mock data insertion: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error during mock data insertion: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error during mock data insertion: %', SQLERRM;
END $$;

-- Comments for documentation
COMMENT ON TABLE public.user_profiles IS 'Core user profiles table - intermediary for auth.users to maintain PostgREST compatibility';
COMMENT ON TABLE public.user_sessions IS 'Tracks user login sessions and device information';
COMMENT ON TABLE public.otp_verifications IS 'Stores OTP codes for mobile phone verification';
COMMENT ON FUNCTION public.handle_new_user() IS 'Automatically creates user profile when new user signs up';
COMMENT ON FUNCTION public.verify_otp(TEXT, TEXT) IS 'Verifies OTP code for mobile authentication';
COMMENT ON FUNCTION public.cleanup_expired_otps() IS 'Removes expired OTP codes to maintain database cleanliness';