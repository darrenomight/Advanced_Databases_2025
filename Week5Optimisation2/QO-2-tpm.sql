--
-- Demo QO-2-tpm
--
-- @/Users/brendan.tierney/Dropbox/SQL/QO-2-tpm.sql
-- sql scott/tiger@localhost/freepdb1
--@ C:\Users\darre\OneDrive\Desktop\Uni_Work\Masters\Databases\Labs\Week5Optimisation2\QO-2-tpm.sql
conn Darren/darren1@localhost/freepdb1

set termo on
set echo on
set pages 60
set linesize 120
clear screen

drop table if exists sales;
drop table if exists product;
drop table if exists customer;
drop table if exists store;
drop table if exists taxcode;
drop sequence txnseq;

pause

-- Create some tables tables & populate with some randome data 
create table product as select rownum pid, 'product '||rownum descr 
from dual connect by level <= 100000; 
alter table product add primary key (pid); 

create table customer as select rownum cid, 'customer '||rownum descr 
from dual connect by level <= 100000; 
alter table customer add primary key (cid); 

create table store as select rownum sid, 'store '||rownum descr 
from dual connect by level <= 100000; 
alter table store add primary key (sid); 

create table taxcode as select rownum tid, 'taxcode '||rownum descr 
from dual connect by level <= 100000; 
alter table taxcode add primary key (tid); 

create sequence txnseq; 
pause

-- And my sales table that refers back to those tables 
create table sales 
( txn_id int default txnseq.nextval not null ,
 pid int not null references product(pid),
 cid int not null references customer(cid),
 sid int not null references store(sid),
 tid int not null references taxcode(tid),
 discount varchar2(1) not null,
 amount number(10,2) not null,
 qty number(10) not null,
 constraint chk1 check ( discount in ('Y','N')), 
 constraint chk2 check ( amount > 0),
 constraint chk3 check ( qty > 0) ); 
alter table sales add primary key ( txn_id ) 
using index global partition by hash ( txn_id ) partitions 8; 
pause

-- ------------------------------------------------------------- 
-- create a log table to record work
drop table if exists hammer_log;
create table hammer_log ( job int, ela interval day to second ); 

-- create procedure to perform the work
CREATE or REPLACE procedure hammer_time is
   p sys.odcinumberlist := sys.odcinumberlist(); 
   c sys.odcinumberlist := sys.odcinumberlist(); 
   s sys.odcinumberlist := sys.odcinumberlist();
  t sys.odcinumberlist := sys.odcinumberlist();

    timer timestamp; 
BEGIN
   select trunc(dbms_random.value(1,100000)) bulk collect into p 
   from dual connect by level <= 32000; 

   select trunc(dbms_random.value(1,100000)) bulk collect into c 
   from dual connect by level <= 32000; 

   select trunc(dbms_random.value(1,100000)) bulk collect into s 
   from dual connect by level <= 32000; 

   select trunc(dbms_random.value(1,100000)) bulk collect into t 
   from dual connect by level <= 32000; 

   timer := localtimestamp; 

   -- do lots of work
   for j in 1 .. 3 loop 
      for i in 1 .. 32000 loop 
         insert into sales ( pid,cid,sid,tid,discount,amount,qty) 
         values (p(i), c(i), s(i), t(i), 'Y',i,i); 
         commit; 
      end loop; 
   end loop; 

   insert into hammer_log 
   values ( sys_context('USERENV','BG_JOB_ID'), localtimestamp-timer); 

   commit; 
END; 
/ 

-- ------------------------------------------------------- 
-- Start the Hammer process - Submit Job to run in backgroud 12 times
pause

delete from hammer_log; 
declare 
   j int; 
begin 
   for i in 1 .. 12 loop 
      dbms_job.submit(j,'hammer_time;'); 
   end loop; 
   commit; 
end; 
/ 

--wait
pause

-- wait for Jobs to be picked up by DB scheduler
--1 of 7
select * from hammer_log; 
pause

--2 of 7
select * from hammer_log; 
pause

--3 of 7
select * from hammer_log; 
pause

--4 of 7
select * from hammer_log; 
pause

--5 of 7
select * from hammer_log; 
pause

--6 of 7
select * from hammer_log; 
pause

-- 7 of 7 (last one)
select * from hammer_log; 
pause


select count(*)*96000 / extract(second from max(ela)) 
from hammer_log; 

select max(ela) from hammer_log; 
select avg(ela) from hammer_log;
select count(*)*96000 / (extract(second from max(ela))) tps 
from hammer_log; 
-- 19,228.890954 tps 


-- ------------------------------------------------------- 
--create some indexes
pause
drop index if exists sales_ix1; 
drop index if exists sales_ix2; 
drop index if exists sales_ix3; 
drop index if exists sales_ix4; 
create index sales_ix1 on sales ( pid); 
pause
create index sales_ix2 on sales ( sid); 
pause
create index sales_ix3 on sales ( cid); 
pause
create index sales_ix4 on sales ( tid); 
--------------------------------------------------------- 

-- Re-run the Hammer process - this time with the indexes
pause


delete from hammer_log; 
declare 
   j int; 
begin 
   for i in 1 .. 12 loop 
      dbms_job.submit(j,'hammer_time;'); 
   end loop; 
   commit; 
end; 
/ 

-- wait
pause

-- wait for Jobs to be picked up by DB scheduler
select * from hammer_log; 
pause

select * from hammer_log; 
pause

select * from hammer_log; 
pause

select * from hammer_log; 
pause

select * from hammer_log; 
pause

select * from hammer_log; 
pause

select * from hammer_log; 
pause

select * from hammer_log; 

--select max(ela) from hammer_log; 
--select count(*)*96000 / (extract(second from max(ela))) tps 
--from hammer_log; 

select avg(ela) from hammer_log;
select count(*)*96000 / (extract(minute from max(ela))*60)+(extract(second from max(ela))) tps 
from hammer_log; 

-- 19,238.647394

-- the end
pause