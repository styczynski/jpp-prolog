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

insert_if_not_present([], Src, Src).
insert_if_not_present(Dest, [], Dest).
insert_if_not_present(Dest, [Elem], R) :-
    (
        \+ member(Elem, Dest),
        R = [Elem|Dest]
    ) ; (
        member(Elem, Dest),
        R = Dest
    ).
insert_if_not_present(Dest, [HList|TList], R) :-
    (
        insert_if_not_present(Dest, TList, R1),
        \+ member(HList, R1),
        R = [HList|R1]
    ) ; (
        insert_if_not_present(Dest, TList, R1),
        member(HList, R1),
        R = R1
    ).