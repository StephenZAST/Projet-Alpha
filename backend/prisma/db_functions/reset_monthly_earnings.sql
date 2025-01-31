-- Drop existing function if exists
DROP FUNCTION IF EXISTS reset_monthly_earnings();

-- Create function that returns number of updated rows
CREATE OR REPLACE FUNCTION public.reset_monthly_earnings()
RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_count integer;
BEGIN
    UPDATE affiliate_profiles
    SET 
        monthly_earnings = 0,
        updated_at = NOW()
    WHERE is_active = true
    RETURNING COUNT(*) INTO v_count;

    RETURN v_count;
END;
$$;

-- Grant necessary permissions
GRANT EXECUTE ON FUNCTION public.reset_monthly_earnings() TO service_role;
GRANT EXECUTE ON FUNCTION public.reset_monthly_earnings() TO authenticated;

-- Create a comment for the function
COMMENT ON FUNCTION public.reset_monthly_earnings() IS 'Resets monthly earnings for all active affiliates and returns the number of affiliates updated';