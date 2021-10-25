-- needs q-15-pre.sql

select s_suppkey,
       s_name,
       s_address,
       s_phone,
       total_revenue
from supplier,
     revenue0 -- QBD
where s_suppkey = supplier_no
  and total_revenue =
    (select max(total_revenue)
     from revenue0) -- QBD
order by s_suppkey;


-- -- no need to drop
-- drop view revenue0; -- QBD
