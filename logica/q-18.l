@Engine("sqlite");

Query(c_name:, c_custkey:, o_orderkey:, o_orderdate:, o_totalprice:,
      total_qty? += l_quantity) distinct :-
  customer(c_name:, c_custkey:),
  orders(o_orderkey:, o_custkey:, o_orderdate:, o_totalprice:),
  lineitem(l_orderkey:, l_quantity:),
  LargeOrder(orderkey: o_orderkey),
  c_custkey == o_custkey,
  o_orderkey == l_orderkey;
@OrderBy(Query, "o_totalprice desc", "o_orderdate");

LargeOrder(orderkey:) :-
  total_qty += (l_quantity :-
    lineitem(l_orderkey:, l_quantity:), orderkey == l_orderkey),
  total_qty > 300;
