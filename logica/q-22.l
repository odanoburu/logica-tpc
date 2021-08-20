@Engine("sqlite");

Query(cntrycode:, numcust? += 1, totalacctbal? += c_acctbal) distinct :-
  customer(c_custkey:, c_phone:, c_acctbal:),
  cntrycode == Substr(c_phone, 1, 2),
  cntrycode in ["13","31","23","29","30","18","17"],
  AverageAcctBalFromSelected(avg_acctbal:),
  c_acctbal > avg_acctbal,
  ~CustomerOrders(c_custkey:, ..o);
@OrderBy(Query, "cntrycode");

CustomerOrders(c_custkey:, ..o) :-
  orders(o_custkey:, ..o),
  o_custkey == c_custkey;

AverageAcctBalFromSelected(avg_acctbal? Avg=c_acctbal) distinct :-
  customer(c_acctbal:, c_phone:),
  cntrycode == Substr(c_phone, 1, 2),
  cntrycode in ["13","31","23","29","30","18","17"],
  c_acctbal > 0.00;

# 13	888	6737713.99

# Selected(countrycode: "13");
# Selected(countrycode: "31");
# Selected(countrycode: "23");
# Selected(countrycode: "29");
# Selected(countrycode: "30");
# Selected(countrycode: "18");
# Selected(countrycode: "17");

# Query(cntrycode:, numcust? += 1, totalacctbal? += c_acctbal) distinct :-
#   customer(c_custkey:, c_phone:, c_acctbal:),
#   cntrycode == Substr(c_phone, 1, 2),
#   Selected(countrycode:),
#   cntrycode == countrycode,
#   AverageAcctBalFromSelected(avg_acctbal:),
#   c_acctbal > avg_acctbal,
#   ~CustomerOrders(c_custkey:, ..o);
# @OrderBy(Query, "cntrycode");

# CustomerOrders(c_custkey:, ..o) :-
#   orders(o_custkey:, ..o),
#   o_custkey == c_custkey;

# AverageAcctBalFromSelected(avg_acctbal? Avg=c_acctbal) distinct :-
#   customer(c_acctbal:, c_phone:),
#   Selected(countrycode: Substr(c_phone, 1, 2)),
#   c_acctbal > 0.00;
