% Prolog Programming Project 3, Team members:
% 1. Tenepalli Reddy Dheeraj  (SBID: 112669821)
% 2. Venuthurla Venkata Ravi Theja Reddy  (SBID: 112689223)


% ---------------Helper functions for lists and generating samples ----------------
% Member function from slides ( member/2 finds if a given element occurs in a list )
member(H,[H|_]).
member(X,[_|T]) :-
	member(X,T).

% generates all permutations of given list. If n elements in list generates 2^n elements applying include/not-include approach % for each element in the list.
get_subset([],[]).
get_subset([H|T],[H|T_R]) :-
	get_subset(T,T_R).
get_subset([_|T],T_R) :-
	get_subset(T,T_R).

% Returns the minimum element in the given list
min_list([H],H) :-
	!.
min_list([H|T],M) :-
	min_list(T,M2),
	(H<M2 -> M=H;M=M2).

% Finds the length of list given to it.
length([],0).
length([_|T],N) :-
	length(T,N1),
	N is N1 + 1.
	
	
		
% ------------ This are the functions which performs atomic tasks for the main function -----------------

% Generates a list of tuples (Activity, Units) 	and returns list. Utilizing findall method of Aggregates
get_needs(Myneeds) :-
	findall((A,U), need(A,U),Myneeds).

% Parses the offers given and generate a list of tuples (Activites, Units) by mapping (O,P) operator package tuple. We have used findall operator of Aggregates in XSB.
get_packages([],[]).
get_packages([(O,P) | LOP],[(O,P,LAU) | LOPAU]) :-
	findall((A,U),offer(O,P,A,U),LAU),
	get_packages(LOP,LOPAU).	
	
	
% Parses the offers given and generate a list of tuples (Operator, Packages) with no duplicates. We have used setof operator   % from the aggregates in XSB.
get_all_offers(LOP_AU) :-
	setof((O,P), X^Y^offer(O,P,X,Y),LOP),
	get_packages(LOP,LOP_AU).

	
% Checks for maximum accepted operators constraint and if satisfies the subset generated stays in Sub else it gets removed.
op_check([],_).
op_check([O|T],Sub) :-
	findall(P,member((O,P,_LA),Sub),L),
	maxacceptedoffer(M),
	length(L,N),
	N =< M ,
	op_check(T,Sub).	

	
% Checks for maximum accepted operators constraint and if satisfies the subset generated stays in Sub else it gets removed.
max_per_op(Sub) :-
	setof(O,P^LA^member((O,P,LA),Sub),LO),
	op_check(LO,Sub).	

	
% Checks whether the subset satisfies the needs given. If yes retains that possibility into the list provided inplace.	
satisfactory_need(_,U,_) :-
	U =< 0,
	!.
satisfactory_need(A,U,[(_O,_P,LA) | T]) :-
	member((A,U2),LA)
		-> NU is U - U2, satisfactory_need(A,NU,T)
		; satisfactory_need(A,U,T).
	
	
% Checks whether the subset satisfies the needs given. If yes retains that possibility into the list provided inplace.
iter_needs([],_).
iter_needs([(A,U) | T],Sub) :-
	satisfactory_need(A,U,Sub),
	iter_needs(T,Sub).

	
% Calculates price from the given input considering all the (Operator, Package) tuples and sums the prices for all the tuples % in a particular solution.
cal_price([],0).
cal_price([(O,P,_)|Sub],TPrice) :-
	price(O,P,Price1),
	cal_price(Sub,Price2),
	TPrice is Price1 + Price2.
	
	
% All the sub functions for this all provided above. At the end this produces a list of all possible solutions - Price        % satisfying needs and satisfying the constraint of max accepted offers given. Later on this price list min is applied to     % obtain the minimum cost solution.
is_subset(Sub,TPrice) :-
	get_needs(Myneeds),
	get_all_offers(LOP_AU),
	get_subset(LOP_AU,Sub),
	max_per_op(Sub),
	iter_needs(Myneeds,Sub),
	cal_price(Sub,TPrice).

% ++  Usage call: totalcost('S:/input.txt', M).   Path of the input should given as the first argument, Please check the permissions to the file inputting.
	
% ------------- MAIN  -------------	
% Main Function to call for fetching total minimum cost. Firstly generating all possibilities which satisfies needs and       % maxacceptedoffer constraint given, find the price for all possibilities, then Get Minimum priced possibility.
totalcost(InputFile, M) :-
	consult(InputFile),
	findall(TPrice,is_subset(_Sub,TPrice),LPrices),
	min_list(LPrices,M).

	
