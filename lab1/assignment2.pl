remove_duplicates([], []).
remove_duplicates([H|T], [H|R]) :-
    remove_duplicates(T, R),
    not(member(H, R)).
remove_duplicates([H|T], R) :-
    remove_duplicates(T, R),
    member(H, R).