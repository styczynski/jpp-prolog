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

any(L, FilterFn, Args) :-
    filter(L, FilterFn, Args, Out),
    proper_length(Out, Len),
    Len > 0.

unique([]).
unique([HList|TList]) :- \+ member(HList, TList), unique(TList).
