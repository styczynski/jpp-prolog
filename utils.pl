ensure_loaded(assoc).
ensure_loaded(set).

unique([]).
unique([HList|TList]) :- \+ member(HList, TList), unique(TList).

nodeLabel(node(NodeLabel, _, _), NodeLabel).

nodeLabels([], []).
nodeLabels([HNodes|TNodes], [HLabels|TLabels]) :- nodeLabel(HNodes, HLabels), nodeLabels(TNodes, TLabels).

uniqueNodeLabels(LNodes) :- nodeLabels(LNodes, NodeLabels), unique(NodeLabels).