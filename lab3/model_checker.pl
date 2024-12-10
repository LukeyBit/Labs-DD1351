% check(T, L, S, Previous, F)
% T - The transitions in form of adjacency lists
% L - The labeling
% S - Current state
% Previous - Currently recorded states
% F - CTL formula to check.
%
% Should evaluate to true if the sequent below is valid.
% (T,L), S |- F 
%          U
%
% To execute a single file: 
% consult('your_file.pl'). 
% verify('INPUT_FILE_NAME.txt').
%
% To run all tests:
% ['run_all_tests.pl'].
% run_all_tests('verify.pl').

% Read and verify input
verify(Input) :-
    see(Input),
    read(T),
    read(L),
    read(S),
    read(F),
    seen,
    check(T, L, S, [], F). % Start with an empty list of previous states


% AX (All Next): Sant i alla direkta efterföljande tillstånd.
% AF (All Finally): Kommer att vara sant någon gång i framtiden på alla vägar.
% AG (All Globally): Alltid sant på alla vägar.

% EX (Exists Next): Sant i minst ett direkt efterföljande tillstånd.
% EF (Exists Finally): Kommer att vara sant någon gång i framtiden på minst en väg.
% EG (Exists Globally): Alltid sant på minst en väg.

% Literals/atoms are true if they are in the labeling of the current state
check(_, L, S, [], Literal) :- 
    state_variables(L, S, Variables),
    member(Literal, Variables).

check(_, L, S, [], neg(Literal)) :-
    state_variables(L, S, Variables),
    \+ member(Literal, Variables).


% And - Both statements must be true
check(T, L, S, [], and(Statement1, Statement2)) :-
    check(T, L, S, [], Statement1),
    check(T, L, S, [], Statement2).


% Or
check(T, L, S, [], or(Statement1, Statement2)) :-
    check(T, L, S, [], Statement1);
    check(T, L, S, [], Statement2).


% AX - Check if statement is true in all adjacent states
check(T, L, S, [], ax(Statement)) :-
    state_variables(T, S, Adjacent_states),
    verify_all_adjacent(T, L, Adjacent_states, [], Statement).

% EX - Check if statement is true in at least one adjacent state
check(T, L, S, [], ex(Statement)) :-
    state_variables(T, S, Adjacent_states),
    verify_atleast_one_adjacent(T, L, Adjacent_states, [], Statement).
    

% AG - Check if statement is true in all states in the path
check(_, _, S, Previous, ag(_)) :-
    member(S, Previous).

check(T, L, S, Previous, ag(Statement)) :-
    \+ member(S, Previous),
    check(T, L, S, [], Statement),
    state_variables(T, S, Adjacent_states),
    verify_all_adjacent(T, L, Adjacent_states, [S|Previous], ag(Statement)).

% EG - Check if statement is always true in at least one state in the path
check(_, _, S, Previous, eg(_)) :-
    member(S, Previous).

check(T, L, S, Previous, eg(Statement)) :-
    \+ member(S, Previous),
    check(T, L, S, [], Statement),
    state_variables(T, S, Adjacent_states),
    verify_atleast_one_adjacent(T, L, Adjacent_states, [S|Previous], eg(Statement)).


% AF - Check if statement will eventually be true in all states in the path
check(T, L, S, Previous, af(Statement)) :-
    \+ member(S, Previous),
    check(T, L, S, [], Statement).

check(T, L, S, Previous, af(Statement)) :-
    \+ member(S, Previous),
    state_variables(T, S, Adjacent_states),
    verify_all_adjacent(T, L, Adjacent_states,[S|Previous], af(Statement)).

% EF - Check if statement will eventually be true in at least one state in the path
check(T, L, S, Previous, ef(Statement)) :-
    \+ member(S, Previous),
    check(T, L, S, [], Statement).

check(T, L, S, Previous, ef(Statement)) :-
    \+ member(S, Previous),
    state_variables(T, S, Adjacent_states),
    verify_atleast_one_adjacent(T, L, Adjacent_states, [S|Previous], ef(Statement)).

    
% Get the variables of the current state
state_variables([[S, Variables]|_], S, Variables).

state_variables([_|T], S, Variables) :-
    state_variables(T, S, Variables).

% Base case if the state don't have any transitions (to other states)
verify_all_adjacent(_, _, [], _, _).

verify_all_adjacent(T, L, [Adjacent|Adjacent_states], Previous, F) :-
    check(T, L, Adjacent, Previous, F), % Verify the adjacent state
    verify_all_adjacent(T, L, Adjacent_states, Previous, F). % Verify the rest of the adjacent states

% Base case if the state don't have any transitions (to other states)
verify_atleast_one_adjacent(_, _, [], _, _).

verify_atleast_one_adjacent(T, L, Adjacent_states, Previous, F) :-
    member(Adjacent, Adjacent_states), % Check if there are any adjacent states
    check(T, L, Adjacent, Previous, F). % Verify the adjacent state

