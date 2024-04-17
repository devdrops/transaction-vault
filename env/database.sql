/*
 *** Database ***

As PostgreSQL doesn't support IF NOT EXISTS to create a database; we have to use this approach to avoid creating it if
already exists.
 */
SELECT 'CREATE DATABASE transaction_vault'
    WHERE NOT EXISTS
        (SELECT FROM pg_database WHERE datname = 'transaction_vault')\gexec

/* Using transaction_vault database from now on */
\c transaction_vault

/* Set Brazil's TZ from Sao Paulo */
SET timezone = 'America/Sao_Paulo';

/* Table accounts */
BEGIN;
    CREATE TABLE IF NOT EXISTS accounts (
        id         SERIAL      PRIMARY KEY,
        document   VARCHAR(14) UNIQUE NOT NULL,
        created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
    );
    COMMENT ON COLUMN accounts.document IS 'Document length may vary between 11 (CPF) and 14 (CNPJ) chars.';
COMMIT;

/* Operation types */
BEGIN;
    CREATE TYPE OperationTypes AS ENUM ('COMPRA_A_VISTA', 'COMPRA_PARCELADA', 'SAQUE', 'PAGAMENTO');
COMMIT;

/* Table operations */
BEGIN;
    CREATE TABLE IF NOT EXISTS operations (
        id          SERIAL         PRIMARY KEY,
        description OperationTypes NOT NULL,
        created_at  TIMESTAMPTZ    NOT NULL DEFAULT NOW()
    );
    COMMENT ON COLUMN operations.description IS 'COMPRA_A_VISTA, COMPRA_PARCELADA, SAQUE: negative value. PAGAMENTO: positive value.';
    INSERT INTO operations(id, description)
        SELECT 1, 'COMPRA_A_VISTA'
            WHERE NOT EXISTS
                (SELECT 1 FROM operations WHERE id = 1);
    INSERT INTO operations(id, description)
        SELECT 2, 'COMPRA_PARCELADA'
            WHERE NOT EXISTS
                (SELECT 1 FROM operations WHERE id = 2);
    INSERT INTO operations(id, description)
        SELECT 3, 'SAQUE'
            WHERE NOT EXISTS
                (SELECT 1 FROM operations WHERE id = 3);
    INSERT INTO operations(id, description)
        SELECT 4, 'PAGAMENTO'
            WHERE NOT EXISTS
                (SELECT 1 FROM operations WHERE id = 4);
    REVOKE ALL ON TABLE operations FROM public;
COMMIT;

/* Table transactions */
BEGIN;
    CREATE TABLE IF NOT EXISTS transactions (
        id           SERIAL         PRIMARY KEY,
        account_id   INTEGER        NOT NULL,
        operation_id INTEGER        NOT NULL,
        amount       NUMERIC(15, 4) NOT NULL,
        balance      NUMERIC(15, 4) NOT NULL DEFAULT 0,
        created_at   TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
        CONSTRAINT fk_accounts
            FOREIGN KEY (account_id) REFERENCES accounts(id),
        CONSTRAINT fk_operations
            FOREIGN KEY (operation_id) REFERENCES operations(id)
    );
COMMIT;