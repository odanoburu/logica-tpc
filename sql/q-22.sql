-- NOTE: takes very long to run
select cntrycode,
       count(*) as numcust,
       sum(c_acctbal) as totacctbal
from
  (select substring(c_phone
          --           from 1
          --           for 2
	  , 1, 2 -- SQLite
	  ) as cntrycode,
          c_acctbal
   from customer
   where substring(c_phone
                   -- from 1 for 2
		   , 1, 2 -- SQLite
		   ) in ('13','31','23','29','30','18','17') -- QDB
and c_acctbal > (
select
avg(c_acctbal)
from
customer
where
c_acctbal > 0.00
and substring(c_phone
   -- from 1 for 2
   , 1, 2 -- SQLite
   ) in ('13','31','23','29','30','18','17') ) -- QDB
and not exists
  (select *
   from orders
   where o_custkey = c_custkey ) ) as custsale
group by cntrycode
order by cntrycode;
