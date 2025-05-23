:- use_module(library(pce)).
:- use_module(library(clpfd)).

% --- 8 Queens Solver ---
solve_queens(Solution) :-
    length(Solution, 8),
    Solution ins 1..8,
    all_different(Solution),
    safe_diagonals(Solution),
    label(Solution).

safe_diagonals([]).
safe_diagonals([Q|Qs]) :-
    safe_diagonals(Qs, Q, 1),
    safe_diagonals(Qs).

safe_diagonals([], _, _).
safe_diagonals([Q|Qs], Q0, D) :-
    abs(Q0 - Q) #\= D,
    D1 #= D + 1,
    safe_diagonals(Qs, Q0, D1).

% --- GUI Setup ---
start_queens_gui :-
    findall(Sol, solve_queens(Sol), Solutions),
    length(Solutions, Total),
    format('Found ~d solutions~n', [Total]),

    % Create dialog and board
    new(Dialog, dialog('8 Queens Visualizer')),
    new(Board, picture('Chessboard')),
    send(Board, size, size(400, 400)),
    send(Dialog, append, Board),

    % Create index counter
    new(Index, number(0)),

    % Create status display - changed to text_item
    new(Status, text_item(status, 'Solution 1/92')),
    send(Dialog, append, Status),

    % Store solutions in a global reference
    nb_setval(queens_solutions, Solutions),

    % Create buttons with simple messages
    send(Dialog, append,
         button(next, message(@prolog, next_solution, Board, Index, Status))),

    send(Dialog, append,
         button(prev, message(@prolog, prev_solution, Board, Index, Status))),

    send(Dialog, append, button(close, message(Dialog, destroy))),

    send(Dialog, open),
    show_solution(Board, Index, Status).

% --- Navigation predicates ---
next_solution(Board, Index, Status) :-
    nb_getval(queens_solutions, Solutions),
    get(Index, value, I),
    NextI is (I + 1) mod 92,
    send(Index, value, NextI),
    show_solution(Board, Index, Status).

prev_solution(Board, Index, Status) :-
    nb_getval(queens_solutions, Solutions),
    get(Index, value, I),
    PrevI is (I - 1) mod 92,
    send(Index, value, PrevI),
    show_solution(Board, Index, Status).

% --- Show current solution ---
show_solution(Board, Index, Status) :-
    nb_getval(queens_solutions, Solutions),
    get(Index, value, I),
    nth0(I, Solutions, Sol),
    draw_board(Board, Sol),
    SolutionNum is I + 1,
    % Fixed status update - using format_to_atom
    format(atom(StatusText), 'Solution ~d/92', [SolutionNum]),
    send(Status, selection, StatusText).

% --- Drawing logic ---
draw_board(Board, Queens) :-
    send(Board, clear),
    Size = 50,
    % Draw chessboard
    forall(between(1, 8, Row),
        forall(between(1, 8, Col),
            (
                X is (Col - 1) * Size,
                Y is (Row - 1) * Size,
                ( (Row + Col) mod 2 =:= 0 ->
                    Color = white ; Color = lightgrey ),
                new(Box, box(Size, Size)),
                send(Box, fill_pattern, colour(Color)),
                send(Board, display, Box, point(X, Y))
            )
        )
    ),
    % Draw queens
    forall(nth1(Row, Queens, Col),
        (
            X is (Col - 1) * Size + 5,
            Y is (Row - 1) * Size + 5,
            new(Circle, circle(40)),
            send(Circle, fill_pattern, colour(red)),
            send(Board, display, Circle, point(X, Y))
        )
    ).
