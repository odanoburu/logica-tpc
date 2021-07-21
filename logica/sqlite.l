# FIXME: work for non-sqlite engines
DateYear(date) = SqlExpr("strftime('%Y', {d})", {d: date});
