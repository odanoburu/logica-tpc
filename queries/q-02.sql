select s_acctbal,
       s_name,
       n_name,
       p_partkey,
       p_mfgr,
       s_address,
       s_phone,
       s_comment
from part,
     supplier,
     partsupp,
     nation,
     region
where p_partkey = ps_partkey
  and s_suppkey = ps_suppkey
  and p_size = 15 -- QBD
  and p_type like '%BRASS' -- QDB
  and s_nationkey = n_nationkey
  and n_regionkey = r_regionkey
  and r_name = 'EUROPE' -- QDB
  and ps_supplycost =
    (select min(ps_supplycost)
     from partsupp,
          supplier,
          nation,
          region
     where p_partkey = ps_partkey
       and s_suppkey = ps_suppkey
       and s_nationkey = n_nationkey
       and n_regionkey = r_regionkey
       and r_name = 'EUROPE' ) -- QDB
order by s_acctbal desc,
         n_name,
         s_name,
         p_partkey;

-- (sqlite)
-- QUERY PLAN
-- |--SCAN TABLE partsupp
-- |--SEARCH TABLE supplier USING INTEGER PRIMARY KEY (rowid=?)
-- |--SEARCH TABLE part USING INTEGER PRIMARY KEY (rowid=?)
-- |--CORRELATED SCALAR SUBQUERY 1
-- |  |--SEARCH TABLE partsupp USING INDEX sqlite_autoindex_PARTSUPP_1 (PS_PARTKEY=?)
-- |  |--SEARCH TABLE supplier USING INTEGER PRIMARY KEY (rowid=?)
-- |  |--SEARCH TABLE nation USING INTEGER PRIMARY KEY (rowid=?)
-- |  `--SEARCH TABLE region USING INTEGER PRIMARY KEY (rowid=?)
-- |--SEARCH TABLE nation USING INTEGER PRIMARY KEY (rowid=?)
-- |--SEARCH TABLE region USING INTEGER PRIMARY KEY (rowid=?)
-- `--USE TEMP B-TREE FOR ORDER BY
