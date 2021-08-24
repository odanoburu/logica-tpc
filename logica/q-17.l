@Engine("sqlite");

Query(avg_yearly? MyAvg=l_extendedprice) distinct :-
  lineitem(l_partkey:, l_extendedprice:, l_quantity:),
  part(p_partkey:, p_brand: "Brand#23", p_container: "MED BOX"),
  avg_qty Avg= (l_quantity2 :-
    lineitem(l_partkey: p_partkey, l_quantity: l_quantity2)),
  l_quantity < 0.2 * avg_qty;

MyAvg(x) = Sum(x) / 7.0;
