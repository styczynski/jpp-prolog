set_new(X) :- X = assoc([]).
set_del(L, K, R) :- assoc_del(L, K, R).
set_put(L, K, R) :- assoc_put(L, K, K, R).
set_has(L, K) :- assoc_has_key(L, K).

set_put_all(L, [], L).
set_put_all(L, [HKeys|TKeys], R) :- set_put(L, HKeys, L1), set_put_all(L1, TKeys, R).
set_items(L, R) :- assoc_keys(L, R).
set_eq(A,B) :-
    set_subset(A, B),
    set_subset(B, A).
set_subset(A, B) :-
    set_items(A, ItemsA),
    set_items(B, ItemsB),
    subset(ItemsA, ItemsB).
set_from_list(L, R) :-
    set_new(E),
    set_put_all(E, L, R).
set_subtract(A, B, R) :-
    set_new(E),
    set_items(A, ItemsA),
    set_items(B, ItemsB),
    subtract(ItemsA, ItemsB, ItemsR),
    set_put_all(E, ItemsR, R).