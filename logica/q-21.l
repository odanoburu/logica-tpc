# works, but why doesn't the other option (in the stash) work too?

@Engine("sqlite");

Query(s_name:, numwait? Count=l_orderkey) distinct :-
  supplier(s_suppkey:, s_nationkey:, s_name:),
  lineitem(l_suppkey:, l_orderkey:, l_receiptdate:, l_commitdate:),
  s_suppkey == l_suppkey,
  orders(o_orderkey:, o_orderstatus: "F"),
  o_orderkey == l_orderkey,
  nation(n_nationkey:, n_name: "SAUDI ARABIA"),
  l_receiptdate > l_commitdate,
  MultiSupplierOrder(orderkey: l_orderkey, suppkey: l_suppkey),
  ~OnlyFailingSupplier({orderkey: l_orderkey, suppkey: l_suppkey}),
  n_nationkey == s_nationkey;
@OrderBy(Query, "numwait desc", "s_name");
@Limit(Query, 100);

MultiSupplierOrder(orderkey:, suppkey:) :-
  lineitem(l_orderkey:, l_suppkey:),
  l_orderkey == orderkey,
  l_suppkey != suppkey;

OnlyFailingSupplier(orderinfo) :-
  lineitem(l_orderkey:, l_suppkey:, l_receiptdate:, l_commitdate:),
  l_orderkey == orderinfo.orderkey,
  l_suppkey != orderinfo.suppkey,
  l_receiptdate > l_commitdate;
