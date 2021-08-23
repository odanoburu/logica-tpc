@Engine("sqlite");

Query(avg_yearly: revenue) :-
  revenue += (l_extendedprice / 7.0 :-
    lineitem(l_partkey:, l_extendedprice:, l_quantity:),
    part(p_partkey:, p_brand: "Brand#23", p_container: "MED BOX"),
    AverageQuantity(p_partkey: p_partkey, avg_qty:),
    l_quantity < 0.2 * avg_qty);

AverageQuantity(p_partkey:, avg_qty? Avg=l_quantity) distinct :-
  lineitem(l_partkey:, l_quantity:),
  l_partkey == p_partkey;
