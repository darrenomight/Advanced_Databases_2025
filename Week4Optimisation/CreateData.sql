insert /*+ APPEND */ into stores_v2
   select rownum,
          'store' || rownum,
          'address' || rownum,
          'INDIA'
     from dual
   connect by
      level <= 50;


insert /*+ APPEND */ into customers_v2
   select rownum,
          'cust' || rownum,
          sysdate - 720 + mod(
             rownum,
             500
          ),
          dbms_random.value(
             1,
             100
          ),
          case
             when mod(
                rownum,
                10
             ) = 0 then
                'Y'
             else
                'N'
          end,
          mod(
             rownum,
             50
          ) + 1
     from dual
   connect by
      level <= 5000;


insert /*+ APPEND */ into sales_v2
   select rownum,
          1 + mod(
             rownum,
             5000
          ),
          sysdate - 720 + rownum / ( 1000000 / 720 ),
          rownum / 1000,
          mod(
             rownum,
             100
          )
     from dual
   connect by
      level <= 1000000;


commit;


set autotrace on;
select prod_id, max(amount)
from  stores_v2 st,
      customers_v2 c,
      sales_v2 s
where s.cust_id = c.cust_id (+)
and c.store_id = st.store_id
and s.amount > 10
group by prod_id;
set autotrace off;