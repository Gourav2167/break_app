-- Create app_usage table for persistent tracking
CREATE TABLE IF NOT EXISTS public.usage_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    package_name TEXT NOT NULL,
    duration_seconds INTEGER NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT now(),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- Enable RLS
ALTER TABLE public.usage_events ENABLE ROW LEVEL SECURITY;

-- Policies
CREATE POLICY "Users can insert their own usage" 
ON public.usage_events FOR INSERT 
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view their own usage" 
ON public.usage_events FOR SELECT 
USING (auth.uid() = user_id);

-- Index for performance
CREATE INDEX IF NOT EXISTS idx_usage_events_user_id ON public.usage_events(user_id);
CREATE INDEX IF NOT EXISTS idx_usage_events_timestamp ON public.usage_events(timestamp);
