ensure_loaded(assoc).
ensure_loaded(set).
ensure_loaded(list).

graph_node_has_no_e_output(node(_, [], _)).
graph_node_has_no_e_input(node(Label, _, _), GAssoc) :-
    assoc_new(E),
    assoc_fold(GAssoc, graph_fold_get_e_neighbours, [], E, ENeighbours),
    format("~w~n", ENeighbours),
    format("~w~n", Label),
    format("~w~n", set_has(Label, ENeighbours)),
    \+ set_has(Label, ENeighbours).

graph_get_assoc([], GAssoc) :- assoc_new(GAssoc).
graph_get_assoc([node(Label,N1,N2)|TNodes], GAssoc) :-
    graph_get_assoc(TNodes, GAssoc1),
    assoc_put(GAssoc1, Label, node(Label,N1,N2), GAssoc).

graph_fold_get_all_neighbours(Key, node(_,N1,N2), Acc, Res) :-
    set_put_all(Acc, N1, Acc1),
    set_put_all(Acc1, N2, Res).

graph_fold_get_e_neighbours(Key, node(_,N1,_), Acc, Res) :-
    set_put_all(Acc, N1, Res).