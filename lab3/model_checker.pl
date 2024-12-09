% check(T, L, S, Previous, F)
% Transitions - The transitions in form of adjacency lists
% Labels - The labeling
% State - Current state
% Previous - Currently recorded states
% Formula - CTL Formula to check.
%
% Should evaluate to true if the sequent below is valid.
% (Transitions,Labels), State |- Formula 
%                             U
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
    read(Transitions),
    read(Labels),
    read(State),
    read(Formula),
    seen,
    check(Transitions, Labels, State, [], Formula).


% Literals/atoms (numbers and strings with first character in lower case)
check(_, Labels, State, [], Literal) :- 
    state_variables(Labels, State, Variables),
    member(Literal, Variables).

check(_, Labels, State, [], neg(Literal)) :-
    state_variables(Labels, State, Variables),
    \+ member(Literal, Variables).


% And
check(Transitions, Labels, State, [], and(Statement1, Statement2)) :-
    check(Transitions, Labels, State, [], Statement1),
    check(Transitions, Labels, State, [], Statement2).


% Or
check(Transitions, Labels, State, [], or(Statement1, Statement2)) :-
    check(Transitions, Labels, State, [], Statement1);
    check(Transitions, Labels, State, [], Statement2).


% AX q - q is true in the next state
check(Transitions, Labels, State, [], ax(Statement)) :-
    state_variables(Transitions, State, Adjacent_states),
    verify_all_adjacent(Transitions, Labels, Adjacent_states, [], Statement).

% EX q - q is true in some next state
check(Transitions, Labels, State, [], ex(Statement)) :-
    state_variables(Transitions, State, Adjacent_states),
    verify_atleast_one_adjacent(Transitions, Labels, Adjacent_states, [], Statement).
    

% AG q - q is true in every state in every path
check(_, _, State, Previous, ag(_)) :-
    member(State, Previous).

check(Transitions, Labels, State, Previous, ag(Statement)) :-
    \+ member(State, Previous),
    check(Transitions, Labels, State, [], Statement),
    state_variables(Transitions, State, Adjacent_states),
    verify_all_adjacent(Transitions, Labels, Adjacent_states, [State|Previous], ag(Statement)).

% EG q - q is true in every state in some path
check(_, _, State, Previous, eg(_)) :-
    member(State, Previous).

check(Transitions, Labels, State, Previous, eg(Statement)) :-
    \+ member(State, Previous),
    check(Transitions, Labels, State, [], Statement),
    state_variables(Transitions, State, Adjacent_states),
    verify_atleast_one_adjacent(Transitions, Labels, Adjacent_states, [State|Previous], eg(Statement)).


% AF q - every path will have q true eventually
check(Transitions, Labels, State, Previous, af(Statement)) :-
    \+ member(State, Previous),
    check(Transitions, Labels, State, [], Statement).

check(Transitions, Labels, State, Previous, af(Statement)) :-
    \+ member(State, Previous),
    state_variables(Transitions, State, Adjacent_states),
    verify_all_adjacent(Transitions, Labels, Adjacent_states,[State|Previous], af(Statement)).

% EF q - there exists a path where q will eventually be true
check(Transitions, Labels, State, Previous, ef(Statement)) :-
    \+ member(State, Previous),
    check(Transitions, Labels, State, [], Statement).

check(Transitions, Labels, State, Previous, ef(Statement)) :-
    \+ member(State, Previous),
    state_variables(Transitions, State, Adjacent_states),
    verify_atleast_one_adjacent(Transitions, Labels, Adjacent_states, [State|Previous], ef(Statement)).


% ------------Utility methods------------
    
% Retrieves the variables that are true for a certain state
state_variables([[State, Variables]|_], State, Variables). % Variables gets unified

state_variables([_|T], State, Variables) :-
    state_variables(T, State, Variables).

% Base case, if all adjacent states have been verified or the state doesn't have any transitions (to other states)
verify_all_adjacent(_, _, [], _, _).

verify_all_adjacent(Transitions, Labels, [Adjacent|Adjacent_states], Previous, Formula) :-
    check(Transitions, Labels, Adjacent, Previous, Formula), % Check if the adjacent state is true
    verify_all_adjacent(Transitions, Labels, Adjacent_states, Previous, Formula). % Check if the rest of the adjacent states are true

% Base case, if the state don't have any transitions (to other states)
verify_atleast_one_adjacent(_, _, [], _, _).

verify_atleast_one_adjacent(Transitions, Labels, Adjacent_states, Previous, Formula) :-
    member(Adjacent, Adjacent_states), % Get every adjacent state
    check(Transitions, Labels, Adjacent, Previous, Formula). % Check every adjacent state til one is true or all are false