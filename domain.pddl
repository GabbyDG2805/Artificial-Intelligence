;;Domain for cleaning floor tiles
;; A domain file for CMP2020M assignment 2018/2019
;;  By Gabriella Di Gregorio, 15624188


;; Define the name for this domain (needs to match the domain definition in the problem files)
(define (domain floor-tile)

	;; We only require some typing to make this plan faster. We can do without!
	(:requirements :typing)

	;; We have two types: robots and the tiles, both are objects
	(:types robot tile - object)

	;; define all the predicates as they are used in the probem files
	(:predicates  

    ;; described what tile a robot is at
    (robot-at ?r - robot ?x - tile)

    ;; indicates that tile ?x is above tile ?y
    (up ?x - tile ?y - tile)

    ;; indicates that tile ?x is below tile ?y
    (down ?x - tile ?y - tile)

    ;; indicates that tile ?x is right of tile ?y
    (right ?x - tile ?y - tile)

    ;; indicates that tile ?x is left of tile ?y
    (left ?x - tile ?y - tile)
    
    ;; indicates that a tile is clear (robot can move there)
    (clear ?x - tile)

    ;; indicates that a tile is cleaned
    (cleaned ?x - tile)
 	)

;; Before defining the actions, I made a sketch of both problems which helped me understand:
;; How the floor tiles are laid out
;; Where the robots are
;; What steps need to be taken
;; Which tiles needed to be cleaned

;; ACTIONS:

;;Actions are described as a set of action schemas that implicitly define the action and result functions needed to do a problem-solving search.
;;Any system for action description needs to solve the frame problem - to say what changes and what stays the same as a result of the action (Russell and Norvig, 2014).

;; The first action that needs to be defined is clean-up.
;; This is referring to the brush on the front of the robot that can clean the tile above it.
(:action clean-up
	:parameters (?r ?x ?y)                  ;;The parameters refer to what needs to be known first. These are the robot, the tile it is at, and the next tile it can clean.
    :precondition (and (robot-at ?r ?x)     ;;The preconditions are what needs to happen or be checked before the effect can take place. The first precondition is that the robot is at tile x which is the tile it is currently on.
					(not(robot-at ?r ?y))   ;;The next precondition is that the robot is not at the tile it can clean.
					(clear ?y)              ;;Another precondition is that the tile it can clean is clear of other robots.
                    (not(cleaned ?y))       ;;We also need to check that the tile that it can clean has not already been clean. This must be a precondition so that it does not clean the same tile more than once which would be inefficient.
                    (down ?x ?y)            ;;The final precondition is that the tile the robot is currently on (x) is below/down of the tile it can clean (y) in order to clean upwards.
					)                       ;;The precondition and the effect of an action are each conjunctions of literals. The precondition defines the states in which the action can be executed, and the effect defines the result of an executing action (Russell and Norvig, 2014).
	:effect(and (cleaned ?y))               ;;The effects are the results of the action (what happens when it completes?). So, the effect of this action is that the tile above (y) is now clean.   
)

;;The parameters, preconditions, and effects for the clean-down action are almost identical to the clean-up action so there is no need to explain them all again.
;;This action is referring to the brush at the back of the robot that can clean the tile behind it.
(:action clean-down
	:parameters (?r ?x ?y)
    :precondition (and (robot-at ?r ?x)
                       (not(robot-at ?r ?y))
                       (clear ?y)
                       (not(cleaned ?y))
					   (up ?x ?y)           ;;However, this time the precondition is that the tile the robot is on (x) is up/above the tile it can clean (y) in order to clean downwards instead.
					)
	:effect(and (cleaned ?y)) 
)

;; The next four actions that need to be defined are all about movement. These define the directions the robot can move in.
;; The first movement action is 'up' which means that the robot will move forwards to the tile in front of its current location.
(:action up 
	:parameters (?r ?x ?y)                      ;;The parameters for the movement actions are the same as the clean actions. This is because it is necessary to know about the robot, the tile it is currently on, and the next tile it can move to.
	:precondition (and (robot-at ?r ?x)         ;;The robot must be at tile x which is the tile it is currently on.
                       (down ?x ?y)             ;;The tile it is on must be down of/below the tile it can move to in order to move upwards. This is the only precondition that changes for the movement actions.
                       (not(robot-at ?r ?y))    ;;The robot must also not be at the next tile it will move to.
                       (clear ?y)               ;;The tile it can move to must also not have any robots on it in order to avoid collisions.
                       (not(cleaned ?y))        ;;The tile that it can move to must also not have been cleaned already since it cannot go on wet surfaces.
					)
	:effect (and (robot-at ?r ?y)               ;;The effects of these actions are more complex than the clean actions since more will happen. Firstly, the robot will now be at the tile it was able to move to (y).
				(not(clear ?y))                 ;;Also, the tile it has move to will no longer be clear because there is a robot on it now.
				(not (robot-at ?r ?x))          ;;But, the robot is now no longer at the tile it moved from/ was on before (x)
				(clear ?x)                      ;;so, this tile is now clear of robots because it has moved.
			)
)

;; The following actions all have parameters, preconditions, and effects almost identical to the 'up' action so these don't need to be explained again since I'd just be repeating myself.
(:action down 
	:parameters (?r ?x ?y)
	:precondition (and (robot-at ?r ?x)
                       (up ?x ?y)               ;;However, for the robot to be able to move downwards, it must be checked that the tile it is currently on is up of/ above the tile it can move to.
                       (not(robot-at ?r ?y))
                       (clear ?y)
                       (not(cleaned ?y))
					)
	:effect (and (robot-at ?r ?y)
				(not(clear ?y))
				(not (robot-at ?r ?x))
				(clear ?x)
			)
)

(:action right 
	:parameters (?r ?x ?y)
	:precondition (and (robot-at ?r ?x)
                       (left ?x ?y)             ;;In order for it to move right, the tile the robot is at (x) must be left of the tile it can move to (y).
                       (not(robot-at ?r ?y))
                       (clear ?y)
                       (not(cleaned ?y))
					)
	:effect (and (robot-at ?r ?y)
				(not(clear ?y))
				(not (robot-at ?r ?x))
				(clear ?x)
			)
)

(:action left 
	:parameters (?r ?x ?y)
	:precondition (and (robot-at ?r ?x)
                       (right ?x ?y)            ;;Finally, if the robot can move left then the tile it is at (x) must be right of the tile it can move to (y).
                       (not(robot-at ?r ?y))
                       (clear ?y)
                       (not(cleaned ?y))
					)
	:effect (and (robot-at ?r ?y)
				(not(clear ?y))
				(not (robot-at ?r ?x))
				(clear ?x)
			)
)

;; All of these action definitions provide enough information to successfully generate a correct and efficient plan of how the robot should move and which order it should clean the tiles.
)

;; Here's how it solves floor-problem-01:
;;1. Cleans tile 0-1 from the tile it starts on, 1-1
;;2. Moves up to tile 2-1
;;3. Cleans tile 1-1 while it is on 2-2
;;4. Moves right to tile 2-2
;;5. Moves down to tile 1-2 because it cannot clean anything from 2-2
;;6. Cleans 0-2 whilst on 1-2
;;7. Cleans 2-2 whilst still on 0-2 - All the dirty tiles have now been cleaned, it did not waste time cleaning clean tiles or cleaning tiles more than once, and it did not move onto tiles that had been cleaned...DONE!

;; Here's how it solves floor-problem-02:
;;1. Robot1 cleans 4-1 whilst it is on 3-1
;;2. Robot1 moves right to tile 3-2
;;3. Robot1 cleans 4-2 whilst on 3-2
;;4. Robot1 moves right to 3-3
;;5. Robot2 cleans 3-2 whilst on 2-2
;;6. Robot1 cleans 4-3 whilst on 3-3
;;7. Robot2 moves left to 2-1
;;8. Robot2 cleans 3-1 from 2-1
;;9. Robot2 moves down to 1-1
;;10.Robot2 cleans 2-1 from 1-1
;;11.Robot2 moves right to 1-2
;;12.Robot2 cleans 2-2 whilst on 1-2
;;13.Robot2 moves down to 0-2
;;14.Robot2 cleans 1-2 from 0-2
;;15.Robot2 moves left to 0-1
;;16.Robot2 cleans 1-1
;;17.Robot1 moves down to 2-3
;;18.Robot1 cleans 3-3 when on 2-3
;;19.Robot1 moves down to 1-3
;;20.Robot1 cleans 2-3 from 1-3
;;21.Robot1 moves down to 0-3
;;22.Robot1 cleans 1-3 whilst on 0-3 - All the dirty tiles have now been cleaned, they never collided because they never went onto the same tile at the same time, they did not waste time cleaning clean tiles or cleaning tiles more than once, and they did not move onto tiles that had been cleaned...DONE!


;; Although this task was relatively simple to figure out using logic alone, I had never used PDDL before so a couple of resources helped me understand the syntax and structure.
;; Please find below a list of references, each with a brief description of how they helped me complete this task.

;; REFERENCES:

;;Helmert, M. (n.d.). [online] Cs.toronto.edu. Available at: https://www.cs.toronto.edu/~sheila/2542/s14/A1/introtopddl2.pdf [Accessed 11 Apr. 2019].
;;In order to be able to complete this task I needed a better understanding of PDDL syntax. I referred back to this resource that had been used in a lecture to grasp the basics of PDDL.

;; Russell, S. and Norvig, P. (2014). Artificial intelligence. 3rd ed. Harlow: Pearson, pp.Chapter 10 pg372-407.
;;As well as providing me with some important definitions, the examples in this book also helped me to understand the basic structure of planning.

;;Users.cecs.anu.edu.au. (n.d.). Writing Planning Domains and Problems in PDDL. [online] Available at: http://users.cecs.anu.edu.au/~patrik/pddlman/writing.html [Accessed 11 Apr. 2019].
;;I also wanted to broaden my knowledge beyond what had been covered in the lectures so I also used this resource as a relatively simple guide to PDDL.
