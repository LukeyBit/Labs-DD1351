% Read input file and verify proof
verify(InputFileName) :-
    see(InputFileName),
    read(Prems), read(Goal), read(Proof),
    seen,
    valid_proof(Prems, Goal, Proof).

% Check if the proof is valid
valid_proof(Prems, Goal, Proof) :-
    % Ensure the last line of the proof matches the goal
    last(Proof, [_, Goal, _]),
    % Check each line of the proof
    check_proof(Proof, Prems, []).

% Check each line of the proof
check_proof([], _, _).
check_proof([[_, Formula, Rule] | Rest], Prems, Context) :-
    % Debugging output
    write('Checking: '), write(Formula), write(' with rule: '), writeln(Rule),
    % Validate the current line
    valid_rule(Formula, Rule, Prems, Context),
    % Continue checking the rest of the proof
    check_proof(Rest, Prems, [Formula | Context]).
check_proof([box(Assumption, SubProof) | Rest], Prems, Context) :-
    % Check the sub-proof within the box
    check_subproof(SubProof, Prems, [Assumption | Context]),
    % Continue checking the rest of the proof
    check_proof(Rest, Prems, Context).

% Check each line of the sub-proof
check_subproof([], _, _).
check_subproof([[_, Formula, Rule] | Rest], Prems, Context) :-
    % Debugging output for sub-proofs
    write('Checking sub-proof: '), write(Formula), write(' with rule: '), writeln(Rule),
    % Validate the current line in the sub-proof
    valid_rule(Formula, Rule, Prems, Context),
    % Continue checking the rest of the sub-proof
    check_subproof(Rest, Prems, [Formula | Context]).

% Define valid rules

% Premise: The formula must be one of the premises
valid_rule(Formula, premise, Prems, _) :-
    member(Formula, Prems).

% Assumption: The formula must be in the current context
valid_rule(Formula, assumption, _, Context) :-
    member(Formula, Context).

% Conjunction Introduction (∧i): Combine two formulas into a conjunction
valid_rule(and(A, B), andint(LineA, LineB), _, Context) :-
    nth1(LineA, Context, A),
    nth1(LineB, Context, B).

% Conjunction Elimination (∧e): Extract the first part of a conjunction
valid_rule(A, andel1(Line), _, Context) :-
    nth1(Line, Context, and(A, _)).

% Conjunction Elimination (∧e): Extract the second part of a conjunction
valid_rule(B, andel2(Line), _, Context) :-
    nth1(Line, Context, and(_, B)).

% Disjunction Introduction (∨i): Introduce a disjunction with the first part
valid_rule(or(A, _), orint1(Line), _, Context) :-
    nth1(Line, Context, A).

% Disjunction Introduction (∨i): Introduce a disjunction with the second part
valid_rule(or(_, B), orint2(Line), _, Context) :-
    nth1(Line, Context, B).

% Disjunction Elimination (∨e): Eliminate a disjunction by proving both cases
valid_rule(C, orel(LineDisj, LineA, LineB, LineC, LineD), _, Context) :-
    nth1(LineDisj, Context, or(A, B)),
    nth1(LineA, Context, A),
    nth1(LineB, Context, C),
    nth1(LineC, Context, B),
    nth1(LineD, Context, C).

% Implication Introduction (→i): Introduce an implication from an assumption
valid_rule(imp(A, B), impint(LineA, LineB), _, Context) :-
    nth1(LineA, Context, A),
    nth1(LineB, Context, B).

% Implication Elimination (→e): Apply an implication to derive a conclusion
valid_rule(B, impel(LineA, LineImp), _, Context) :-
    nth1(LineA, Context, A),
    nth1(LineImp, Context, imp(A, B)).

% Negation Introduction (¬i): Introduce a negation from a contradiction
valid_rule(neg(A), negint(LineA, LineCont), _, Context) :-
    nth1(LineA, Context, A),
    nth1(LineCont, Context, cont).

% Negation Elimination (¬e): Derive a contradiction from a formula and its negation
valid_rule(cont, negel(LineA, LineNegA), _, Context) :-
    nth1(LineA, Context, A),
    nth1(LineNegA, Context, neg(A)).

% Double Negation Introduction (¬¬i): Introduce a double negation
valid_rule(neg(neg(A)), negnegint(Line), _, Context) :-
    nth1(Line, Context, A).

% Double Negation Elimination (¬¬e): Eliminate a double negation
valid_rule(A, negnegel(Line), _, Context) :-
    nth1(Line, Context, neg(neg(A))).

% Contradiction Elimination (⊥e): Derive any formula from a contradiction
valid_rule(_, contel(Line), _, Context) :-
    nth1(Line, Context, cont).

% Law of Excluded Middle (LEM): Introduce a disjunction of a formula and its negation
valid_rule(or(A, neg(A)), lem, _, _).

% Modus Tollens (MT): Derive a negation from an implication and the negation of the conclusion
valid_rule(neg(A), mt(LineImp, LineNegB), _, Context) :-
    nth1(LineImp, Context, imp(A, B)),
    nth1(LineNegB, Context, neg(B)).

% Proof by Contradiction (PBC): Derive a formula from the negation leading to a contradiction
valid_rule(A, pbc(LineNegA, LineCont), _, Context) :-
    nth1(LineNegA, Context, neg(A)),
    nth1(LineCont, Context, cont).

% Copy Rule: Copy a formula from a previous line
valid_rule(A, copy(Line), _, Context) :-
    nth1(Line, Context, A).