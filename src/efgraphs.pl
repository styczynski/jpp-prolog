/**
 * <module> EF-Graphs library module
 *
 * This module contains main definitions to work with EF-Graphs.
 *
 * @author Piotr Styczynski
 * @license MIT
 */

/*
 * Checks if the graph G is a valid representation of EF-Graph
 */
jestEFGrafem_G0(G0, G, GAssoc) :-
    complete_g(G0, G),
    graph_get_assoc(G, GAssoc),
    assoc_new(E),
    assoc_fold(GAssoc, graph_fold_get_all_neighbours, [], E, NeighboursAssoc),
    assoc_keys(GAssoc, NodeLabelsList),
    map(G, graph_map_node_assoc_to_node_label, [], NodeLabelsListFull),
    unique(NodeLabelsListFull),
    set_from_list(NodeLabelsList, NodeLabelsSet),
    set_subset(NeighboursAssoc, NodeLabelsSet).

/*
 * Checks if the graph G is a valid representation of EF-Graph
 */
jestEFGrafem(G0) :-
    jestEFGrafem_G0(G0, _, _).

/*
 * Checks if the graph G is well-layouted
 */
jestDobrzeUlozony(G0) :-
    jestEFGrafem_G0(G0, G, GAssoc),
    assoc_filter_values(GAssoc, graph_node_has_no_e_output, [], NodesWithoutOutputAssoc),
    assoc_count(NodesWithoutOutputAssoc, NodesWithoutOutputCount),
    assoc_filter_values(GAssoc, graph_node_has_no_e_input, [GAssoc], NodesWithoutInputAssoc),
    assoc_count(NodesWithoutInputAssoc, NodesWithoutInputCount),
    %format("NodesWithoutOutputCount = ~w~n", NodesWithoutOutputCount),
    %format("NodesWithoutInputCount = ~w~n", NodesWithoutInputCount),

    NodesWithoutOutputCount = 1,
    NodesWithoutInputCount = 1,
    assoc_next_key(NodesWithoutInputAssoc, GraphSource, _),
    assoc_next_key(NodesWithoutOutputAssoc, GraphSink, _),
    %format("GraphSource = ~w~n", GraphSource),
    %format("GraphSink = ~w~n", GraphSink),

    graph_exist_e_euler_path(GAssoc, GraphSource, GraphSink),
    assoc_filter_values(GAssoc, graph_node_has_more_than_f_neighbours, [3], NodesWithMoreThan3FNeighours),
    assoc_count(NodesWithMoreThan3FNeighours, NodesWithMoreThan3FNeighoursCount),

    %format("NodesWithMoreThan3FNeighoursCount = ~w~n", NodesWithMoreThan3FNeighoursCount),
    NodesWithMoreThan3FNeighoursCount = 0.

/*
 * Checks if the graph G is well-permuting
 */
jestDobrzePermutujacy(G0) :-
    jestEFGrafem_G0(G0, G, GAssoc),
    assoc_filter_values(GAssoc, graph_node_does_not_well_permute, [GAssoc], NodesNotWellPermuting),
    assoc_count(NodesNotWellPermuting, NodesNotWellPermutingCount),
    NodesNotWellPermutingCount = 0.

/*
 * Checks if the F-route L2 is successor of F-route L1
 */
jestSucc(G0, L1, L2) :-
    jestEFGrafem_G0(G0, G, GAssoc),
    graph_is_f_route_succ(GAssoc, L1, L2).