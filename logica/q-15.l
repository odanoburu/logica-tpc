@Engine("sqlite");

Query(s_suppkey:, s_name:, s_address:, s_phone:, max_revenue: result.revenue) :-
  supplier(s_suppkey:, s_name:, s_address:, s_phone:),
  result == MaxRevenueSupplier(),
  s_suppkey == result.no;
@OrderBy(Query, "s_suppkey");

SupplierRevenue(supplier_no:) += l_extendedprice * (1 - l_discount) :-
  lineitem(l_suppkey:, l_shipdate:, l_extendedprice:, l_discount:),
  l_shipdate >= Date(date),
  l_shipdate < Date(date, "+3 month"),
  date == "1996-01-01",
  supplier_no == l_suppkey;

MaxRevenueSupplier() = {no: supplier_no, revenue: max_revenue} :-
  SupplierRevenue(supplier_no:) == max_revenue,
  max_revenue Max= SupplierRevenue();

# # works but is way slower:

# Query(supplier:, s_name:, s_address:, s_phone:) :-
#   supplier(s_suppkey:, s_name:, s_address:, s_phone:),
#   ~GreaterSupplier(supplier:),
#   supplier == s_suppkey;
# @OrderBy(Query, "s_suppkey");

# GreaterSupplier(supplier:) :-
#   SupplierRevenue(supplier_no: supplier, supplier_revenue:),
#   SupplierRevenue(supplier_no: b, supplier_revenue: greater_supplier_revenue),
#   supplier_revenue < greater_supplier_revenue;

# SupplierRevenue(supplier_no:, supplier_revenue? += l_extendedprice * (1 - l_discount)) distinct :-
#   lineitem(l_suppkey:, l_shipdate:, l_extendedprice:, l_discount:),
#   l_shipdate >= Date(date),
#   l_shipdate < Date(date, "+3 month"),
#   date == "1996-01-01",
#   supplier_no == l_suppkey;
