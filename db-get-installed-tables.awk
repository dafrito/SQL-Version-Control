#!/bin/awk -f

BEGIN {
    t=0
}
{
    if (!($1 in tables)) {
        print $1
        order[t++] = $1;
    }
    tables[$1] = $2;
}
END {
    print time
    for (i=0;i<t;i++) {
        table = order[i]
        if(!(table in printed) && (tables[table] != "drop")) {
            print table;
            printed[table] = true;
        }
    }
}
