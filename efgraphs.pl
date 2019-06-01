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
    graph_get_assoc(G, GAssoc),
    assoc_filter_values(GAssoc, graph_node_has_no_e_output, [], NodesWithoutOutputAssoc),
    assoc_count(NodesWithoutOutputAssoc, NodesWithoutOutputCount),
    assoc_filter_values(GAssoc, graph_node_has_no_e_input, [GAssoc], NodesWithoutInputAssoc),
    assoc_count(NodesWithoutInputAssoc, NodesWithoutInputCount),
    NodesWithoutOutputCount = 1,
    NodesWithoutInputCount = 1,
    assoc_next_key(NodesWithoutInputAssoc, GraphSource, _),
    assoc_next_key(NodesWithoutOutputAssoc, GraphSink, _),
    graph_exist_e_hamil_path(GAssoc, GraphSource, GraphSink).

