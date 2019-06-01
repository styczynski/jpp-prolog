assoc_new(X) :- X = assoc([]).

assoc_del_list([], _, RAssoc) :- RAssoc = [].
assoc_del_list([[K,_]|TAssoc], K, RAssoc) :- assoc_del_list(TAssoc, K, RAssoc).
assoc_del_list([[Key, Data]|TAssoc], K, [[Key, Data]|TRAssoc]) :- assoc_del_list(TAssoc, K, TRAssoc).

assoc_get_list([[K, Data]|_], K, Data).
assoc_get_list([[_, _]|TAssoc], K, Data) :- assoc_get_list(TAssoc, K, Data).

assoc_del(assoc(L), K, assoc(R)) :- assoc_del_list(L, K, R).
assoc_put(assoc(L), K, D, assoc(R)) :- assoc_del_list(L, K, R1), R = [[K, D]|R1].
assoc_get(assoc(L), K, R) :- assoc_get_list(L, K, R).
