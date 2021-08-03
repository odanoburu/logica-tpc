select sum(l_extendedprice*l_discount) as revenue
from lineitem
where l_shipdate >= date('1994-01-01') -- QDB
  and l_shipdate < date('1994-01-01', '+1 year') -- QDB
  and l_discount between 0.06 - 0.01 and 0.06 + 0.01 -- QDB
  and l_quantity < 24; -- QDB
