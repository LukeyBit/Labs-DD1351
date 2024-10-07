% Huvudpredikatet partstring/3
partstring(List, L, F) :-
    subsequence(List, F),  % Generera en konsekutiv delsekvens F
    length(F, L).          % Kontrollera att längden på F är L

% För varje siffra i listan, generera alla sekvenser som börjar med siffran
subsequence([], []).
subsequence([H|T], [H|SubT]) :-  % Ta första elementet och generera alla listor som elementet är prefix till
    prefix(SubT, T).
subsequence([_|T], SubT) :-      % Gå vidare i listan
    subsequence(T, SubT).

% För en siffra, generera alla listor som börjar med siffran
prefix([], _).
prefix([H|T], [H|Rest]) :-
    prefix(T, Rest).
