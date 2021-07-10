## BUILDING DB for SQLite
# some stuff stolen from https://github.com/lovasoa/TPCH-sqlite
SCALE_FACTOR?=1
TABLES = customer lineitem nation orders partsupp part region supplier
TABLE_FILES = $(foreach table, $(TABLES), tpch-dbgen/$(table).tbl)

## Building SQL queries from Logica code
QUERIES = 02 13
LOGICA_DIR=logica
QUERY_DIR=logica-sql
QUERY_FILES = $(foreach query, $(QUERIES), $(QUERY_DIR)/q-$(query).sql)
LOGICA=/home/odanoburu/sites/logica/logica

## TODO: benchmarking variables here

TPC-H.db: $(TABLE_FILES)
	./create_db.sh $(TABLES)

$(TABLE_FILES): tpch-dbgen/dbgen
	cd tpch-dbgen && ./dbgen -v -f -s $(SCALE_FACTOR)
	chmod +r $(TABLE_FILES)

tpch-dbgen/dbgen: tpch-dbgen/makefile
	cd tpch-dbgen && $(MAKE)

$(QUERY_DIR)/%.sql: $(LOGICA_DIR)/%.l
	mkdir -p $(QUERY_DIR)
	$(LOGICA) $^ print Query > $@

queries: $(QUERY_FILES)

benchmark:
	mkdir -p build
	python3 src/benchmark.py --check-equivalent --db-address TPC-H.db --dir-a logica-sql --dir-b sql -d sqlite3 > build/benchmark.csv

clean:
	rm -rf TPC-H.db $(TABLE_FILES) tpch-dbgen/dbgen
	rm -rf $(QUERY_FILES)

all: queries benchmark
