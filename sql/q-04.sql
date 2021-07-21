select o_orderpriority,
       count(*) as order_count
from orders
where o_orderdate >= date('1993-07-01') -- QDB
  and o_orderdate < date('1993-07-01', '+3 month') -- QDB
  and exists
    (select *
     from lineitem
     where l_orderkey = o_orderkey
       and l_commitdate < l_receiptdate)
group by o_orderpriority
order by o_orderpriority;
