-- Skema Database & RLS untuk Aplikasi Direktori Wisata Daerah
-- Jalankan skrip ini di Supabase SQL Editor.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE IF NOT EXISTS public.destinations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL,
  district text NOT NULL,
  address text NOT NULL,
  description text NOT NULL,
  ticket_price integer NOT NULL DEFAULT 0 CHECK (ticket_price >= 0),
  ticket_notes text,
  opening_hours text NOT NULL,
  facilities text[] NOT NULL DEFAULT '{}',
  accessibility_vehicle text NOT NULL,
  accessibility_notes text NOT NULL,
  image_url text NOT NULL,
  latitude double precision,
  longitude double precision,
  google_maps_url text,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_destinations_active_category
  ON public.destinations (is_active, category);

CREATE INDEX IF NOT EXISTS idx_destinations_name
  ON public.destinations (name);

-- Aktifkan Row Level Security (RLS)
ALTER TABLE public.destinations ENABLE ROW LEVEL SECURITY;

-- Policy Read-Only publik untuk aplikasi mobile (role anon & authenticated)
DROP POLICY IF EXISTS "Allow public read active destinations" ON public.destinations;
CREATE POLICY "Allow public read active destinations"
  ON public.destinations
  FOR SELECT
  TO anon, authenticated
  USING (is_active = true);

-- Bucket Storage untuk foto destinasi (upload dilakukan admin lewat Supabase Dashboard)
INSERT INTO storage.buckets (id, name, public)
VALUES ('destination-images', 'destination-images', true)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "Public read destination images" ON storage.objects;
CREATE POLICY "Public read destination images"
  ON storage.objects
  FOR SELECT
  TO anon, authenticated
  USING (bucket_id = 'destination-images');
