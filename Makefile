## BUILDING DB for SQLite
# some stuff stolen from https://github.com/lovasoa/TPCH-sqlite
SCALE_FACTOR?=1
TABLES = customer lineitem nation orders partsupp part region supplier
TABLE_FILES = $(foreach table, $(TABLES), tpch-dbgen/$(table).tbl)

## Building SQL queries from Logica code
QUERIES = 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 18 19 21 # Q17/Q20/Q22 too slow
LOGICA_DIR=logica
QUERY_DIR=logica-sql
QUERY_BASENAMES = $(foreach query, $(QUERIES), q-$(query).sql)
QUERY_FILES = $(foreach query_basename, $(QUERY_BASENAMES), $(QUERY_DIR)/$(query_basename))
LOGICA=/home/odanoburu/sites/logica/logica
N_TIMES=3 # times to run each query

## TODO: benchmarking variables here

TPC-H.db: $(TABLE_FILES)
	./create_db.sh $(TABLES)
# create view used in Q15 # this is a temporary solution that won't
# work when/if we add more backends (but then neither will this
# database building rule!)
	sqlite3 TPC-H.db -batch -init sql/q-15-pre.sql ".exit"

$(TABLE_FILES): tpch-dbgen/dbgen
	cd tpch-dbgen && ./dbgen -v -f -s $(SCALE_FACTOR)
	chmod +r $(TABLE_FILES)

tpch-dbgen/dbgen: tpch-dbgen/makefile
	cd tpch-dbgen && $(MAKE)

$(QUERY_DIR)/%.sql: $(LOGICA_DIR)/%.l
	mkdir -p $(QUERY_DIR)
	LOGICAPATH=$(LOGICA_DIR) $(LOGICA) $^ print Query > $@

queries: $(QUERY_FILES)

benchmark-check-equivalent: queries
	mkdir -p build
	python3 src/benchmark.py --check-equivalent --db-address TPC-H.db --dir-a logica-sql --dir-b sql -d sqlite3 >> build/benchmark.csv -n $(N_TIMES) $(QUERY_BASENAMES)

benchmark-no-check-equivalent: queries
	mkdir -p build
	python3 src/benchmark.py --db-address TPC-H.db --dir-a logica-sql --dir-b sql -d sqlite3 >> build/benchmark.csv -n $(N_TIMES) $(QUERY_BASENAMES)

clean:
	rm -rf TPC-H.db $(TABLE_FILES) tpch-dbgen/dbgen
	rm -rf $(QUERY_FILES)

all: queries benchmark-check-equivalent
