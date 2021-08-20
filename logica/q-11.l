@Engine("sqlite");

Query(ps_partkey:, value:) distinct :-
  partsupp(ps_partkey:),
  TotalPartsValueInCountry(country: country, value: countryval),
  TotalPartValueInCountry(country: country, part: ps_partkey,
                          value: countrypartval),
  country == "GERMANY",
  countrypartval > 0.0001 * countryval,
  value == countrypartval;
@OrderBy(Query, "value desc");

TotalPartsValueInCountry(country:,
                         value? += ps_supplycost * ps_availqty) distinct :-
  partsupp(ps_supplycost:, ps_availqty:, ps_suppkey:),
  supplier(s_suppkey:, s_nationkey:),
  nation(n_nationkey:, n_name:),
  ps_suppkey == s_suppkey,
  s_nationkey == n_nationkey,
  n_name == country;

TotalPartValueInCountry(country:, part:,
                        value? += ps_supplycost * ps_availqty) distinct :-
  partsupp(ps_partkey:, ps_supplycost:, ps_availqty:, ps_suppkey:),
  supplier(s_suppkey:, s_nationkey:),
  nation(n_nationkey:, n_name:),
  ps_suppkey == s_suppkey,
  s_nationkey == n_nationkey,
  n_name == country,
  ps_partkey == part;
