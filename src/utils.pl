graph_exist_e_hamil_path_rec(CurrentLabel, GAssoc, _, CurrentLabel, Trace0) :-
    % format("CHECK FINALIZATION? ~w~n", CurrentLabel),
    set_put(Trace0, CurrentLabel, Trace),
    assoc_count(GAssoc, GAssocCount),
    assoc_count(Trace, TraceCount),
    % format("  | gassoc = ~w~n", GAssocCount),
    % format("  | trace  = ~w~n", TraceCount),
    GAssocCount = TraceCount.
graph_exist_e_hamil_path_rec(CurrentLabel, GAssoc, LabelFrom, LabelTo, Trace0) :-
    \+ CurrentLabel = LabelTo,
    \+ set_has(Trace0, CurrentLabel),
    % format("NOW IN NODE ~w~n", CurrentLabel),
    % format("  | From = ~w~n", LabelFrom),
    % format("  | To   = ~w~n", LabelTo),
    % format("  | Trc  = ~w~n", Trace0),
    set_put(Trace0, CurrentLabel, Trace),
    assoc_get(GAssoc, CurrentLabel, NodeCurrent),
    NodeCurrent = node(CurrentLabel, ENeighbours, _),
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

graph_node_ef_edges_pair_does_not_well_permute_in([ELabel, _], GAssoc) :-
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

graph_pair_does_represent_e_edge([node(_, EEdges, _), node(TargetLabel, _, _)]) :-
    member(TargetLabel, EEdges).

graph_get_assoc([], GAssoc) :- assoc_new(GAssoc).
graph_get_assoc([node(Label,N1,N2)|TNodes], GAssoc) :-
    graph_get_assoc(TNodes, GAssoc1),
    assoc_put(GAssoc1, Label, node(Label,N1,N2), GAssoc).

graph_fold_get_all_neighbours(_, node(_,N1,N2), Acc, Res) :-
    set_put_all(Acc, N1, Acc1),
    set_put_all(Acc1, N2, Res).

graph_fold_get_e_neighbours(_, node(_,N1,_), Acc, Res) :-
    set_put_all(Acc, N1, Res).

graph_is_f_route_succ(GAssoc, LabelsList1, LabelsList2) :-
    map(LabelsList1, graph_map_node_label_to_node, [GAssoc], List1),
    map(LabelsList2, graph_map_node_label_to_node, [GAssoc], List2),
    proper_length(LabelsList1, Size1),
    proper_length(LabelsList2, Size2),
    Size1 =< Size2,
    zip(List1, List2, ListZip),
    all(ListZip, graph_pair_does_represent_e_edge, []).
