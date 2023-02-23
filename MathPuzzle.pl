% ------------------------------------------------------------------------
%     AUTHOR
% Tuan Phong Vu - 1266265
%
%     DESCRIPTION
% Prolog file to solve any size of "Math Puzzle".
% Step by step explaination could be found below.
% 
% ------------------------------------------------------------------------
% puzzle_solution(Puzzle) will be the main function
%     - Hold when presented with a solved "Math Puzzle" Puzzle 
% This is done via:
%     - We tranposing Puzzle giving us the "vertical" puzzle VPuzzle, this will
%       be later be simultaneously checking alonside with Puzzle in order to 
%       make sure the symetrical math puzzle are correct both way
%     - Double check to make sure all element are digits, 0 are not permitted
%     - Ensure each row and Column contains no repeated digits
%     - All squares on diagonal line from uppoer left to lower right contains
%       the same value
%     - The heading of reach row and column holds either the sum or the product
%       of all the digits in that rows
%     - Check if the whole puzzle is filled using ground(Term).
%      
% ------------------------------------------------------------------------
:- ensure_loaded(library(clpfd)).

% ------------------------------------------------------------------------
% check_repetition/1 takes in a math puzzle Puzzle and checking through
% each row to see whether if there are repetitions in a row. Hold true when
% no 2 same integers are found in a single row.

check_repetition(Puzzle) :-
    Puzzle = [_|Row],
    maplist(all_distinct,Row).

% ----------------------------------------------------------------------------
% remove_head/2 used to return just a tail of a list, in our Math Puzzle case, 
% it will return a row of the puzzle without the heading.
% 
% without_heading/2 take in a Puzzle, apply remove_head/2 to each of the row  
% (except column heading). I.e This function will hold when Squares represent
% a version of Puzzle but without both column and row heading.
%
% same_diagonal/2 hold true when Diagonal is the first value of the first list
% in a give list of lists. In our case is the upper left corner value.
% The recursive call here checking apply same_diagonal to the "shrink" version
% of the original input puzzle to check the upper left corner value
% e.g given a 4x4 Puzzle, we store the first detected UpperLeft, we shrink the 
% puzzle down to a 3x3, now the next diagonal value that we need to check 
% with our original UpperLeft will also be positioned at the upper left corner
% of this new 3x3 matrix, and so on until our base case is reached.
%
% check_diagonal/1 hold true when all the squares on the diagonal line from 
% upper left to lower right cotain same value.  

remove_head([_|Tail], Tail).
without_heading([_|Rows],Squares):-
    maplist(remove_head, Rows, Squares).

same_diagonal([],_).
same_diagonal([[UpperLeft|_]|Rows], Diagonal) :-
    Diagonal = UpperLeft,  
    without_heading([UpperLeft|Rows], ReducedMatrix),    
    same_diagonal(ReducedMatrix, Diagonal).

check_diagonal(Puzzle) :-
    without_heading(Puzzle,NPuzzle),
    same_diagonal(NPuzzle,_).

% --------------------------------------------------------------------------
% product/3 taking in a list, and product accumulate A over time with each
% element of that list and our base case is when our accumulate a has the same
% value as Product.
%
% sum/3 taking in a list, and summing accumulate A over time with each
% element of that list and our base case is when our accumulate a has the same
% value as Sum.
%
% check/1 taking in a list and hold true when apply sum/3 and product/3. with 
% the checking value be the Head and the list to be check be the Tail of the 
% input list
%
% checking_heading/1 taking in list of list(puzzle) and apply check/1 to each
% of the rows except the heading row./
product([], Product, Product).
product([Head|Tail], A, Product) :-
    Acc #= A * Head,
    product(Tail, Acc, Product).

sum([],Sum,Sum).
sum([Head|Tail], A, Sum) :-
    Acc #= A + Head,
    sum(Tail,Acc,Sum).


check([Head|Row]):- 
    sum(Row,0,Head);
    product(Row,1,Head).
    
check_heading(Puzzle) :-
    Puzzle = [_|Row],
    maplist(check,Row).
% -------------------------------------------------------------------------
% ground_vars/1 takes in a Puzzle and holds true when all of the squares values
% in the the puzzle are grounded (filled) .
check_ground([_|Rows]) :- maplist(ground, Rows).

% -------------------------------------------------------------------------
% Since the squares value are not bounded to integers unlike its heading we need
% to check whether they are in a range of single digit, while for all heading
% we only need to check whether they hold valid integer value (not 0).
%
% check_digits/1 take in a math puzzle, and holds when all the heading rows and
% columns are digits. And all the squares values are interged with value between
% 1 and 9. Since the lowest value any squares can take is 1, its heading just 
% need to be checked whether it is larger or equal to 1.
%
% check_row/1 take in a list, i.e a row of our puzzle, and hold when all its
% value are in the range 1 to 9, except its first value (heading).

check_digits(Puzzle) :-
    Puzzle = [[_|FRow]|Row],
    transpose(Puzzle,VPuzzle),
    VPuzzle = [[_|FCol]|_],
    maplist(#=<(1),FRow),
    maplist(#=<(1),FCol),
    maplist(check_row,Row).


check_row([_|Row]) :-
    Row ins 1..9.
% ----------------------------------------------------------------------------
% puzzle_solution/1 is our main solving function and its hold true when a 
% Puzzle are a solved Maths Puzzle! 
%    - It tranpose the Puzzle to give us the "vertical" version VPuzzle
%    - We check whether all the elements in the Puzzle are valids integers
%    - We check for diagonal condition, detail description in check_digaonal/1
%    - We check for repetition detail description in check_repetition
%      in the squares value for both direction
%    - We check for correct heading value, detail description in check_heading/1
%    - We grounded the terms that has satisfied all the listed conditions.

puzzle_solution(Puzzle) :-
    transpose(Puzzle, VPuzzle),
    check_digits(Puzzle),
    
    check_diagonal(Puzzle),
    
    check_repetition(Puzzle),
    check_repetition(VPuzzle),
    
    check_heading(Puzzle), 
    check_heading(VPuzzle),
    
    check_ground(Puzzle).



    