/*---------------------------------------------------------------*/
/* Telecom Paristech - J-L. Dessalles 2009                       */
/*            http://teaching.dessalles.fr                       */
/*---------------------------------------------------------------*/


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% symbolic concept learning %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


:- select(_,_,_).   % to circumvent a bug in my version of SWI-Prolg
:- unknown(_,fail).
:- dynamic(vPosition/2).

%----------------------%
% Geometrical ontology %
%----------------------%
/*
                form
            /           \
     polygon            ellipsoid
  /  /	 |    \         /       \
sq. tr. pent. hex.    ellipse  circle

*/
parent(form, polygon).
parent(form, ellipsoid).
parent(polygon, square).
parent(polygon, triangle).
parent(polygon, pentagon).
parent(polygon, hexagon).
parent(ellipsoid, ellipse).
parent(ellipsoid, circle).


%------------------------------------------------------------%
% Least general generalization between two geometrical shapes
%------------------------------------------------------------%

lgg(Shape, Shape, Shape, 0).
lgg(Shape1, Shape2, Shape3, I+1) :-
    parent(Shape11, Shape1),
    parent(Shape12, Shape2),
    lgg(Shape11, Shape12, Shape3, I).


/* Add +1 to the cost for each step climbed up 
   in the conceptual hierarchy                    
*/


/*--------------------------------------------------*/
/* Unification between two feature structures       */
/* Calls 'lgg' to unify features that are not equal */
/*--------------------------------------------------*/
match([],[],[],0).
match([Feature1|FS1], FS2, [F|FS], Cost) :-
    % Looks for compatible features between the two feature structures
    select(Feature2, FS2, FS2a),
    compatible(Feature1, Feature2, F, Cost1),
    match(FS1, FS2a, FS, Cost2),
    Cost is Cost1 + Cost2.

compatible(F1, F2, F, Cost) :-
    F1 =.. [Shape1|A],
    F2 =.. [Shape2|A],
    lgg(Shape1, Shape2, Shape, Cost),
    F =.. [Shape|A].
    
%------------------------------------------------------------------%
% interface with "perception":                                     %
% executing objects means that they are given a definite reference %
%------------------------------------------------------------------%
execute([]).
execute([P|Ps]) :-
    P,
    execute(Ps).
execute([P|Ps]) :-
    P =.. [Pr|Var], % P has failed
    parent(PPr,Pr), % climb up the hierarchy to make another attempt
    PP =.. [PPr|Var],
    execute([PP|Ps]).

% object instantiation
form(object_1).	% object is instanciated regardless of its specific properties
form(object_2).	% object is instanciated regardless of its specific properties

% Vertical position
vPos(Object,P) :-
    not(vPosition(Object,_)),
    assert(vPosition(Object,P)).	% objects are given positions only once
vPos(Object,P) :-
    retract(vPosition(Object,P)),    % cleans memory when backtracking
    fail.

%-------%
% Tests %
%-------%
generalize(E1, E2) :-
    write(E1),nl,
    write(E2),nl,
    match(E1, E2, E, Cost),
    execute(E),
    write(E), write(' --- '), write(Cost), nl.

matchTest :-
    E1 = [square(A), circle(B), vPos(A,2), vPos(B,1)],  
    E2 = [triangle(C), square(D), vPos(C,2), vPos(D,1)],
    generalize(E1,E2).
