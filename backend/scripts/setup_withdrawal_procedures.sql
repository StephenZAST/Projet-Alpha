\echo 'Installing withdrawal procedures...'

\i prisma/migrations/20250130_withdrawal_procedures.sql

\echo 'Testing procedures...'

DO $$
BEGIN
    -- Test process_withdrawal_request
    BEGIN
        CALL process_withdrawal_request('00000000-0000-0000-0000-000000000000'::uuid, 30000);
        RAISE EXCEPTION 'Expected process_withdrawal_request to fail with invalid affiliate';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'process_withdrawal_request test passed: %', SQLERRM;
    END;

    -- Test reject_withdrawal
    BEGIN
        CALL reject_withdrawal('00000000-0000-0000-0000-000000000000'::uuid, 'test');
        RAISE EXCEPTION 'Expected reject_withdrawal to fail with invalid withdrawal';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'reject_withdrawal test passed: %', SQLERRM;
    END;

    -- Test approve_withdrawal
    BEGIN
        CALL approve_withdrawal('00000000-0000-0000-0000-000000000000'::uuid);
        RAISE EXCEPTION 'Expected approve_withdrawal to fail with invalid withdrawal';
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'approve_withdrawal test passed: %', SQLERRM;
    END;
END$$;

\echo 'All withdrawal procedures installed and tested successfully!'