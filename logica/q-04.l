@Engine("sqlite");

# Query(o_orderpriority:, order_count? Count=o_orderkey) distinct :-
#   orders(o_orderkey:, o_orderdate:, o_orderpriority:),
#   o_orderdate >= Date("1993-07-01"),
#   o_orderdate < Date("1993-07-01", "+3 month"),
#   LateReceipt(o_orderkey);

# LateReceipt(o_orderkey) Min= true :-
#   lineitem(l_orderkey:, l_commitdate:, l_receiptdate:),
#   l_orderkey == o_orderkey,
#   l_commitdate < l_receiptdate;

# version using counting
Query(o_orderpriority:, order_count? Count=o_orderkey) distinct :-
  orders(o_orderkey:, o_orderdate:, o_orderpriority:),
  o_orderdate >= Date("1993-07-01"),
  o_orderdate < Date("1993-07-01", "+3 month"),
  LateReceipt(o_orderkey) >= 1;

LateReceipt(o_orderkey) += 1 :-
  lineitem(l_orderkey:, l_commitdate:, l_receiptdate:),
  l_orderkey == o_orderkey,
  l_commitdate < l_receiptdate;
LateReceipt(o_orderkey) += 0 :-
  lineitem(l_orderkey:),
  l_orderkey == o_orderkey;
