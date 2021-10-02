import timeit
from pathlib import Path
import sys
import csv

BACKENDS = {}

VERBOSE = True


def print_info(*args, **kwargs):
    if VERBOSE:
        print(*args, **kwargs)


class Backend:
    def __init__(self,
                 query_fn,
                 init_fn=lambda *_: None,
                 end_fn=lambda *_: None):
        self.init_fn = init_fn
        self.query_fn = query_fn
        self.end_fn = end_fn

    def init(self, *args, **kwargs):
        self.state = self.init_fn(*args, **kwargs)
        return self.state

    def query(self, q):
        return self.query_fn(self.state, q)

    def end(self, *args, **kwargs):
        return self.end_fn(self.state, *args, **kwargs)


def register_backend(name, backend):
    assert isinstance(backend, Backend)
    BACKENDS[name] = backend
    return backend


def compare_queries(backend, q1, q2):
    c1 = backend.query(q1)
    c2 = backend.query(q2)
    r1 = c1.fetchall()
    r2 = c2.fetchall()
    return r1 == r2, r1, r2


def benchmark(backend,
              address,
              port,
              queries,
              number=100,
              check_equivalent=False):
    # start DB connection
    backend.init(address, port)
    times = {}
    try:
        for qname, (q_a, q_b) in queries.items():
            print_info("Running query {}".format(qname), file=sys.stderr)
            same_query_plan, _, _ = compare_queries(
                backend, "EXPLAIN QUERY PLAN " + q_a,
                "EXPLAIN QUERY PLAN " + q_b)
            if same_query_plan:
                print("Query plans for {} are the same".format(qname),
                      file=sys.stderr)
            else:
                if check_equivalent:
                    same_results, res_a, res_b = compare_queries(
                        backend, q_a, q_b)
                    if same_results:
                        print_info(
                            "Query results for {} are equivalent. Timing now…".
                            format(qname),
                            file=sys.stderr)
                    else:
                        print("Query results for {} are not the same".format(
                            qname),
                              file=sys.stderr)
                        import tempfile
                        tmpdir = Path(tempfile.gettempdir())
                        for ix, res in enumerate([res_a, res_b]):
                            p = tmpdir.joinpath("{}-{}.tsv".format(qname, ix))
                            with p.resolve().open('w', newline='') as outfile:
                                print_info("Writing query output to",
                                           outfile.name,
                                           file=sys.stderr)
                                write_csv(outfile, res)
                        continue
                times_a = timeit.repeat(lambda: all(backend.query(q_a)),
                                        repeat=number,
                                        number=1)
                times_b = timeit.repeat(lambda: all(backend.query(q_b)),
                                        repeat=number,
                                        number=1)
                times[qname] = (times_a, times_b)
    finally:
        # end DB connection
        assert (backend.end())
    return times


def gather_queries(dir_a, dir_b, query_names=None):
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


def write_csv(csvout, rowgenerator, header=None):
    writer = csv.writer(csvout, delimiter='\t')
    if header is not None:
        writer.writerow(header)
    for row in rowgenerator:
        writer.writerow(row)


def to_csv(times, dirA='A', dirB='B', output=None):
    def rowgenerator():
        for qname, dirTimings in times.items():
            for dirname, timings in zip([dirA, dirB], dirTimings):
                for timing in timings:
                    yield [qname, dirname, timing]

    f = lambda outfile: write_csv(
        outfile, rowgenerator(), header=["query", "dir", "time"])
    if output is None:
        f(sys.stdout)
    else:
        with open(output, 'w', newline='') as csvfile:
            f(csvfile)


def sqlite3_init(address, port):
    import sqlite3
    print_info("Connecting sqlite3 to:", address, file=sys.stderr)
    con = sqlite3.connect(address)
    return con


def sqlite3_query(con, q):
    cur = con.execute(q)
    return cur


def sqlite3_end(con):
    con.close()
    return True


register_backend("sqlite3", Backend(sqlite3_query, sqlite3_init, sqlite3_end))

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(
        description='Benchmark two sets of SQL queries against each other.',
        allow_abbrev=False)
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
    parser.add_argument('-o',
                        '--output',
                        metavar='FILE',
                        type=str,
                        help='Write output to FILE')
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
    #print_info(args)
    backend = BACKENDS.get(args.database)
    assert (backend is not None)
    dirA, dirB = args.dir_a, args.dir_b
    queries = gather_queries(dirA, dirB, args.queries)  # dict(str, (str, str))
    #print_info(queries)
    timings = benchmark(backend,
                        args.db_address,
                        args.db_port,
                        queries,
                        number=args.number,
                        check_equivalent=args.check_equivalent)
    to_csv(timings, dirA, dirB, args.output)
    # python benchmark.py --check-equivalent --db-address ../TPC-H.db --dir-a ../queries/ --dir-b ../gen-queries/ -d sqlite3 q-02.sql
