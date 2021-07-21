Query(l_orderkey:, revenue? += l_extendedprice*(1-l_discount), o_orderdate:, o_shippriority:) distinct :-
  customer(c_mktsegment:, c_custkey:),
  orders(o_custkey:, o_orderkey:, o_orderdate:, o_shippriority:),
  lineitem(l_orderkey:, l_shipdate:, l_extendedprice:, l_discount:),
  c_mktsegment == "BUILDING",
  c_custkey == o_custkey,
  l_orderkey == o_orderkey,
  o_orderdate < Date("1995-03-15"),
  l_shipdate > Date("1995-03-15");
@OrderBy(Query, "revenue desc", "o_orderdate");
@Limit(Query, 10);
