@Engine("sqlite");

MinimumCostSupplier(s_acctbal:, s_name:, n_name:, p_partkey:, p_mfgr:,
                    s_address:, s_phone:, s_comment:) :-
  part(p_partkey:, p_mfgr:, p_size:, p_type:),
  partsupp(ps_partkey:, ps_suppkey:, ps_supplycost:),
  supplier(s_suppkey:, s_address:, s_name:, s_acctbal:, s_nationkey:,
           s_phone:, s_comment:),
  nation(n_name:, n_regionkey:, n_nationkey:),
  region(r_regionkey:, r_name:),
  p_partkey == ps_partkey,
  s_suppkey == ps_suppkey,
  p_size == 15, # QDB
  Like(p_type, "%BRASS"), # QDB
  s_nationkey == n_nationkey,
  n_regionkey == r_regionkey,
  r_name == "EUROPE", # QDB
  MinimumSupplyCost(p_partkey:, min_supplycost:),
  ps_supplycost == min_supplycost;
@OrderBy(MinimumCostSupplier,
         "s_acctbal desc", "n_name", "s_name", "p_partkey");

MinimumSupplyCost(p_partkey:, min_supplycost? Min=ps_supplycost) distinct :-
  partsupp(ps_partkey:, ps_suppkey:, ps_supplycost:),
  supplier(s_suppkey:, s_suppkey:, s_nationkey:),
  nation(n_nationkey:, n_regionkey:),
  region(r_name:, r_regionkey:),
  p_partkey == ps_partkey,
  s_suppkey == ps_suppkey,
  s_nationkey == n_nationkey,
  n_regionkey == r_regionkey,
  r_name == "EUROPE"; # QDB

## To generate the same query (plan) as the original:
# MinimumSupplyCost(p_partkey:, min_supplycost:) :-
#   min_supplycost Min= (ps_supplycost :-
#     partsupp(ps_partkey:, ps_suppkey:, ps_supplycost:),
#     supplier(s_suppkey:, s_suppkey:, s_nationkey:),
#     nation(n_nationkey:, n_regionkey:),
#     region(r_name:, r_regionkey:),
#     p_partkey == ps_partkey,
#     s_suppkey == ps_suppkey,
#     s_nationkey == n_nationkey,
#     n_regionkey == r_regionkey,
#     r_name == "EUROPE" # QDB
#   );


## Local Variables:
## mode: prog
## comment-start: "# "
## End:
