ensure_loaded(assoc).
ensure_loaded(set).
ensure_loaded(utils).

jestEFGrafem(G) :-
    graph_get_assoc(G, GAssoc),
    assoc_new(E),
    assoc_fold(GAssoc, graph_fold_get_all_neighbours, [], E, NeighboursAssoc),
    assoc_keys(GAssoc, NodeLabelsList),
    unique(NodeLabelsList),
    set_from_list(NodeLabelsList, NodeLabelsSet),
    set_subset(NeighboursAssoc, NodeLabelsSet).

jestDobrzeUlozony(G) :-
    jestEFGrafem(G),
    graph_get_assoc(G, GAssoc),
    assoc_filter_values(GAssoc, graph_node_has_no_e_output, [], NodesWithoutOutputAssoc),
    assoc_count(NodesWithoutOutputAssoc, NodesWithoutOutputCount),
    assoc_filter_values(GAssoc, graph_node_has_no_e_input, [GAssoc], NodesWithoutInputAssoc),
    assoc_count(NodesWithoutInputAssoc, NodesWithoutInputCount),
    NodesWithoutOutputCount = 1,
    NodesWithoutInputCount = 1,
    assoc_next_key(NodesWithoutInputAssoc, GraphSource, _),
    assoc_next_key(NodesWithoutOutputAssoc, GraphSink, _),
    graph_exist_e_hamil_path(GAssoc, GraphSource, GraphSink),
    assoc_filter_values(GAssoc, graph_node_has_more_than_f_neighbours, [3], NodesWithMoreThan3FNeighoursCount),
    NodesWithMoreThan3FNeighoursCount = 0.

jestDobrzePermutujacy(G) :-
    graph_get_assoc(G, GAssoc),
    assoc_filter_values(GAssoc, graph_node_does_not_well_permute, [GAssoc], NodesNotWellPermuting),
    assoc_count(NodesNotWellPermuting, NodesNotWellPermutingCount),
    NodesNotWellPermutingCount = 0.

jestSucc(G, L1, L2) :-
    graph_get_assoc(G, GAssoc),
    graph_is_f_route_succ(GAssoc, L1, L2).