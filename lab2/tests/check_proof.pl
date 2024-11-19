% Verify the proof from the input file
verify(InputFileName) :-
    see(InputFileName),
    read(Prems), read(Goal), read(Proof),
    seen,
    % write('Premises after reading: '), writeln(Prems),
    valid_proof(Prems, Goal, Proof).

% Check if the proof is valid
valid_proof(Prems, Goal, Proof) :-
    % Ensure the last line of the proof matches the goal
    last(Proof, [_, Goal, _]),
    % Check each line of the proof
    check_proof(Proof, Prems, []).

% Check each line of the proof
check_proof([], _, _).
check_proof([Row | Rest], Prems, Previous) :-
    % write('Checking: '), write(Formula), write(' with rule: '), writeln(Rule),
    valid_rule(Row, Prems, Previous),
    check_proof(Rest, Prems, [Row | Previous]).

% Define valid rules

% Premise rule: Ensure formula is in premises
valid_rule([_, Formula, premise], Prems, _) :-
    member(Formula, Prems).

% Assumption rule
% Calls check_proof on assumption box
valid_rule([[Line, Formula, assumption] | Box], Prems, Previous) :-
    check_proof(Box, Prems, [[Line, Formula, assumption] | Previous]).

% Copy rule: Copy a formula from a previous line in the proof
valid_rule([_, Formula, copy(Line)], _, Previous) :-
    member([Line, Formula, _], Previous).

% Implication Introduction (→i)
valid_rule([_, imp(Formula1, Formula2), impint(Line1, Line2)], _, Previous) :-
    member([[Line1, Formula1, assumption] | Box], Previous),
    last([[Line1, Formula1, assumption] | Box], [Line2, Formula2, _]).

% Implication Elimination (→e)
valid_rule([_, Formula2, impel(Line1, Line2)], _, Previous) :-
    member([Line1, Formula1, _], Previous),
    member([Line2, imp(Formula1, Formula2), _], Previous).

% And introduction rule
valid_rule([_, and(Formula1, Formula2), andint(Line1, Line2)], _, Previous) :-
    member([Line1, Formula1, _], Previous),
    member([Line2, Formula2, _], Previous).

% And elimination rules
valid_rule([_, Formula, andel1(Line)], _, Previous) :-
    member([Line, and(Formula, _), _], Previous).

valid_rule([_, Formula, andel2(Line)], _, Previous) :-
    member([Line, and(_, Formula), _], Previous).

% Or introduction rules
valid_rule([_, or(Formula, _), orint1(Line)], _, Previous) :-
    member([Line, Formula, _], Previous).

valid_rule([_, or(_, Formula), orint2(Line)], _, Previous) :-
    member([Line, Formula, _], Previous).

% Or elimination rule
valid_rule([_, Formula3, orel(Line1, Line2, Line3, Line4, Line5)], _, Previous) :-
    member([Line1, or(Formula1, Formula2), _], Previous),
    member([[Line2, Formula1, assumption] | Box1], Previous),
    last([Line3, Formula3, _], Box1),
    member([[Line4, Formula2, assumption] | Box2], Previous),
    last([Line5, Formula3, _], Box2).

% Negation introduction rule
valid_rule([_, neg(Formula), negint(Line1, Line2)], _, Previous) :-
    member([[Line1, Formula, assumption] | Box], Previous),
    last([Line2, cont, _], Box).

% Negation elimination rule
valid_rule([_, cont, negel(Line1, Line2)], _, Previous) :-
    member([Line1, Formula, _], Previous),
    member([Line2, neg(Formula), _], Previous).

% Contradiction elimination rule
valid_rule([_, _, contel(Line)], _, Previous) :-
    member([Line, cont, _], Previous).

% Double negation introduction rule
valid_rule([_, neg(neg(Formula)), negnegint(Line)], _, Previous) :-
    member([Line, Formula, _], Previous).

% Double negation elimination rule
valid_rule([_, Formula, negnegel(Line)], _, Previous) :-
    member([Line, neg(neg(Formula)), _], Previous).

% Modus tollens (MT) rule
valid_rule([_, neg(Formula1), mt(Line1, Line2)], _, Previous) :-
    member([Line1, imp(Formula1, Formula2), _], Previous),
    member([Line2, neg(Formula2), _], Previous).

% Proof By Cases (PBC) rule
valid_rule([_, Formula, pbc(Line1, Line2)], _, Previous) :-
    member([[Line1, neg(Formula), assumption] | Box], Previous),
    member([Line2, cont, _], Box),
    last([Line2, cont, _], Box).

% Law Of Excluded Middle (LEM) rule
valid_rule([_, or(Formula, neg(Formula)), lem], _, _).