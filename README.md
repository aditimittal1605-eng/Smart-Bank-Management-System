file:///C:/Users/Aditi/Desktop/pl%20sql%20project/index.html
# SmartBank — Banking Management System (PL/SQL)

An MCA database project demonstrating Oracle SQL/PLSQL concepts with a responsive banking dashboard frontend.

## Features
- Account dashboard and sample customer accounts
- Deposit, withdrawal, and transfer forms
- Transaction history view
- Balance audit log view
- Oracle SQL schema and sample data
- PL/SQL procedures, function, explicit cursor, trigger, sequences, constraints, and exception handling

## Project structure
- `frontend/` — HTML, CSS, and JavaScript frontend demo
- `database/01_schema_and_sample_data.sql` — tables, sequences, sample data
- `database/02_trigger_and_procedures.sql` — trigger, procedures, function, cursor procedure
- `database/03_test_queries.sql` — test operations and verification queries

## Run the frontend
1. Open `frontend/index.html` in a browser, or use Visual Studio Code with the Live Server extension.
2. The forms work in **demo mode** and save sample data in your browser's local storage.
3. Use the Reset site data / clear local storage in your browser if you want to restore the original sample accounts.

## Run the PL/SQL database scripts
1. Sign in to Oracle Live SQL: https://livesql.oracle.com/
2. Run `database/01_schema_and_sample_data.sql` in a fresh schema.
3. Run `database/02_trigger_and_procedures.sql`.
4. Run selected tests from `database/03_test_queries.sql`.
5. Verify the results with the SELECT statements.

## Important integration note
The included frontend is a working browser demonstration, but it is **not directly connected to Oracle Live SQL**. Oracle Live SQL is a browser-based SQL practice environment, not an application database endpoint for a custom website. The frontend's sample operations are kept in browser local storage. The SQL/PLSQL scripts run separately in Oracle Live SQL.

For a genuinely connected full-stack application, use Oracle APEX (recommended for an Oracle/PLSQL college project) or add a backend API connected to an Oracle database that supports application connections. Never place database credentials in frontend JavaScript.

## GitHub upload
1. Create a repository named `SmartBank-PLSQL-Project` on GitHub.
2. Upload all files from this folder. The root contains `index.html`, `style.css`, and `app.js` for easy publishing; the `frontend/` folder contains the same organized frontend files.
3. Ensure `README.md` is in the repository root.
4. Open repository **Settings → Pages**. Under Build and deployment, choose **Deploy from a branch**, select branch `main` and folder `/(root)`, then save.
5. Your repository link will look like `https://github.com/YOUR-USERNAME/SmartBank-PLSQL-Project`.
6. After GitHub Pages finishes publishing, the website URL usually looks like `https://YOUR-USERNAME.github.io/SmartBank-PLSQL-Project/`.

## PL/SQL concepts demonstrated
- Tables, primary keys, foreign keys, and check constraints
- Sequences
- Stored procedures
- Function with return value
- Explicit cursor (`OPEN`, `FETCH`, `CLOSE`, `%NOTFOUND`)
- Row-level trigger using `:OLD` and `:NEW`
- Exception handling and `RAISE_APPLICATION_ERROR`
- Transaction management with `COMMIT`, `ROLLBACK`, and `SAVEPOINT`


