@Engine("sqlite");

import sqlite.DateYear;

NationYearVolume(o_year:, volume:, nation: n_name) :-
  part(p_partkey:, p_type:),
  supplier(s_suppkey:, s_nationkey:),
  lineitem(l_partkey:, l_suppkey:, l_orderkey:,
           l_extendedprice:, l_discount:),
  orders(o_orderkey:, o_custkey:, o_orderdate:),
  customer(c_custkey:, c_nationkey:),
  nation(n_nationkey: n_nationkey1, n_regionkey:),
  nation(n_nationkey: n_nationkey2, n_name:),
  region(r_regionkey:, r_name:),
  p_partkey == l_partkey,
  s_suppkey == l_suppkey,
  l_orderkey == o_orderkey,
  o_custkey == c_custkey,
  c_nationkey == n_nationkey1,
  n_regionkey == r_regionkey,
  r_name == "AMERICA", # QDB
  s_nationkey == n_nationkey2,
  o_orderdate >= Date("1995-01-01"),
  o_orderdate <= Date("1996-12-31"),
  p_type == "ECONOMY ANODIZED STEEL",
  o_year == DateYear(o_orderdate),  # FIXME: for sqlite
  volume == l_extendedprice * (1 - l_discount);

BrazilShare(x) = Sum(if x.nation == "BRAZIL" then x.volume else 0) / Sum(x.volume);

Query(o_year:, mkt_share? BrazilShare={nation:,volume:}) distinct :-
  NationYearVolume(o_year:, volume:, nation:);
@OrderBy(Query, "o_year");
