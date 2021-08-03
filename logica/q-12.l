@Engine("sqlite");

Query(l_shipmode:,
      high_line_count? += if high_line
                          then 1 else 0,
      low_line_count? += if !high_line then 1 else 0) distinct :-
  orders(o_orderkey:, o_orderpriority:),
  lineitem(l_orderkey:, l_shipmode:, l_commitdate:, l_receiptdate:,
           l_shipdate:),
  o_orderkey == l_orderkey,
  l_shipmode == "MAIL" || l_shipmode == "SHIP",
  l_commitdate < l_receiptdate,
  l_shipdate < l_commitdate,
  l_receiptdate >= Date(cutoffdate),
  l_receiptdate < Date(cutoffdate, "+1 year"),
  cutoffdate == "1994-01-01",
  high_line == (o_orderpriority == "1-URGENT" || o_orderpriority == "2-HIGH");
@OrderBy(Query, "l_shipmode");
