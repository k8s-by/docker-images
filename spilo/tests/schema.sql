CREATE DATABASE test_db;
\c test_db

CREATE UNLOGGED TABLE "bAr" ("bUz" INTEGER);
ALTER TABLE "bAr" ALTER COLUMN "bUz" SET STATISTICS 500;
INSERT INTO "bAr" SELECT * FROM generate_series(1, 100000);