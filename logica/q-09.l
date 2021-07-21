@Engine("sqlite");

import sqlite.DateYear;

Query(nation:, o_year:, sum_profit? += amount) distinct :-
  Profit(nation:, o_year:, amount:);
@OrderBy(Query, "nation", "o_year desc");

Profit(nation:, o_year:, amount:) :-
  part(p_partkey:, p_name:),
  supplier(s_suppkey:, s_nationkey:),
  lineitem(l_suppkey:, l_partkey:, l_orderkey:, l_quantity:,
           l_discount:, l_extendedprice:),
  partsupp(ps_suppkey:, ps_partkey:, ps_supplycost:),
  orders(o_orderkey:, o_orderdate:),
  nation(n_nationkey:, n_name:),
  s_suppkey == l_suppkey,
  ps_suppkey == l_suppkey,
  ps_partkey == l_partkey,
  p_partkey == l_partkey,
  o_orderkey == l_orderkey,
  s_nationkey == n_nationkey,
  Like(p_name, "%green%"), # QDB
  nation == n_name,
  o_year == DateYear(o_orderdate),
  amount == l_extendedprice * (1 - l_discount) - ps_supplycost * l_quantity;
