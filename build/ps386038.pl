/**
 * Code for handling EF-Graphs.
 * I used there self-made higher order function to easier handle generic graphs processing.
 * It can be easily changed into normal non-hof definitions.
 *
 * Piotr Styczynski 2019, MIM UW (JPP)
 * @license MIT
 */

/**
 * <module> Lists utilities
 *
 * This module provides more refined utilities than Prolog builtins to operate on lists.
 *
 * @author Piotr Styczynski
 * @license MIT
 */

/*
 * Filters list using provided filter function.
 *
 * Note:
 *   FilterFn is a function of signature fn(item, Args...)
 *
 * @param L - Input list
 * @param FilterFn - Filtering function
 * @param Args - Additional arguments supplied to the filtering function
 * @param R - List that is the result of applying the filter
 */
filter([], _, _, []).
filter([HList|TList], FilterFn, Args, R) :-
    filter(TList, FilterFn, Args, R1),
    Goal =.. [FilterFn,HList|Args],
    call(Goal),
    R = [HList|R1].
filter([HList|TList], FilterFn, Args, R) :-
    filter(TList, FilterFn, Args, R),
    Goal =.. [FilterFn,HList|Args],
    \+ call(Goal).

/*
 * Checks if any item on the list satisfies the supplied predicate.
 *
 * Note:
 *   FilterFn is a function of signature fn(item, Args...)
 *
 * @param L - Input list
 * @param FilterFn - Filtering function
 * @param Args - Additional arguments supplied to the filtering function
 */
any(L, FilterFn, Args) :-
    filter(L, FilterFn, Args, Out),
    proper_length(Out, Len),
    Len > 0.

/*
 * Checks if all of the items on the list satisfies the supplied predicate.
 *
 * Note:
 *   FilterFn is a function of signature fn(item, Args...)
 *
 * @param L - Input list
 * @param FilterFn - Filtering function
 * @param Args - Additional arguments supplied to the filtering function
 */
all([], _, _).
all(L, FilterFn, Args) :-
    filter(L, FilterFn, Args, Out),
    proper_length(Out, Len),
    proper_length(L, Len0),
    Len0 = Len.

/*
 * Maps the items of the list using mapping function.
 *
 * Note:
 *   MapFn is a function of signature fn(item, mappedItem, Args...)
 *
 * @param L - Input list
 * @param MapFn - Mapping function
 * @param Args - Additional arguments supplied to the mapping function
 * @param R - List that is the result of mapping the input list
 */
map([], _, _, []).
map([Item|TList], MapFn, Args, [RItem|TRList]) :-
    Goal =.. [MapFn,Item,RItem|Args],
    call(Goal),
    map(TList, MapFn, Args, TRList).

/*
 * Checks if the list contains only unique elements.
 *
 * @param L - Input list
 */
unique([]).
unique([HList|TList]) :- \+ member(HList, TList), unique(TList).

/*
 * Zips single element with the input list.
 * Note:
 *   For item I=1 and list L = [a,b,c...,z] the result will be a list [[1,a],[1,b],...[1,z]].
 *
 * @param I - Input item
 * @param L - Input list
 * @param R - Resulting list
 */
product_single(_, [], []).
product_single(Item, [HBList|TBList], R) :-
    product_single(Item,TBList,R1),
    R = [[Item,HBList]|R1].

/*
 * For given input lists A, B calculates a list with all pairs such that the first elements is in A and
 * the second one is in B.
 * Note:
 *   For A=[1,2] and B=[3,4] returns [[1,3],[1,4],[2,3],[2,4]]
 *
 * @param A - Input list A
 * @param B - Input list B
 * @param R - List that is a product AxB
 */
product([], _, []).
product(_, [], []).
product([HAList|TAList],BList, R) :-
    product_single(HAList,BList,R1),
    product(TAList,BList,R2),
    append(R1,R2,R).

/*
 * Zips two lists together. The zipped list ends if the first one ends.
 * Note:
 *   For A=[1,2], B=[3,4,5] the result is [[1,3],[2,4]].
 *
 * @param A - Input list A
 * @param B - Input list B
 * @param R - List A zipped with B
 */
zip([], _, []).
zip([HAList|TAList],[HBList|TBList], R) :-
    zip(TAList,TBList,R1),
    R = [[HAList,HBList]|R1].
/**
 * <module> Associative arrays utilities
 *
 * This module provides basic utilities to operate on associative arrays.
 *
 * @author Piotr Styczynski
 * @license MIT
 */

/*
 * Creates new associative array
 * @param X - Empty associative array
 */
assoc_new(X) :- X = assoc([]).

/* Unwrapped helper for assoc_del */
assoc_del_list([], _, RAssoc) :- RAssoc = [].
assoc_del_list([[K,_]|TAssoc], K, RAssoc) :- assoc_del_list(TAssoc, K, RAssoc).
assoc_del_list([[Key, Data]|TAssoc], K, [[Key, Data]|TRAssoc]) :- assoc_del_list(TAssoc, K, TRAssoc).

/* Unwrapped helper for assoc_get */
assoc_get_list([[K, Data]|_], K, Data).
assoc_get_list([[_, _]|TAssoc], K, Data) :- assoc_get_list(TAssoc, K, Data).

/* Unwrapped helper for assoc_keys */
assoc_keys_list([], []).
assoc_keys_list([[Key, _]|TAssoc], L) :- assoc_keys_list(TAssoc, L1), L = [Key|L1].

/* Unwrapped helper for assoc_values */
assoc_values_list([], []).
assoc_values_list([[_, Data]|TAssoc], L) :- assoc_values_list(TAssoc, L1), L = [Data|L1].

/* Unwrapped helper for assoc_map */
assoc_map_list([], _, _, []).
assoc_map_list([[Key, Data]|TAssoc], MapFn, Args, [HRList|TRList]) :-
    Goal =.. [MapFn,Key,Data,HRList|Args],
    call(Goal),
    assoc_map_list(TAssoc, MapFn, Args, TRList).

/* Unwrapped helper for assoc_fold */
assoc_fold_list([], _, _, Acc, Acc).
assoc_fold_list([[Key, Data]|TAssoc], FoldFn, Args, Acc, Res) :-
    assoc_fold_list(TAssoc,FoldFn,Args,Acc,Res1),
    Goal =.. [FoldFn,Key,Data,Res1,Res|Args],
    call(Goal).

/* Unwrapped helper for assoc_filter */
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

/* Unwrapped helper for assoc_filter_values */
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

/*
 * Removes key from associative array
 * Note: Removals on non-existing keys have no effect
 *
 * @param L - Input associative array
 * @param K - Key to remove
 * @param R - Returned associative array without the key K
 */
assoc_del(assoc(L), K, assoc(R)) :- assoc_del_list(L, K, R).

/*
 * Adds key, value pair to the existing associative array
 * Note: Overrides any existing keys if they are the same
 *
 * @param L - Input associative array
 * @param K - Key to insert
 * @param D - Data to insert (stored under the given key)
 * @param R - Returned associative array with the new entry [K -> D]
 */
assoc_put(assoc(L), K, D, assoc(R)) :- assoc_del_list(L, K, R1), R = [[K, D]|R1].

/*
 * Retrieves the data stored under the given key.
 *
 * @param L - Input associative array
 * @param K - Key to retrieve
 * @param R - Returned data stored under key K
 */
assoc_get(assoc(L), K, R) :- assoc_get_list(L, K, R).

/*
 * Checks if the associative array has the supplied key.
 *
 * @param L - Input associative array
 * @param K - Key to check for
 */
assoc_has_key(assoc(L), K) :- assoc_get_list(L, K, _).

/*
 * Retieves all associative array keys as a list.
 *
 * @param L - Input associative array
 * @param R - List of keys
 */
assoc_keys(assoc(L), R) :- assoc_keys_list(L, R).

/*
 * Retieves all associative array values as a list.
 *
 * @param L - Input associative array
 * @param R - List of values
 */
assoc_values(assoc(L), R) :- assoc_values_list(L, R).

/*
 * Checks the number of stored [Key -> Data] pairs.
 *
 * @param L - Input associative array
 * @param R - Number of entries stored
 */
assoc_count(assoc(L), R) :- proper_length(L, R).

/*
 * Maps each data value of the associative array using the given function.
 *
 * Note:
 *   MapFn is a function of signature fn(key, data, mappedElement, Args...)
 *
 * @param L - Input associative array
 * @param MapFn - Function that maps entries
 * @param Args - Additional arguments supplied to the mapping function
 * @param R - Associative array that is the result of mapping
 */
assoc_map(assoc(L), MapFn, Args, assoc(R)) :- assoc_map_list(L, MapFn, Args, R).

/*
 * Performs fold-left operation on data values of the associative array using provided function.
 *
 * Note:
 *   FoldFn is a function of signature fn(key, data, acc, foldedValue, Args...)
 *
 * @param L - Input associative array
 * @param FoldFn - Function that folds the array
 * @param Args - Additional arguments supplied to the folding function
 * @param Acc - Initial accumulator value
 * @param R - Value that is a result of folding
 */
assoc_fold(assoc(L), FoldFn, Args, Acc, R) :- assoc_fold_list(L, FoldFn, Args, Acc, R).

/*
 * Filters data entries of associative array using provided filter function.
 *
 * Note:
 *   FilterFn is a function of signature fn(key, data, Args...)
 *
 * @param L - Input associative array
 * @param FilterFn - Filtering function
 * @param Args - Additional arguments supplied to the filtering function
 * @param R - Associative array that is the result of applying the filter
 */
assoc_filter(assoc(L), FilterFn, Args, assoc(R)) :- assoc_filter_list(L, FilterFn, Args, R).

/*
 * Filters data entries of associative array using provided filter function.
 * Instead of passing key and data parameters to filter like assoc_filter(...) does,
 * this function passes only the data value.
 *
 * Note:
 *   FilterFn is a function of signature fn(data, Args...)
 *
 * @param L - Input associative array
 * @param FilterFn - Filtering function
 * @param Args - Additional arguments supplied to the filtering function
 * @param R - Associative array that is the result of applying the filter
 */
assoc_filter_values(assoc(L), FilterFn, Args, assoc(R)) :- assoc_filter_values_list(L, FilterFn, Args, R).

/*
 * Gets the next available key value and returns the associative array without it.
 * Used for interation on associative arrays or for getting any single key of it.
 *
 * @param L - Input associative array
 * @param Key - Returned any key that is present in the associative array or assoc_none atom if array is empty
 * @param R - Returned associative array without the returned key
 */
assoc_next_key(assoc([]), assoc_none, assoc([])).
assoc_next_key(assoc([[Key,_]|TAssoc]), Key, assoc(TAssoc)).
/**
 * <module> Sets utilities
 *
 * This module provides basic utilities to operate on sets of elements.
 * Each set is an associative array where entries are of the form [K->K] and K is an item in the set.
 * Thats why you can use ordinary assoc_* functions on sets.
 *
 * @author Piotr Styczynski
 * @license MIT
 */

/*
 * Creates a new set
 * @param X - Empty set with no elements
 */
set_new(X) :- X = assoc([]).

/*
 * Removes element from the set
 *
 * @param L - Input set
 * @param K - Element to be removed
 * @param R - Input set without element K
 */
set_del(L, K, R) :- assoc_del(L, K, R).

/*
 * Adds element to the set
 *
 * @param L - Input set
 * @param K - Element to be added
 * @param R - Input set with element K
 */
set_put(L, K, R) :- assoc_put(L, K, K, R).

/*
 * Checks if set contains the supplied element.
 *
 * @param L - Input set
 * @param K - Element to be checked
 */
set_has(L, K) :- assoc_has_key(L, K).

/*
 * Inserts all elements from the list to the set.
 *
 * @param S - Input set
 * @param L - List of elements to be inserted
 * @param R - Set with all elements added
 */
set_put_all(L, [], L).
set_put_all(L, [HKeys|TKeys], R) :- set_put(L, HKeys, L1), set_put_all(L1, TKeys, R).

/*
 * Obtains the list of all elements in the set.
 *
 * @param S - Input set
 * @param L - List with all set elements
 */
set_items(L, R) :- assoc_keys(L, R).

/*
 * Checks if two sets contain the same elements.
 *
 * @param A - Input set
 * @param B - Input set
 */
set_eq(A,B) :-
    set_subset(A, B),
    set_subset(B, A).

/*
 * Checks if set A is a subset of B.
 *
 * @param A - Input set
 * @param B - Input set
 */
set_subset(A, B) :-
    set_items(A, ItemsA),
    set_items(B, ItemsB),
    subset(ItemsA, ItemsB).

/*
 * Create new set from the given list of items.
 *
 * @param L - Input list with elements
 * @param R - Set created from the elements
 */
set_from_list(L, R) :-
    set_new(E),
    set_put_all(E, L, R).

/*
 * Removes elements of set B from set A.
 *
 * @param A - Input set
 * @param B - Input set
 * @param R - Set with all elements from A except those from B
 */
set_subtract(A, B, R) :-
    set_new(E),
    set_items(A, ItemsA),
    set_items(B, ItemsB),
    subtract(ItemsA, ItemsB, ItemsR),
    set_put_all(E, ItemsR, R).
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

/* TODO */
graph_map_node_assoc_to_node_label(node(Label,_,_), Label).

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
jestEFGrafem(G) :-
    graph_get_assoc(G, GAssoc),
    assoc_new(E),
    assoc_fold(GAssoc, graph_fold_get_all_neighbours, [], E, NeighboursAssoc),
    assoc_keys(GAssoc, NodeLabelsList),
    map(G, graph_map_node_assoc_to_node_label, [], NodeLabelsListFull),
    unique(NodeLabelsListFull),
    set_from_list(NodeLabelsList, NodeLabelsSet),
    set_subset(NeighboursAssoc, NodeLabelsSet).

/*
 * Checks if the graph G is well-layouted
 */
jestDobrzeUlozony(G) :-
    jestEFGrafem(G),
    graph_get_assoc(G, GAssoc),
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

    graph_exist_e_hamil_path(GAssoc, GraphSource, GraphSink),
    assoc_filter_values(GAssoc, graph_node_has_more_than_f_neighbours, [3], NodesWithMoreThan3FNeighours),
    assoc_count(NodesWithMoreThan3FNeighours, NodesWithMoreThan3FNeighoursCount),

    %format("NodesWithMoreThan3FNeighoursCount = ~w~n", NodesWithMoreThan3FNeighoursCount),
    NodesWithMoreThan3FNeighoursCount = 0.

/*
 * Checks if the graph G is well-permuting
 */
jestDobrzePermutujacy(G) :-
    graph_get_assoc(G, GAssoc),
    assoc_filter_values(GAssoc, graph_node_does_not_well_permute, [GAssoc], NodesNotWellPermuting),
    assoc_count(NodesNotWellPermuting, NodesNotWellPermutingCount),
    NodesNotWellPermutingCount = 0.

/*
 * Checks if the F-route L2 is successor of F-route L1
 */
jestSucc(G, L1, L2) :-
    graph_get_assoc(G, GAssoc),
    graph_is_f_route_succ(GAssoc, L1, L2).