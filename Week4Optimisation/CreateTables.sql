drop table sales_v2;
drop table customers_v2;
drop table stores_v2;


create table stores_v2 (
   store_id int,
   name     varchar2(20),
   address  varchar2(100),
   country  varchar2(20)
);


create table customers_v2 (
   cust_id     int,
   name        varchar2(100),
   signup      date,
   creditlimit int,
   vip         varchar2(1),
   store_id    int
);


create table sales_v2 (
   sales_id int,
   cust_id  int,
   tstamp   timestamp,
   amount   number(10,2),
   prod_id  int
);

create unique index store_ix on
   stores_v2 (
      store_id
   );
create unique index cust_ix on
   customers_v2 (
      cust_id
   );
create unique index sales_ix on
   sales_v2 (
      sales_id
   );
create index sales_ix_cust on
   sales_v2 (
      cust_id
   );
create index sales_ix_prod on
   sales_v2 (
      prod_id,
      amount
   );

-- create the primary keys

alter table stores_v2 add primary key ( store_id );

alter table customers_v2 add primary key ( cust_id );

alter table sales_v2 add primary key ( sales_id );


-- create some NOT NULL constraints on attributes

alter table sales_v2 modify
   cust_id not null;

alter table sales_v2 modify
   prod_id not null;

alter table sales_v2 modify
   amount not null;

alter table customers_v2 modify
   store_id not null;


-- create the foreign key constraints


alter table customers_v2
   add constraint cust_fk foreign key ( store_id )
      references stores_v2 ( store_id );


alter table sales_v2
   add constraint sales_fk foreign key ( cust_id )
      references customers_v2 ( cust_id );