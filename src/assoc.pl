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