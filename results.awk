NR > 1 {Query[$1][$2]=($3 < Query[$1][$2] || !Query[$1][$2] ? $3 : Query[$1][$2])
}
END{ for (query in Query) print query, Query[query]["logica-sql"] / Query[query]["sql"]
    }
