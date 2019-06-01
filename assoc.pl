ensure_loaded(list).

assoc_new(X) :- X = assoc([]).

assoc_del_list([], _, RAssoc) :- RAssoc = [].
assoc_del_list([[K,_]|TAssoc], K, RAssoc) :- assoc_del_list(TAssoc, K, RAssoc).
assoc_del_list([[Key, Data]|TAssoc], K, [[Key, Data]|TRAssoc]) :- assoc_del_list(TAssoc, K, TRAssoc).

assoc_get_list([[K, Data]|_], K, Data).
assoc_get_list([[_, _]|TAssoc], K, Data) :- assoc_get_list(TAssoc, K, Data).

assoc_keys_list([], []).
assoc_keys_list([[Key, _]|TAssoc], L) :- assoc_keys_list(TAssoc, L1), L = [Key|L1].

assoc_values_list([], []).
assoc_values_list([[_, Data]|TAssoc], L) :- assoc_values_list(TAssoc, L1), L = [Data|L1].

assoc_map_list([], _, _, []).
assoc_map_list([[Key, Data]|TAssoc], MapFn, Args, [HRList|TRList]) :-
    Goal =.. [MapFn,Key,Data,HRList|Args],
    call(Goal),
    assoc_map_list(TAssoc, MapFn, Args, TRList).

assoc_fold_list([], _, _, Acc, Acc).
assoc_fold_list([[Key, Data]|TAssoc], FoldFn, Args, Acc, Res) :-
    assoc_fold_list(TAssoc,FoldFn,Args,Acc,Res1),
    Goal =.. [FoldFn,Key,Data,Res1,Res],
    call(Goal).

assoc_filter_list([], _, _, []).
assoc_filter_list([[Key, Data]|TList], FilterFn, Args, R) :-
    assoc_filter_list(TList, FilterFn, Args, R1),
    Goal =.. [FilterFn,Key,Data|Args],
    call(Goal),
    R = [[Key, Data]|R1].
assoc_filter_list([[Key,Data]|TList], FilterFn, Args, R) :-
    assoc_filter_list(TList, FilterFn, Args, R),
    Goal =.. [FilterFn,Key,Data|Args],
    \+ call(Goal).

assoc_filter_values_list([], _, _, []).
assoc_filter_values_list([[Key, Data]|TList], FilterFn, Args, R) :-
    assoc_filter_values_list(TList, FilterFn, Args, R1),
    Goal =.. [FilterFn,Data|Args],
    call(Goal),
    R = [[Key, Data]|R1].
assoc_filter_values_list([[_,Data]|TList], FilterFn, Args, R) :-
    assoc_filter_values_list(TList, FilterFn, Args, R),
    Goal =.. [FilterFn,Data|Args],
    \+ call(Goal).

assoc_del(assoc(L), K, assoc(R)) :- assoc_del_list(L, K, R).
assoc_put(assoc(L), K, D, assoc(R)) :- assoc_del_list(L, K, R1), R = [[K, D]|R1].
assoc_get(assoc(L), K, R) :- assoc_get_list(L, K, R).
assoc_has_key(assoc(L), K) :- assoc_get_list(L, K, _).
assoc_keys(assoc(L), R) :- assoc_keys_list(L, R).
assoc_values(assoc(L), R) :- assoc_values_list(L, R).
assoc_count(assoc(L), R) :- proper_length(L, R).
assoc_map(assoc(L), MapFn, Args, assoc(R)) :- assoc_map_list(L, MapFn, Args, R).
assoc_fold(assoc(L), FoldFn, Args, Acc, R) :- assoc_fold_list(L, FoldFn, Args, Acc, R).
assoc_filter(assoc(L), FilterFn, Args, assoc(R)) :- assoc_filter_list(L, FilterFn, Args, R).
assoc_filter_values(assoc(L), FilterFn, Args, assoc(R)) :- assoc_filter_values_list(L, FilterFn, Args, R).