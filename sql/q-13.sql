select c_count,
       count(*) as custdist
from
  (select c_custkey,
          count(o_orderkey) as c_count
   from customer
   left outer join orders on
        c_custkey = o_custkey
        and o_comment not like '%special%requests%' -- QDB
   group by c_custkey) as c_orders
group by c_count
order by custdist desc,
         c_count desc;

-- QUERY PLAN
-- |--CO-ROUTINE 1
-- |  |--SCAN TABLE customer
-- |  `--SEARCH TABLE orders USING AUTOMATIC COVERING INDEX (O_CUSTKEY=?)
-- |--SCAN SUBQUERY 1 AS c_orders
-- |--USE TEMP B-TREE FOR GROUP BY
-- `--USE TEMP B-TREE FOR ORDER BY

-- create view orders_per_cust (custkey, ordercount) as
-- select c_custkey,
--        count(o_orderkey)
-- from customer
-- left outer join orders on c_custkey = o_custkey
-- and o_comment not like '%special%requests%' -- QDB
-- group by c_custkey;

-- select ordercount,
--        count(*) as custdist
-- from orders_per_cust
-- group by ordercount
-- order by custdist desc,
--          ordercount desc;
-- drop view orders_per_cust;

-- QUERY PLAN
-- |--CO-ROUTINE 2
-- |  |--SCAN TABLE customer
-- |  `--SEARCH TABLE orders USING AUTOMATIC COVERING INDEX (O_CUSTKEY=?)
-- |--SCAN SUBQUERY 2
-- |--USE TEMP B-TREE FOR GROUP BY
-- `--USE TEMP B-TREE FOR ORDER BY
