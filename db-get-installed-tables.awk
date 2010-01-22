#!/bin/awk -f

{
    tables[$1] = $2;
}
END {
    for (i in tables) {
        if(tables[i] != "delete")
            print i;
    }
}
