#!/bin/awk -f

BEGIN {
    t=0
}
{
    if (!($1 in tables)) {
        order[t++] = $1;
    }
    tables[$1] = $2;
}
END {
    for (i=0;i<t;i++) {
        table = order[i]
        if(!(table in printed) && (tables[table] != "drop")) {
            print table;
            printed[table] = true;
        }
    }
}
