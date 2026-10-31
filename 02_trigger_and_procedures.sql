-- SmartBank: trigger, procedures, and function
-- Run after 01_schema_and_sample_data.sql.

CREATE OR REPLACE TRIGGER trg_balance_audit
AFTER UPDATE OF balance ON bank_accounts
FOR EACH ROW
BEGIN
  IF :OLD.balance <> :NEW.balance THEN
    INSERT INTO bank_audit_log (audit_id, account_id, old_balance, new_balance, change_date, action_description)
    VALUES (audit_seq.NEXTVAL, :OLD.account_id, :OLD.balance, :NEW.balance, SYSDATE, 'Account balance updated');
  END IF;
END;
/

CREATE OR REPLACE PROCEDURE deposit_money(p_account_id IN NUMBER, p_amount IN NUMBER)
AS
BEGIN
  IF p_amount IS NULL OR p_amount <= 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Deposit amount must be greater than zero.');
  END IF;
  UPDATE bank_accounts SET balance = balance + p_amount WHERE account_id = p_account_id;
  IF SQL%ROWCOUNT = 0 THEN
    RAISE_APPLICATION_ERROR(-20002, 'Account number does not exist.');
  END IF;
  INSERT INTO bank_transactions (transaction_id, account_id, transaction_type, amount, description)
  VALUES (transaction_seq.NEXTVAL, p_account_id, 'DEPOSIT', p_amount, 'Cash deposit');
  DBMS_OUTPUT.PUT_LINE('Deposit completed successfully.');
END;
/

CREATE OR REPLACE PROCEDURE withdraw_money(p_account_id IN NUMBER, p_amount IN NUMBER)
AS
  v_balance NUMBER(12,2);
BEGIN
  IF p_amount IS NULL OR p_amount <= 0 THEN
    RAISE_APPLICATION_ERROR(-20003, 'Withdrawal amount must be greater than zero.');
  END IF;
  SELECT balance INTO v_balance FROM bank_accounts WHERE account_id = p_account_id FOR UPDATE;
  IF v_balance < p_amount THEN
    RAISE_APPLICATION_ERROR(-20004, 'Insufficient balance.');
  END IF;
  UPDATE bank_accounts SET balance = balance - p_amount WHERE account_id = p_account_id;
  INSERT INTO bank_transactions (transaction_id, account_id, transaction_type, amount, description)
  VALUES (transaction_seq.NEXTVAL, p_account_id, 'WITHDRAWAL', p_amount, 'Cash withdrawal');
  DBMS_OUTPUT.PUT_LINE('Withdrawal completed successfully.');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20005, 'Account number does not exist.');
END;
/

CREATE OR REPLACE PROCEDURE transfer_money(p_from_account IN NUMBER, p_to_account IN NUMBER, p_amount IN NUMBER)
AS
  v_balance NUMBER(12,2);
  v_target NUMBER;
BEGIN
  SAVEPOINT transfer_start;
  IF p_amount IS NULL OR p_amount <= 0 THEN
    RAISE_APPLICATION_ERROR(-20006, 'Transfer amount must be greater than zero.');
  END IF;
  IF p_from_account = p_to_account THEN
    RAISE_APPLICATION_ERROR(-20007, 'Source and destination accounts must differ.');
  END IF;
  SELECT balance INTO v_balance FROM bank_accounts WHERE account_id = p_from_account FOR UPDATE;
  SELECT account_id INTO v_target FROM bank_accounts WHERE account_id = p_to_account;
  IF v_balance < p_amount THEN
    RAISE_APPLICATION_ERROR(-20008, 'Insufficient balance for transfer.');
  END IF;
  UPDATE bank_accounts SET balance = balance - p_amount WHERE account_id = p_from_account;
  UPDATE bank_accounts SET balance = balance + p_amount WHERE account_id = p_to_account;
  INSERT INTO bank_transactions (transaction_id, account_id, transaction_type, amount, description)
  VALUES (transaction_seq.NEXTVAL, p_from_account, 'TRANSFER_OUT', p_amount, 'Transfer to account ' || p_to_account);
  INSERT INTO bank_transactions (transaction_id, account_id, transaction_type, amount, description)
  VALUES (transaction_seq.NEXTVAL, p_to_account, 'TRANSFER_IN', p_amount, 'Transfer from account ' || p_from_account);
  DBMS_OUTPUT.PUT_LINE('Transfer completed successfully.');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    ROLLBACK TO transfer_start;
    RAISE_APPLICATION_ERROR(-20009, 'Source or destination account does not exist.');
  WHEN OTHERS THEN
    ROLLBACK TO transfer_start;
    RAISE;
END;
/

CREATE OR REPLACE FUNCTION get_balance(p_account_id IN NUMBER)
RETURN NUMBER
AS
  v_balance NUMBER(12,2);
BEGIN
  SELECT balance INTO v_balance FROM bank_accounts WHERE account_id = p_account_id;
  RETURN v_balance;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RAISE_APPLICATION_ERROR(-20010, 'Account number does not exist.');
END;
/

CREATE OR REPLACE PROCEDURE show_transactions(p_account_id IN NUMBER)
AS
  CURSOR c_transactions IS
    SELECT transaction_id, transaction_type, amount, transaction_date, description
    FROM bank_transactions WHERE account_id = p_account_id ORDER BY transaction_id;
  v_id NUMBER;
  v_type VARCHAR2(20);
  v_amount NUMBER(12,2);
  v_date DATE;
  v_description VARCHAR2(200);
  v_found BOOLEAN := FALSE;
  v_account NUMBER;
BEGIN
  SELECT account_id INTO v_account FROM bank_accounts WHERE account_id = p_account_id;
  OPEN c_transactions;
  LOOP
    FETCH c_transactions INTO v_id, v_type, v_amount, v_date, v_description;
    EXIT WHEN c_transactions%NOTFOUND;
    v_found := TRUE;
    DBMS_OUTPUT.PUT_LINE('ID: ' || v_id || ' | Type: ' || v_type || ' | Amount: ' || v_amount ||
                         ' | Date: ' || TO_CHAR(v_date, 'DD-MON-YYYY') || ' | ' || v_description);
  END LOOP;
  CLOSE c_transactions;
  IF NOT v_found THEN DBMS_OUTPUT.PUT_LINE('No transactions found.'); END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF c_transactions%ISOPEN THEN CLOSE c_transactions; END IF;
    RAISE_APPLICATION_ERROR(-20011, 'Account number does not exist.');
  WHEN OTHERS THEN
    IF c_transactions%ISOPEN THEN CLOSE c_transactions; END IF;
    RAISE;
END;
/
