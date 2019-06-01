ensure_loaded(assoc).

set_new(X) :- X = assoc([]).
set_del(L, K, R) :- assoc_del(L, K, R).
set_put(L, K, R) :- assoc_put(L, K, set_marker, R).
set_has(L, K) :- assoc_get(L, K, Data), Data = set_marker.
