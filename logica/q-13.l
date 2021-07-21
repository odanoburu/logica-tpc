@Engine("sqlite");

# Query(c_count:, custdist? Sum=1) distinct
#   :- customer(c_custkey:),
#      c_count == Coalesce(GetOrdersCount(c_custkey:), 0);
#      ## using just the below will exclude customers with no orders
#      # ExistingCustomerOrders(c_custkey:, c_count:);
# @OrderBy(CustomerOrderDist,
#          "custdist desc", "c_count desc");

# GetOrdersCount(c_custkey:) = c_count :-
#   c_count AnyValue= (x :- ExistingCustomerOrders(c_custkey:, c_count: x));

# ExistingCustomerOrders(c_custkey:, c_count? Count=o_orderkey) distinct
#   :- customer(c_custkey:),
#      orders(o_custkey:, o_orderkey:, o_comment:),
#      c_custkey == o_custkey,
#      !Like(o_comment, "%special%requests%"); # QDB

OrdersByCustomer(c_custkey) += 1 :-
  customer(c_custkey:),
  orders(o_custkey:, o_comment:),
  o_custkey == c_custkey,
  !Like(o_comment, "%special%requests%");
OrdersByCustomer(c_custkey) += 0 :-
  customer(c_custkey:);

# distribution of customers' number of orders
Query(
  c_count: OrdersByCustomer(),
  custdist? += 1) distinct;
@OrderBy(Query,
         "custdist desc", "c_count desc");
