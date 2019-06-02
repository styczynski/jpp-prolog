/**
 * <module> Graph utilities
 *
 * This module contains utilites to operate on EF-graphs.
 *
 * @author Piotr Styczynski
 * @license MIT
 */

/*
 * Recursive helper to check for existence of Hamiltonian path on E-edges.
 *
 * @param CurrentLabel - current node label (during graph traversal)
 * @param GAssoc - Input graph G
 * @param LabelFrom - start of the Hamiltonian path
 * @param LabelTo - end of the Hamiltonian path
 * @param Trace0 - set of currently accessed node labels
 */
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

/*
 * Checks for existence of Hamiltonian path on E-edges from
 * node with label LabelFrom to node with label LabelTo in graph GAssoc.
 *
 * @param GAssoc - Input graph G
 * @param LabelFrom - start of the Hamiltonian path
 * @param LabelTo - end of the Hamiltonian path
 */
graph_exist_e_hamil_path(GAssoc, LabelFrom, LabelTo) :-
    assoc_has_key(GAssoc, LabelFrom),
    assoc_has_key(GAssoc, LabelTo),
    set_new(EmptyTrace),
    graph_exist_e_hamil_path_rec(LabelFrom, GAssoc, LabelFrom, LabelTo, EmptyTrace).

/*
 * Checks if the given node have no output E-edges.
 *
 * @param N - node to check
 */
graph_node_has_no_e_output(node(_, [], _)).

/*
 * Checks if the given node have no input E-edges.
 *
 * @param N - node to check
 * @param G - input graph
 */
graph_node_has_no_e_input(node(Label, _, _), GAssoc) :-
    assoc_new(E),
    assoc_fold(GAssoc, graph_fold_get_e_neighbours, [], E, ENeighbours),
    \+ set_has(ENeighbours, Label).

/*
 * For pair of nodes E, F such that there exist a node v with E-edge to E and F-edge to F
 * checks if there is no node such that E has F-edge to it and F has E-Edge to it.
 *
 * @param [E, F] - Input label pair
 * @param G - Input graph
 */
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

/*
 * For pair of nodes E, F such that E has E-edge to some node v and F has F-edge to the same node v checks if
 * there is no such node u that it has F-edge to E and E-edge to F.
 *
 * @param [E, F] - Input label pair
 * @param G - Input graph
 */
graph_node_ef_edges_pair_does_not_well_permute_in([ELabel, _], GAssoc) :-
    assoc_get(GAssoc, ELabel, NodeE),
    NodeE = node(ELabel, _, NodeENeigboursFLabels),
    map(NodeENeigboursFLabels, graph_map_node_label_to_node, [GAssoc], NodeENeigboursF),
    filter(NodeENeigboursF, graph_node_has_e_edge_to, [...], PermuteInCandidates),
    proper_length(PermuteInCandidates, PermuteInCandidatesCount),
    PermuteInCandidatesCount = 0.

/*
 * Checks if the single node breaks the statement of well-permutation for given graph.
 *
 * @param N - Input node
 * @param G - Input graph
 */
graph_node_does_not_well_permute(node(Label, N1, N2), GAssoc) :-
    product(N1, N2, EFPairs),
    \+ EFPairs = [],
    all(EFPairs, graph_node_ef_edges_pair_does_not_well_permute_out, [GAssoc]),
    assoc_filter_values(GAssoc, graph_node_has_e_edge_to, [Label], NodesWithEEdgeThere),
    product(NodesWithEEdgeThere, N2, EFPairs2),
    all(EFPairs2, graph_node_ef_edges_pair_does_not_well_permute_in, [GAssoc]).

/*
 * Maps node label to nide itself
 *
 * @param L - Input node label
 * @param N - Output node
 * @param G - Input graph
 */
graph_map_node_label_to_node(NodeLabel, Node, GAssoc) :-
    assoc_get(GAssoc, NodeLabel, Node).

/*
 * Checks if node has an E-edge to other node i.e if theres E-edge <N,T>.
 *
 * @param L - Input node
 * @param T - Input node
 */
graph_node_has_e_edge_to(node(_, N1, _), TargetLabel) :-
    member(TargetLabel, N1).

/*
 * Checks if the node has strictly more direct F-neighbours than the threshold value.
 *
 * @param L - Input node
 * @param T - Edges threshold
 */
graph_node_has_more_than_f_neighbours(node(_, _, N2), MaxFNeighbours) :-
    proper_length(N2, FNeighboursCount),
    FNeighboursCount > MaxFNeighbours.

/*
 * Checks if the node A is connected to node B i.e if there exists an edge A->B.
 *
 * @param A - Input node A
 * @param B - Input node B
 */
graph_pair_does_represent_e_edge([node(_, EEdges, _), node(TargetLabel, _, _)]) :-
    member(TargetLabel, EEdges).

/*
 * Generate associative array representation of EF-Graph.
 * This representation is used intensively (mostly as GAssoc variables).
 *
 * G - Input graph in raw EF-Graph format
 * GAssoc - Output associative array graph representation
 */
graph_get_assoc([], GAssoc) :- assoc_new(GAssoc).
graph_get_assoc([node(Label,N1,N2)|TNodes], GAssoc) :-
    graph_get_assoc(TNodes, GAssoc1),
    assoc_put(GAssoc1, Label, node(Label,N1,N2), GAssoc).

/*
 * Helper folding function to get set of all neighbours (joined E and F sets).
 *
 * @param L - Node label
 * @param N - Node
 * @param A - accumulator (set)
 * @param R - A with added sets E and F of the current node
 */
graph_fold_get_all_neighbours(_, node(_,N1,N2), Acc, Res) :-
    set_put_all(Acc, N1, Acc1),
    set_put_all(Acc1, N2, Res).

/*
 * Helper folding function to get set of E-neighbours (only E set).
 *
 * @param L - Node label
 * @param N - Node
 * @param A - accumulator (set)
 * @param R - A with added set E of the current node
 */
graph_fold_get_e_neighbours(_, node(_,N1,_), Acc, Res) :-
    set_put_all(Acc, N1, Res).

/*
 * Checks if F-route LabelsList2 is succesor of F-route LabelsList1.
 *
 * @param G - Input graph
 * @param LabelsList1 - Input F-route
 * @param LabelsList2 - Input F-route
 */
graph_is_f_route_succ(GAssoc, LabelsList1, LabelsList2) :-
    map(LabelsList1, graph_map_node_label_to_node, [GAssoc], List1),
    map(LabelsList2, graph_map_node_label_to_node, [GAssoc], List2),
    proper_length(LabelsList1, Size1),
    proper_length(LabelsList2, Size2),
    Size1 =< Size2,
    zip(List1, List2, ListZip),
    all(ListZip, graph_pair_does_represent_e_edge, []).
