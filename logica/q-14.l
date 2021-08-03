@Engine("sqlite");

Query(promo_revenue? PromoRevenue={p_type:, l_extendedprice:, l_discount:})
    distinct :-
  lineitem(l_partkey:, l_extendedprice:, l_discount:, l_shipdate:),
  part(p_partkey:, p_type:),
  l_partkey == p_partkey,
  l_shipdate >= Date(cutoff_date),
  l_shipdate < Date(cutoff_date, "+1 month"),
  cutoff_date == "1995-09-01";

PromoRevenue(x) = 100
                * Sum(if Like(x.p_type, "PROMO%")
                      then x.l_extendedprice * (1 - x.l_discount)
                      else 0)
                / Sum(x.l_extendedprice * (1 - x.l_discount));
