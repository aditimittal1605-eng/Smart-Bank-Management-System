-- SmartBank: run selected tests after creating all objects.
-- Run each operation only once unless you intentionally want to repeat it.

-- Deposit 1500 into Rahul's account:
BEGIN
  deposit_money(1001, 1500);
  COMMIT;
END;
/

-- Withdraw 500 from Priya's account:
BEGIN
  withdraw_money(1002, 500);
  COMMIT;
END;
/

-- Transfer 1000 from Rahul to Priya:
BEGIN
  transfer_money(1001, 1002, 1000);
  COMMIT;
END;
/

-- Current balances:
SELECT account_id, customer_name, account_type, balance
FROM bank_accounts ORDER BY account_id;

-- Transaction history:
SELECT transaction_id, account_id, transaction_type, amount, transaction_date, description
FROM bank_transactions ORDER BY transaction_id;

-- Audit log:
SELECT audit_id, account_id, old_balance, new_balance, change_date, action_description
FROM bank_audit_log ORDER BY audit_id;

-- Balance function:
SELECT get_balance(1001) AS current_balance FROM dual;

-- Explicit cursor output:
BEGIN
  show_transactions(1001);
END;
/

-- Expected error test: insufficient balance (uncomment to test separately)
-- BEGIN
--   withdraw_money(1001, 999999);
-- END;
-- /
