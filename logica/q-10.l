@Engine("sqlite");

Query(c_custkey:, c_name:,
      revenue? += l_extendedprice * (1 - l_discount),
      c_acctbal:, n_name:, c_address:, c_phone:, c_comment:) distinct :-
  customer(c_custkey:, c_name:, c_acctbal:, c_address:,
           c_phone:, c_comment:, c_nationkey:),
  orders(o_orderkey:, o_custkey:, o_orderdate:),
  lineitem(l_extendedprice:, l_discount:, l_returnflag:, l_orderkey:),
  nation(n_nationkey:, n_name:),
  c_custkey == o_custkey,
  l_orderkey == o_orderkey,
  o_orderdate >= Date(cutoff_date),
  o_orderdate < Date(cutoff_date, "+3 month"),
  l_returnflag == "R",
  c_nationkey == n_nationkey,
  cutoff_date == "1993-10-01";
@OrderBy(Query, "revenue desc");
@Limit(Query, 20);
