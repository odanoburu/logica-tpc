## example row/predicate
# Lineitem(l_orderkey:1, l_partkey:2, l_suppkey:3, l_linenumber:4,
#          l_quantity:5.0, l_extendedprice:6.0, l_discount:0.7, l_tax:0.12,
#          l_returnflag:"a", l_linestatus:"b", l_shipdate: "2020-04-05",
#          l_commitdate:"2020-04-06", l_receiptdate:"2020-04-15",
#          l_shipinstruct:"don't open", l_shipmode:"plane",
#          l_comment:"ooh nice");

@OrderBy(Query, "l_returnflag, l_linestatus");
Query(l_returnflag:, l_linestatus:,
      sum_qty? += l_quantity,
      sum_base_price? += l_extendedprice,
      sum_disc_price? += (1-l_discount) * l_extendedprice,
      sum_charge? += l_extendedprice*(1-l_discount)*(1+l_tax),
      avg_qty? Avg=l_quantity,
      avg_price? Avg=l_extendedprice,
      avg_disc? Avg=l_discount,
      count_order? += 1) distinct # fix final count
  :- lineitem(l_returnflag:, l_linestatus:, l_quantity:, l_discount:,
              l_tax:, l_shipdate:,
              l_extendedprice:, l_orderkey:), l_shipdate <= Date("1998-12-01", "-3 days");
