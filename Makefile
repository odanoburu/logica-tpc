# some stuff stolen from https://github.com/lovasoa/TPCH-sqlite
SCALE_FACTOR?=1
TABLES = customer lineitem nation orders partsupp part region supplier
TABLE_FILES = $(foreach table, $(TABLES), tpch-dbgen/$(table).tbl)
QUERIES = 02
LOGICA_DIR=logica
QUERY_DIR=logica-sql
QUERY_FILES = $(foreach query, $(QUERIES), $(QUERY_DIR)/q-$(query).sql)
LOGICA=/home/odanoburu/sites/logica/logica

TPC-H.db: $(TABLE_FILES)
	./create_db.sh $(TABLES)

$(TABLE_FILES): tpch-dbgen/dbgen
	cd tpch-dbgen && ./dbgen -v -f -s $(SCALE_FACTOR)
	chmod +r $(TABLE_FILES)

tpch-dbgen/dbgen: tpch-dbgen/makefile
	cd tpch-dbgen && $(MAKE)

$(QUERY_FILES):
	mkdir -p $(QUERY_DIR)
	$(foreach query, $(QUERIES), $(LOGICA) $(LOGICA_DIR)/q-$(query).l print Query > $(QUERY_DIR)/q-$(query).sql)

queries: $(QUERY_FILES)

benchmark:
	mkdir -p build
	python3 src/benchmark.py --check-equivalent --db-address TPC-H.db --dir-a logica-sql --dir-b sql -d sqlite3 > build/benchmark.csv

clean:
	rm -rf TPC-H.db $(TABLE_FILES) tpch-dbgen/dbgen
	rm -rf $(QUERY_FILES)

all: queries benchmark
