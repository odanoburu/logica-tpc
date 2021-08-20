select ps_partkey,
       sum(ps_supplycost * ps_availqty) as value
from partsupp,
     supplier,
     nation
where ps_suppkey = s_suppkey
  and s_nationkey = n_nationkey
  and n_name = 'GERMANY' -- QDB
group by ps_partkey
having sum(ps_supplycost * ps_availqty) >
  (select sum(ps_supplycost * ps_availqty) * 0.0001 -- QDB
   from partsupp,
        supplier,
        nation
   where ps_suppkey = s_suppkey
     and s_nationkey = n_nationkey
     and n_name = 'GERMANY') -- QDB
order by value desc;
