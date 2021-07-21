@Engine("sqlite");

Query(revenue? += l_extendedprice * l_discount) distinct :-
  lineitem(l_extendedprice:, l_discount:, l_shipdate:,
           l_discount:, l_quantity:),
  l_shipdate >= Date(date),
  l_shipdate < Date(date, "+1 year"),
  l_discount >= discount - 0.01, l_discount < discount + 0.01,
  l_quantity < quantity,
  discount == 0.06, # QDB
  date == "1994-01-01", # QDB
  quantity == 24; # QDB
