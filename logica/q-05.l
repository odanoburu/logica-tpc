@Engine("sqlite");

Query(n_name:, revenue? += l_extendedprice * (1 - l_discount)) distinct :-
  customer(c_custkey:, c_nationkey:),
  orders(o_custkey:, o_orderkey:, o_orderdate:),
  lineitem(l_orderkey:, l_suppkey:, l_extendedprice:, l_discount:),
  supplier(s_suppkey:, s_nationkey:),
  nation(n_regionkey:, n_name:, n_nationkey:),
  region(r_regionkey:, r_name:),
  c_custkey == o_custkey,
  l_orderkey == o_orderkey,
  l_suppkey == s_suppkey,
  c_nationkey == s_nationkey,
  s_nationkey == n_nationkey,
  n_regionkey == r_regionkey,
  r_name == "ASIA",
  o_orderdate >= Date("1994-01-01"),
  o_orderdate < Date("1994-01-01", "+1 year");
@OrderBy(Query, "revenue desc")
