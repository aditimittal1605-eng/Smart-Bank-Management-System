-- SmartBank: schema and sample data
-- Run once in your Oracle schema. Do not rerun if objects already exist.

CREATE TABLE bank_accounts (
    account_id NUMBER PRIMARY KEY,
    customer_name VARCHAR2(100) NOT NULL,
    account_type VARCHAR2(20) NOT NULL,
    balance NUMBER(12,2) DEFAULT 0 NOT NULL,
    created_at DATE DEFAULT SYSDATE NOT NULL,
    CONSTRAINT chk_account_type CHECK (account_type IN ('SAVINGS','CURRENT')),
    CONSTRAINT chk_balance CHECK (balance >= 0)
);
CREATE SEQUENCE account_seq START WITH 1001 INCREMENT BY 1;

CREATE TABLE bank_transactions (
    transaction_id NUMBER PRIMARY KEY,
    account_id NUMBER NOT NULL,
    transaction_type VARCHAR2(20) NOT NULL,
    amount NUMBER(12,2) NOT NULL,
    transaction_date DATE DEFAULT SYSDATE,
    description VARCHAR2(200),
    CONSTRAINT fk_transaction_account FOREIGN KEY (account_id) REFERENCES bank_accounts(account_id),
    CONSTRAINT chk_transaction_amount CHECK (amount > 0),
    CONSTRAINT chk_transaction_type CHECK (transaction_type IN ('DEPOSIT','WITHDRAWAL','TRANSFER_IN','TRANSFER_OUT'))
);
CREATE SEQUENCE transaction_seq START WITH 1 INCREMENT BY 1;

CREATE TABLE bank_audit_log (
    audit_id NUMBER PRIMARY KEY,
    account_id NUMBER NOT NULL,
    old_balance NUMBER(12,2),
    new_balance NUMBER(12,2),
    change_date DATE DEFAULT SYSDATE,
    action_description VARCHAR2(100)
);
CREATE SEQUENCE audit_seq START WITH 1 INCREMENT BY 1;

INSERT INTO bank_accounts (account_id, customer_name, account_type, balance)
VALUES (account_seq.NEXTVAL, 'Rahul Sharma', 'SAVINGS', 10000);
INSERT INTO bank_accounts (account_id, customer_name, account_type, balance)
VALUES (account_seq.NEXTVAL, 'Priya Verma', 'SAVINGS', 5000);
INSERT INTO bank_accounts (account_id, customer_name, account_type, balance)
VALUES (account_seq.NEXTVAL, 'Aman Singh', 'CURRENT', 20000);
COMMIT;

SELECT * FROM bank_accounts ORDER BY account_id;
