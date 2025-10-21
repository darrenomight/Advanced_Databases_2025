-- Create a copy of your base table
CREATE TABLE sales_copy AS SELECT * FROM sales;

-- Confirm the copy
SELECT COUNT(*) FROM sales_copy;

ALTER TABLE sales_copy INMEMORY;

ALTER TABLE sales_copy INMEMORY PRIORITY HIGH;

SELECT table_name, inmemory, inmemory_priority
FROM user_tables
WHERE table_name = 'SALES_COPY';

--SALES_COPY    ENABLED	HIGH

SELECT pool, alloc_bytes, used_bytes
FROM v$inmemory_area;

ALTER TABLE sales_copy INMEMORY PRIORITY CRITICAL;
EXEC DBMS_INMEMORY.POPULATE('DARREN','SALES_COPY');

SELECT segment_name, populate_status
FROM v$im_segments
WHERE segment_name = 'SALES_COPY';

-- Check your In-Memory size parameter
SHOW PARAMETER inmemory_size;

-- Check how big your sales_copy table is
SELECT segment_name, ROUND(bytes/1024/1024, 2) AS size_mb
FROM user_segments
WHERE segment_name = 'SALES_COPY';

-- Check if it even tried to populate
SELECT segment_name, populate_status, 
       ROUND(bytes/1024/1024, 2) AS table_size_mb,
       ROUND(inmemory_size/1024/1024, 2) AS inmemory_size_mb,
       ROUND(bytes_not_populated/1024/1024, 2) AS not_populated_mb
FROM v$im_segments
WHERE segment_name = 'SALES_COPY';


-- Check table size
SELECT segment_name, ROUND(bytes/1024/1024, 2) AS size_mb
FROM user_segments
WHERE segment_name = 'SALES_COPY';

-- Check if it's in v$im_segments at all
SELECT segment_name, populate_status, 
       ROUND(bytes/1024/1024, 2) AS table_size_mb,
       ROUND(inmemory_size/1024/1024, 2) AS inmemory_size_mb,
       ROUND(bytes_not_populated/1024/1024, 2) AS not_populated_mb
FROM v$im_segments
WHERE segment_name = 'SALES_COPY';

-- Force population
ALTER TABLE sales_copy INMEMORY PRIORITY CRITICAL;
EXEC DBMS_INMEMORY.POPULATE(USER, 'SALES_COPY');

-- Trigger with full scan
SELECT /*+ FULL(sales_copy) NO_RESULT_CACHE */ COUNT(*) FROM sales_copy;

-- Wait 10 seconds
EXEC DBMS_SESSION.SLEEP(10);

-- Check again
SELECT segment_name, populate_status FROM v$im_segments WHERE segment_name = 'SALES_COPY';

-- 1. Check if In-Memory is enabled on the table
SELECT table_name, inmemory, inmemory_priority, inmemory_compression
FROM user_tables
WHERE table_name = 'SALES_COPY';

-- 2. Check population status
SELECT segment_name, populate_status, 
       ROUND(bytes/1024/1024, 2) AS table_size_mb,
       ROUND(inmemory_size/1024/1024, 2) AS inmemory_size_mb
FROM v$im_segments
WHERE segment_name = 'SALES_COPY';

-- 3. Check In-Memory area usage NOW
SELECT pool, 
       ROUND(alloc_bytes/1024/1024, 2) AS allocated_mb,
       ROUND(used_bytes/1024/1024, 2) AS used_mb
FROM v$inmemory_area;

-- Check In-Memory usage
SELECT pool, ROUND(used_bytes/1024/1024, 2) AS used_mb FROM v$inmemory_area;

SELECT sql_text, executions, im_scans
FROM v$sql
WHERE sql_text LIKE '%sales_copy%'
  AND sql_text NOT LIKE '%v$sql%'
ORDER BY last_active_time DESC
FETCH FIRST 3 ROWS ONLY;

-- Check which tables have In-Memory enabled
SELECT table_name, inmemory, inmemory_priority
FROM user_tables
WHERE table_name IN ('SALES_COPY', 'PRODUCT', 'CUSTOMER');

-- Check table sizes
SELECT segment_name, ROUND(bytes/1024/1024, 2) AS size_mb
FROM user_segments
WHERE segment_name IN ('SALES_COPY', 'PRODUCT', 'CUSTOMER');

-- Enable In-Memory on the lookup tables
ALTER TABLE customer INMEMORY PRIORITY CRITICAL;
ALTER TABLE product INMEMORY PRIORITY CRITICAL;

-- Force population
EXEC DBMS_INMEMORY.POPULATE(USER, 'CUSTOMER');
EXEC DBMS_INMEMORY.POPULATE(USER, 'PRODUCT');

-- Trigger population with full scans
SELECT /*+ FULL(customer) NO_RESULT_CACHE */ COUNT(*) FROM customer;
SELECT /*+ FULL(product) NO_RESULT_CACHE */ COUNT(*) FROM product;

-- Wait a few seconds
EXEC DBMS_SESSION.SLEEP(5);

-- Verify all three are populated
SELECT segment_name, populate_status, 
       ROUND(inmemory_size/1024/1024, 2) AS inmemory_mb
FROM v$im_segments
WHERE segment_name IN ('SALES_COPY', 'CUSTOMER', 'PRODUCT')
ORDER BY segment_name;

-- Check total In-Memory usage
SELECT pool, ROUND(used_bytes/1024/1024, 2) AS used_mb 
FROM v$inmemory_area;