-- Route public contact submissions through the rate-limited Edge Function.
DROP POLICY IF EXISTS "Anyone can submit contact messages" ON public.contact_messages;
DROP POLICY IF EXISTS "Anon can insert contact messages" ON public.contact_messages;
REVOKE INSERT ON public.contact_messages FROM anon, authenticated;

CREATE TABLE IF NOT EXISTS public.contact_submission_limits (
  fingerprint text NOT NULL,
  window_start timestamptz NOT NULL,
  attempts integer NOT NULL DEFAULT 0 CHECK (attempts >= 0),
  last_submitted_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (fingerprint, window_start)
);

ALTER TABLE public.contact_submission_limits ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.contact_submission_limits FROM anon, authenticated;

CREATE OR REPLACE FUNCTION public.register_contact_attempt(p_fingerprint text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_window timestamptz := date_trunc('hour', now());
  v_record public.contact_submission_limits%ROWTYPE;
BEGIN
  IF p_fingerprint IS NULL OR length(p_fingerprint) < 32 THEN
    RETURN false;
  END IF;

  SELECT * INTO v_record
  FROM public.contact_submission_limits
  WHERE fingerprint = p_fingerprint AND window_start = v_window
  FOR UPDATE;

  IF FOUND THEN
    IF v_record.attempts >= 5 OR v_record.last_submitted_at > now() - interval '60 seconds' THEN
      RETURN false;
    END IF;
    UPDATE public.contact_submission_limits
      SET attempts = attempts + 1, last_submitted_at = now()
      WHERE fingerprint = p_fingerprint AND window_start = v_window;
  ELSE
    INSERT INTO public.contact_submission_limits (fingerprint, window_start, attempts)
    VALUES (p_fingerprint, v_window, 1);
  END IF;
  RETURN true;
END;
$$;

REVOKE ALL ON FUNCTION public.register_contact_attempt(text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.register_contact_attempt(text) TO service_role;

-- Keep the limiter small without requiring a scheduled cleanup job.
CREATE INDEX IF NOT EXISTS idx_contact_submission_limits_window
  ON public.contact_submission_limits (window_start);
