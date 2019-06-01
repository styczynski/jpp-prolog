ensure_loaded(assoc).
ensure_loaded(set).
ensure_loaded(list).

graph_exist_e_hamil_path_rec(CurrentLabel, GAssoc, LabelFrom, CurrentLabel, Trace0) :-
    set_eq(GAssoc, Trace0).
graph_exist_e_hamil_path_rec(CurrentLabel, GAssoc, LabelFrom, LabelTo, Trace0) :-
    \+ set_has(Trace0, CurrentLabel),
    set_put(Trace0, CurrentLabel, Trace),
    assoc_get(GAssoc, LabelFrom, NodeFrom),
    NodeFrom = node(LabelFrom, ENeighbours, _),
    any(ENeighbours, graph_exist_e_hamil_path_rec, [GAssoc, LabelFrom, LabelTo, Trace]).

graph_exist_e_hamil_path(GAssoc, LabelFrom, LabelTo) :-
    assoc_has_key(GAssoc, LabelFrom),
    assoc_has_key(GAssoc, LabelTo),
    set_new(EmptyTrace),
    graph_exist_e_hamil_path_rec(LabelFrom, GAssoc, LabelFrom, LabelTo, EmptyTrace).

graph_node_has_no_e_output(node(_, [], _)).
graph_node_has_no_e_input(node(Label, _, _), GAssoc) :-
    assoc_new(E),
    assoc_fold(GAssoc, graph_fold_get_e_neighbours, [], E, ENeighbours),
    \+ set_has(ENeighbours, Label).

graph_get_assoc([], GAssoc) :- assoc_new(GAssoc).
graph_get_assoc([node(Label,N1,N2)|TNodes], GAssoc) :-
    graph_get_assoc(TNodes, GAssoc1),
    assoc_put(GAssoc1, Label, node(Label,N1,N2), GAssoc).

graph_fold_get_all_neighbours(Key, node(_,N1,N2), Acc, Res) :-
    set_put_all(Acc, N1, Acc1),
    set_put_all(Acc1, N2, Res).

graph_fold_get_e_neighbours(Key, node(_,N1,_), Acc, Res) :-
    set_put_all(Acc, N1, Res).