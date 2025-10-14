--
-- Demo QO-1-Constraints
--
-- @/Users/brendan.tierney/Dropbox/SQL/QO-1-Constraints.sql
-- sql scott/tiger@localhost/freepdb1

set termo on
set echo on
set pages 60
set linesize 120
clear screen

drop table if exists sales_v2;
drop table if exists customers_v2;
drop table if exists stores_v2;

create table stores_v2
( store_id int,
name varchar2(20),
address varchar2(100),
country varchar2(20)
);

create table customers_v2
( cust_id int,
name varchar2(100),
signup date,
creditlimit int,
vip varchar2(1),
store_id int
);

create table sales_v2
( sales_id int,
cust_id int,
tstamp timestamp,
amount number(10,2),
prod_id int
);

pause

-- Insert some data
insert /*+ APPEND */ into stores_v2
select rownum, 'store'||rownum, 'address'||rownum , 'INDIA'
from dual
connect by level <= 50;

insert /*+ APPEND */ into customers_v2
select rownum, 'cust'||rownum, sysdate-720+mod(rownum,500), dbms_random.value(1,100),
case when mod(rownum,10)=0 then 'Y' else 'N' end, mod(rownum,50)+1
from dual
connect by level <= 5000;

insert /*+ APPEND */ into sales_v2
select rownum, 1+mod(rownum,5000), sysdate-720+rownum/(1000000/720), rownum/1000, mod(rownum,100)
from dual
connect by level <= 1000000;

commit;
select count(*) from stores_v2;
select count(*) from customers_v2;
select count(*) from sales_v2;
pause

pause

-- Step 3 - Now query this data and examine how the query is/was executed
set autotrace on EXPLAIN;
select prod_id, max(amount)
from   stores_v2 st,
       customers_v2 c,
       sales_v2 s
where s.cust_id = c.cust_id(+)
and   c.store_id = st.store_id
and   s.amount > 10
group by prod_id;

set autotrace off;
pause

-- Step 4 - Let's fix this by creating some indexes
create unique index store_ix on stores_v2 (store_id );
create unique index cust_ix on customers_v2 (cust_id );
create unique index sales_ix on sales_v2 (sales_id);
create index sales_ix_cust on sales_v2 (cust_id);
create index sales_ix_prod on sales_v2 (prod_id , amount);

-- Step 5 - Now run the query again - Does the query run quicker?
set autotrace on EXPLAIN;
select prod_id, max(amount)
from   stores_v2 st,
       customers_v2 c,
       sales_v2 s
where s.cust_id = c.cust_id(+)
and   c.store_id = st.store_id
and   s.amount > 10
group by prod_id;

set autotrace off;
pause


-- Step 6 - Now let us add some valuable meta-data

-- create the primary keys
alter table stores_v2 add primary key (store_id );
alter table customers_v2 add primary key (cust_id );
alter table sales_v2 add primary key (sales_id );

-- create some NOT NULL constraints on attributes
alter table sales_v2 modify cust_id not null;
alter table sales_v2 modify prod_id not null;
alter table sales_v2 modify amount not null;
alter table customers_v2 modify store_id not null;

-- create the foreign key constraints

alter table customers_v2 add constraint cust_fk
foreign key (store_id) references stores_v2 (store_id );

alter table sales_v2 add constraint sales_fk
foreign key (cust_id) references customers_v2 (cust_id );

-- Step 7 - Did adding this meta-data make any difference to our query?
pause

set autotrace on EXPLAIN;
select prod_id, max(amount)
from   stores_v2 st,
       customers_v2 c,
       sales_v2 s
where s.cust_id = c.cust_id(+)
and   c.store_id = st.store_id
and   s.amount > 10
group by prod_id;

set autotrace off;

-- What happened? What's the difference
pause

-- Let's explore the different SET AUTOTRACE ON options
-- Autotrace on EXPLAIN
set autotrace on EXPLAIN
select prod_id, max(amount)
from   stores_v2 st,
       customers_v2 c,
       sales_v2 s
where s.cust_id = c.cust_id(+)
and   c.store_id = st.store_id
and   s.amount > 10
group by prod_id;
set autotrace off;
pause

-- Autotrace on STATISTICS
set autotrace on STATISTICS
select prod_id, max(amount)
from   stores_v2 st,
       customers_v2 c,
       sales_v2 s
where s.cust_id = c.cust_id(+)
and   c.store_id = st.store_id
and   s.amount > 10
group by prod_id;
set autotrace off;
pause

-- Autotrace on TRACEONLY
set autotrace on TRACEONLY;
select prod_id, max(amount)
from   stores_v2 st,
       customers_v2 c,
       sales_v2 s
where s.cust_id = c.cust_id(+)
and   c.store_id = st.store_id
and   s.amount > 10
group by prod_id;
set autotrace off;
pause

-- Autotrace on TRACEONLY EXPLAIN
set autotrace on;
select prod_id, max(amount)
from   stores_v2 st,
       customers_v2 c,
       sales_v2 s
where s.cust_id = c.cust_id(+)
and   c.store_id = st.store_id
and   s.amount > 10
group by prod_id;
set autotrace off;
pause

-- Autotrace on TRACEONLY STATISTICS
set autotrace on TRACEONLY;
select prod_id, max(amount)
from   stores_v2 st,
       customers_v2 c,
       sales_v2 s
where s.cust_id = c.cust_id(+)
and   c.store_id = st.store_id
and   s.amount > 10
group by prod_id;
set autotrace off;

-- The End
pause

-- Clean-up
drop table if exists sales_v2;
drop table if exists customers_v2;
drop table if exists stores_v2;

