@Engine("sqlite");

Query(p_brand:, p_type:, p_size:, supplier_cnt? Count=ps_suppkey) distinct :-
  partsupp(ps_partkey:, ps_suppkey:),
  part(p_partkey:, p_brand:, p_type:, p_size:),
  p_partkey == ps_partkey,
  p_brand != "Brand#45", # QDB
  !Like(p_type, "MEDIUM POLISHED .%"), # QDB
  p_size in [49, 14, 23, 45, 19, 3, 36, 10],
  ~Complaints(s_suppkey: ps_suppkey);
@OrderBy(Query, "supplier_cnt desc", "p_brand", "p_type", "p_size");

Complaints(s_suppkey:) :-
  supplier(s_suppkey:, s_comment:),
  Like(s_comment, "%Customer%Complaints%");
