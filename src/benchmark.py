import timeit

BACKENDS = {}

VERBOSE = False


def print_info(*args, **kwargs):
    if VERBOSE:
        print(*args, **kwargs)


def register_backend(name,
                     query_fn,
                     init_fn=lambda *_: None,
                     end_fn=lambda *_: None):
    backend = {'query': query_fn, 'init': init_fn, 'end': end_fn}
    BACKENDS[name] = backend
    return backend


def benchmark(backend,
              address,
              port,
              queries,
              number=100,
              check_equivalent=False):
    # start DB connection
    backend_state = backend['init'](address, port)
    try:
        times = {}
        for qname, (q_a, q_b) in queries.items():
            if check_equivalent:
                res_a = backend['query'](backend_state, q_a)
                res_b = backend['query'](backend_state, q_b)
                assert(res_a.fetchall() == res_b.fetchall())
            times_a = timeit.repeat(lambda: all(backend['query']
                                             (backend_state, q_a)),
                                    repeat=number,
                                    number=1)
            times_b = timeit.repeat(lambda: all(backend['query']
                                             (backend_state, q_b)),
                                    repeat=number,
                                    number=1)
            times[qname] = (times_a, times_b)
    finally:
        # end DB connection
        assert (backend['end'](backend_state))
    return times


def gather_queries(dir_a, dir_b, query_names=None):
    from pathlib import Path
    dir_a = Path(dir_a)
    dir_b = Path(dir_b)
    if not query_names:
        query_names = sorted(map(lambda p: p.name, dir_a.glob('*.sql')))
    queries = {}
    for q_name in query_names:
        p = dir_a.joinpath(q_name)
        with p.resolve().open('r') as f:
            query_a = f.read()
        p = dir_b.joinpath(q_name)
        with p.resolve().open('r') as f:
            query_b = f.read()
        queries[q_name] = (query_a, query_b)
    return queries


def sqlite3_init(address, port):
    import sqlite3
    print_info("Connecting sqlite3 to:", address)
    con = sqlite3.connect(address)
    return con


def sqlite3_query(con, q):
    cur = con.execute(q)
    return cur


def sqlite3_end(con):
    con.close()
    return True


register_backend('sqlite3',
                 sqlite3_query,
                 init_fn=sqlite3_init,
                 end_fn=sqlite3_end)

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description='Benchmark SQL queries.',
                                     allow_abbrev=False,
                                     exit_on_error=True)
    parser.add_argument('-d',
                        '--database',
                        metavar='DB',
                        type=str,
                        choices=['sqlite3'],
                        default='sqlite3',
                        help='Database to use in the benchmark')
    parser.add_argument('-a',
                        '--db-address',
                        metavar='DB_ADDRESS',
                        type=str,
                        required=True,
                        help='Address to use to connect to database')
    parser.add_argument('-p',
                        '--db-port',
                        metavar='DB_PORT',
                        type=int,
                        help='Port to use to connect to database')
    parser.add_argument('--dir-a',
                        metavar='DIR-A',
                        type=str,
                        required=True,
                        help='Directory containing query files')
    parser.add_argument('--dir-b',
                        metavar='DIR-B',
                        type=str,
                        required=True,
                        help='Other directory containing query files')
    parser.add_argument('-n',
                        '--number',
                        metavar='N',
                        type=int,
                        default=10,
                        help='Run each query N times')
    parser.add_argument(
        '--check-equivalent',
        metavar='CHECK_EQUIVALENT',
        action='store_const',
        const=True,
        default=False,
        help=
        'Check query results at the first run to check if they return the same results'
    )
    parser.add_argument(
        'queries',
        metavar='QUERIES',
        type=str,
        nargs='*',
        default=[],
        help=
        'Base file names of the SQL queries. If unspecified, consider all files in DIR-A to be query files'
    )
    args = parser.parse_args()
    print_info(args)
    backend = BACKENDS.get(args.database)
    assert (backend is not None)
    queries = gather_queries(args.dir_a, args.dir_b,
                             args.queries)  # dict(str, (str, str))
    print_info(queries)
    res = benchmark(backend,
                    args.db_address,
                    args.db_port,
                    queries,
                    number=args.number,
                    check_equivalent=args.check_equivalent)
    print(res)

    # python benchmark.py --check-equivalent --db-address ../TPC-H.db --dir-a ../queries/ --dir-b ../gen-queries/ -d sqlite3 q-02.sql
