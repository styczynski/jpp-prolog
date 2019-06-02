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

graph_node_ef_edges_pair_does_not_well_permute_out([ELabel, FLabel], GAssoc) :-
    assoc_get(GAssoc, ELabel, NodeE),
    assoc_get(GAssoc, FLabel, NodeF),
    NodeE = node(ELabel, _, NodeENeigboursF),
    NodeF = node(FLabel, NodeFNeighboursE, _),
    proper_length(NodeFNeighboursE, NodeFNeighboursECount),
    \+ NodeFNeighboursECount = 0,
    intersection(NodeENeigboursF, NodeFNeighboursE, Intersect),
    proper_length(Intersect, IntersectCount),
    IntersectCount = 0.

graph_node_ef_edges_pair_does_not_well_permute_in([ELabel, FLabel], GAssoc) :-
    assoc_get(GAssoc, ELabel, NodeE),
    NodeE = node(ELabel, _, NodeENeigboursFLabels),
    map(NodeENeigboursFLabels, graph_map_node_label_to_node, [GAssoc], NodeENeigboursF),
    filter(NodeENeigboursF, graph_node_has_e_edge_to, [...], PermuteInCandidates),
    proper_length(PermuteInCandidates, PermuteInCandidatesCount),
    PermuteInCandidatesCount = 0.

graph_node_does_not_well_permute(node(Label, N1, N2), GAssoc) :-
    product(N1, N2, EFPairs),
    \+ EFPairs = [],
    all(EFPairs, graph_node_ef_edges_pair_does_not_well_permute_out, [GAssoc]),
    assoc_filter_values(GAssoc, graph_node_has_e_edge_to, [Label], NodesWithEEdgeThere),
    product(NodesWithEEdgeThere, N2, EFPairs2),
    all(EFPairs2, graph_node_ef_edges_pair_does_not_well_permute_in, [GAssoc]).

graph_map_node_label_to_node(NodeLabel, Node, GAssoc) :-
    assoc_get(GAssoc, NodeLabel, Node).

graph_node_has_e_edge_to(node(_, N1, _), TargetLabel) :-
    member(TargetLabel, N1).

graph_node_has_more_than_f_neighbours(node(_, _, N2), MaxFNeighbours) :-
    proper_length(N2, FNeighboursCount),
    FNeighboursCount > MaxFNeighbours.

graph_get_assoc([], GAssoc) :- assoc_new(GAssoc).
graph_get_assoc([node(Label,N1,N2)|TNodes], GAssoc) :-
    graph_get_assoc(TNodes, GAssoc1),
    assoc_put(GAssoc1, Label, node(Label,N1,N2), GAssoc).

graph_fold_get_all_neighbours(Key, node(_,N1,N2), Acc, Res) :-
    set_put_all(Acc, N1, Acc1),
    set_put_all(Acc1, N2, Res).

graph_fold_get_e_neighbours(Key, node(_,N1,_), Acc, Res) :-
    set_put_all(Acc, N1, Res).
