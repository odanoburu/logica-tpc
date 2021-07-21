@Engine("sqlite");

import sqlite.DateYear;

Query(supp_nation:, cust_nation:, l_year:, revenue? += volume) distinct :-
  ShippingVolume(supp_nation:, cust_nation:, l_year:, volume:),
  (supp_nation == nation1 && cust_nation == nation2)
    || (supp_nation == nation2 && cust_nation == nation1),
  nation1 == "FRANCE", # QDB
  nation2 == "GERMANY"; # QDB
@OrderBy(Query, "supp_nation", "cust_nation", "l_year");

ShippingVolume(supp_nation:, cust_nation:, l_year:,
              volume? += l_extendedprice * (1-l_discount)) distinct :-
  supplier(s_suppkey:, s_nationkey:),
  lineitem(l_suppkey:, l_orderkey:, l_shipdate:,
           l_extendedprice:, l_discount:),
  orders(o_orderkey:, o_custkey:),
  customer(c_custkey:, c_nationkey:),
  nation(n_name: n_name1, n_nationkey: nationkey1),
  nation(n_name: n_name2, n_nationkey: nationkey2),
  s_suppkey == l_suppkey,
  o_orderkey == l_orderkey,
  c_custkey == o_custkey,
  s_nationkey == nationkey1,
  c_nationkey == nationkey2,
  l_shipdate >= "1995-01-01", l_shipdate <= "1996-12-31",
  supp_nation == n_name1,
  cust_nation == n_name2,
  l_year == DateYear(l_shipdate);
