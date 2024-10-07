% Representation av grafen
line(a, b).
line(a, c).
line(b, c).
line(b, a).
line(b, e).
line(c, d).
line(d, e).

% Huvudpredikatet för att hitta en väg mellan Start och End
path(Start, End, ReversePath) :-
    travel(Start, End, [Start], Path),  % Starta resan från Start, med Start i den besökta listan
    reverse(ReversePath, Path).         % Vänd på vägen

% Hjälppredikatet travel/4
% Fall 1: Vi har nått nod End, bygg vägen
travel(Start, End, Visited, [End|Visited]) :-  % Om vi når nod End, bygg vägen
    line(Start, End).                       % Kontrollera att det finns en linje mellan Start och End

% Fall 2: Vi har inte nått nod End, fortsätt att söka vägar
travel(Start, End, Visited, Path) :-  % Fortsätt att söka vägar
    line(Start, Next),                  % Hitta en granne Next till Start
    Next \= End,                        % Se till att vi inte går direkt till End
    \+ member(Next, Visited),          % Se till att vi inte redan har besökt Next
    travel(Next, End, [Next|Visited], Path).  % Rekursivt sök efter vägen från Next till End

