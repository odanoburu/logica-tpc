@Engine("sqlite");

Query(s_name:, s_address:) :-
  supplier(s_suppkey:, s_name:, s_address:),
  nation(n_nationkey:, n_name:),
  ExcessForestPart(suppkey: s_suppkey),
  s_nationkey == n_nationkey,
  n_name == "CANADA"; # QDB
@OrderBy(Query, "s_name");

ExcessForestPart(suppkey:) :-
  partsupp(ps_suppkey: suppkey, ps_partkey:, ps_availqty:),
  ForestPart(partkey: ps_partkey),
  PartQty(partkey: ps_partkey, suppkey: ps_suppkey, qty:),
  ps_availqty > 0.5 * qty;

ForestPart(partkey:) :-
  part(p_partkey: partkey, p_name:),
  Like(p_name, "forest%");

PartQty(partkey:, suppkey:, qty? += l_quantity) distinct :-
  lineitem(l_partkey: partkey, l_suppkey: suppkey, l_quantity:, l_shipdate:),
  l_shipdate >= Date(cutoff_date),
  l_shipdate < Date(cutoff_date, "+1 year"),
  cutoff_date == "1994-01-01";
