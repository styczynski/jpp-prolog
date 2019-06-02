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