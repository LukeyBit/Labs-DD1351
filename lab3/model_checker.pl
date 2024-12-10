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
%


% Read and verify input
verify(Input) :-
    see(Input),
    read(T),
    read(L),
    read(S),
    read(F),
    seen,
    check(T, L, S, [], F).


% AX (All Next): Sant i alla direkta efterföljande tillstånd.
% EX (Exists Next): Sant i minst ett direkt efterföljande tillstånd.    
% AF (All Finally): Kommer att vara sant någon gång i framtiden på alla vägar.    
% EF (Exists Finally): Kommer att vara sant någon gång i framtiden på minst en väg.    
% AG (All Globally): Alltid sant på alla vägar.    
% EG (Exists Globally): Alltid sant på minst en väg.

% Literals/atoms are true if they are in the labeling of the current state
check(_, L, S, [], Literal) :- 
    state_variables(L, S, Variables),
    member(Literal, Variables).

check(_, L, S, [], neg(Literal)) :-
    state_variables(L, S, Variables),
    \+ member(Literal, Variables).


% And
check(T, L, S, [], and(Statement1, Statement2)) :-
    check(T, L, S, [], Statement1),
    check(T, L, S, [], Statement2).


% Or
check(T, L, S, [], or(Statement1, Statement2)) :-
    check(T, L, S, [], Statement1);
    check(T, L, S, [], Statement2).


% AX q - q is true in the next state
check(T, L, S, [], ax(Statement)) :-
    state_variables(T, S, Adjacent_states),
    verify_all_adjacent(T, L, Adjacent_states, [], Statement).

% EX q - q is true in some next state
check(T, L, S, [], ex(Statement)) :-
    state_variables(T, S, Adjacent_states),
    verify_atleast_one_adjacent(T, L, Adjacent_states, [], Statement).
    

% AG q - q is true in every state in every path
check(_, _, S, Previous, ag(_)) :-
    member(S, Previous).

check(T, L, S, Previous, ag(Statement)) :-
    \+ member(S, Previous),
    check(T, L, S, [], Statement),
    state_variables(T, S, Adjacent_states),
    verify_all_adjacent(T, L, Adjacent_states, [S|Previous], ag(Statement)).

% EG q - q is true in every state in some path
check(_, _, S, Previous, eg(_)) :-
    member(S, Previous).

check(T, L, S, Previous, eg(Statement)) :-
    \+ member(S, Previous),
    check(T, L, S, [], Statement),
    state_variables(T, S, Adjacent_states),
    verify_atleast_one_adjacent(T, L, Adjacent_states, [S|Previous], eg(Statement)).


% AF q - every path will have q true eventually
check(T, L, S, Previous, af(Statement)) :-
    \+ member(S, Previous),
    check(T, L, S, [], Statement).

check(T, L, S, Previous, af(Statement)) :-
    \+ member(S, Previous),
    state_variables(T, S, Adjacent_states),
    verify_all_adjacent(T, L, Adjacent_states,[S|Previous], af(Statement)).

% EF q - there exists a path where q will eventually be true
check(T, L, S, Previous, ef(Statement)) :-
    \+ member(S, Previous),
    check(T, L, S, [], Statement).

check(T, L, S, Previous, ef(Statement)) :-
    \+ member(S, Previous),
    state_variables(T, S, Adjacent_states),
    verify_atleast_one_adjacent(T, L, Adjacent_states, [S|Previous], ef(Statement)).


% ------------Utility methods------------
    
% Retrieves the variables that are true for a certain state
state_variables([[S, Variables]|_], S, Variables). % Variables gets unified

state_variables([_|T], S, Variables) :-
    state_variables(T, S, Variables).

% Base case, if all adjacent states have been verified or the state doesn't have any transitions (to other states)
verify_all_adjacent(_, _, [], _, _).

verify_all_adjacent(T, L, [Adjacent|Adjacent_states], Previous, F) :-
    check(T, L, Adjacent, Previous, F), % Check if the adjacent state is true
    verify_all_adjacent(T, L, Adjacent_states, Previous, F). % Check if the rest of the adjacent states are true

% Base case, if the state don't have any transitions (to other states)
verify_atleast_one_adjacent(_, _, [], _, _).

verify_atleast_one_adjacent(T, L, Adjacent_states, Previous, F) :-
    member(Adjacent, Adjacent_states), % Get every adjacent state
    check(T, L, Adjacent, Previous, F). % Check every adjacent state til one is true or all are false

