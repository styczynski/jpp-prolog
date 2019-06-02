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

all([], _, _).
all(L, FilterFn, Args) :-
    filter(L, FilterFn, Args, Out),
    proper_length(Out, Len),
    proper_length(L, Len0),
    Len0 = Len.

map([], _, _, []).
map([Item|TList], MapFn, Args, [RItem|TRList]) :-
    Goal =.. [MapFn,Item,RItem|Args],
    call(Goal),
    map(TList, MapFn, Args, TRList).

unique([]).
unique([HList|TList]) :- \+ member(HList, TList), unique(TList).

product_single(_, [], []).
product_single(Item, [HBList|TBList], R) :-
    product_single(Item,TBList,R1),
    R = [[Item,HBList]|R1].

product([], _, []).
product(_, [], []).
product([HAList|TAList],BList, R) :-
    product_single(HAList,BList,R1),
    product(TAList,BList,R2),
    append(R1,R2,R).

zip([], _, []).
zip([HAList|TAList],[HBList|TBList], R) :-
    zip(TAList,TBList,R1),
    R = [[HAList,HBList]|R1].