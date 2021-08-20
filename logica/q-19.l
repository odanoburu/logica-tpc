@Engine("sqlite");

Query(revenue? += l_extendedprice * (1 - l_discount)) distinct :-
  lineitem(l_partkey:, l_extendedprice:, l_discount:, l_quantity:,
           l_shipmode:, l_shipinstruct:),
  part(p_partkey:, p_size:, p_brand:, p_container:),
  p_partkey == l_partkey,
  l_shipmode == "AIR" || l_shipmode == "AIR REG",
  l_shipinstruct == "DELIVER IN PERSON",
  p_size >= 1,
  (p_brand == "Brand#12" &&
   p_container in ["SM CASE", "SM BOX", "SM PACK", "SM PKG"] &&
   l_quantity >= 1 && # QDB
   l_quantity <= 1 + 10 && # QDB
   p_size <= 5) ||
  (p_brand == "Brand#23" &&
   p_container in ["MED BAG", "MED BOX", "MED PKG", "MED PACK"] &&
   l_quantity >= 10 && # QDB
   l_quantity <= 10 + 10 && # QDB
   p_size <= 10) ||
  (p_brand == "Brand#34" &&
   p_container in ["LG CASE", "LG BOX", "LG PACK", "LG PKG"] &&
   l_quantity >= 20 && # QDB
   l_quantity <= 20 + 10 && # QDB
   p_size <= 15);
