; Create templates
(deftemplate Recipe
   (slot name)
   (slot cuisine)
   (slot difficulty)
   (slot ingredients)
   (slot instructions)
)

(deftemplate RecipeRating
   (slot recipe-name)
   (slot user-name)
   (slot rating)
)

(deftemplate User
   (slot name)
   (slot cuisine-preference)
   (slot difficulty-preference)
   (slot ingredient-preference)
)

; Create Rules

(defrule GetUserPreferences
    (not (User (name ?name)))
    =>
    ; inputs for user
    (printout t "insert your name !")
    (bind ?name (read))
    (printout t "Welcome, " ?name ". Let's find you a recipe!" crlf)
    (printout t "What cuisine do you prefer? ")
    (bind ?cuisine-pref (read))
    (printout t "How difficult should the recipe be? (Easy, Intermediate, Difficult) ")
    (bind ?difficulty-pref (read))
    (printout t "Do you have any specific ingredient preferences? ")
    (bind ?ingredient-pref (read))
    ; create new user fact
    (assert (User 
        (name ?name)
        (difficulty-preference ?difficulty-pref)
        (cuisine-preference ?cuisine-pref)
        (ingredient-preference ?ingredient-pref)
    ))
)

(defrule RecommendRecipe
    (User 
        (name ?name)
        (cuisine-preference ?cuisine-pref)
        (difficulty-preference ?difficulty-pref)
        (ingredient-preference ?ingredient-pref)
    )
    (Recipe 
        (name ?recipe)
        (cuisine ?cuisine)
        (difficulty ?difficulty)
        (ingredients ?ingredients)
    )
    (test (eq ?cuisine ?cuisine-pref))
    (test (eq ?difficulty ?difficulty-pref))
    (test (str-compare ?ingredients ?ingredient-pref))
    =>
    (printout t "Based on your preferences, we recommend: " ?recipe crlf)
    (printout t "Ingredients: " ?ingredients crlf)
    (printout t "Enjoy your meal!" crlf)
    ; (retract (User (name ?name)))
    ; (retract (Recipe (name ?recipe)))
)

(defrule checkRecipeCuisineAvailable ; check if the recipe is available based on cuisine
    (User 
        (name ?name)
        (cuisine-preference ?cuisine-pref)
        (difficulty-preference ?difficulty-pref)
        (ingredient-preference ?ingredient-pref)
    )
    (Recipe 
        (name ?recipe)
        (cuisine ?cuisine)
        (difficulty ?difficulty)
        (ingredients ?ingredients)
    )
    (test (neq ?cuisine ?cuisine-pref))
    =>
    (printout t "Sorry we don't have the cuisine you prefer, try again hehe" crlf)
    (retract (User (name ?name))) ; Delete user fact
     ; Get back to input
    (printout t "insert your name !")
    (bind ?name (read))
    (printout t "Welcome, " ?name ". Let's find you a recipe!" crlf)
    (printout t "What cuisine do you prefer? ")
    (bind ?cuisine-pref (read))
    (printout t "How difficult should the recipe be? (Easy, Intermediate, Difficult) ")
    (bind ?difficulty-pref (read))
    (printout t "Do you have any specific ingredient preferences? ")
    (bind ?ingredient-pref (read))
    ; create new user fact
    (assert (User 
        (name ?name)
        (difficulty-preference ?difficulty-pref)
        (cuisine-preference ?cuisine-pref)
        (ingredient-preference ?ingredient-pref)
    ))
)

(defrule GetUserRating
    (User 
        (name ?user-name)
        (cuisine-preference ?cuisine-pref)
        (difficulty-preference ?difficulty-pref)
        (ingredient-preference ?ingredient-pref)
    )
    (Recipe 
        (name ?recipe)
        (cuisine ?cuisine)
        (difficulty ?difficulty)
        (ingredients ?ingredients)
    )
    (test (eq ?cuisine ?cuisine-pref))
    (test (eq ?difficulty ?difficulty-pref))
    (test (str-compare ?ingredients ?ingredient-pref))
    =>
    (printout t "Have you tried the recommended recipe " ?recipe "? (Enter 'yes' or 'no') ")
    (bind ?user-response (read))
    (if (eq ?user-response yes)
        then
        (printout t "Great! Please rate the recipe from 1 to 5, with 5 being the best: ")
        (bind ?rating (read))
        (assert (RecipeRating (recipe-name ?recipe) (user-name ?user-name) (rating ?rating)))
        (printout t "Thank you for your rating!" crlf)
    else
        (printout t "No problem. If you try it later, feel free to come back and rate it!" crlf)
    )
)



(defrule ExitRecommendationWithRating
   (User (name ?name))
   (RecipeRating (user-name ?name))
   =>
   (printout t "Thank you for using the personalized recipe recommender, " ?name "!" crlf)
   (printout t "Don't forget to check out more recipes and share your feedback. Enjoy your meals!" crlf)
;    (retract (User (name ?name)))
   (exit)
)

; set initial facts

(deffacts SampleRecipes
    (Recipe 
        (name "Spaghetti Carbonara") 
        (cuisine Italian) 
        (difficulty Easy)
        (ingredients "spaghetti, eggs, bacon, Parmesan cheese") 
        (instructions "1. Cook spaghetti. 2. Fry bacon. 3. Mix eggs and cheese. 4. Toss with pasta.")
    )

    (Recipe 
        (name "Chicken Tikka Masala") 
        (cuisine Indian) 
        (difficulty Intermediate)
        (ingredients "chicken, yogurt, tomato sauce, spices") 
        (instructions "1. Marinate chicken. 2. Cook chicken. 3. Simmer in sauce.")
    )

    (Recipe 
        (name "Caesar Salad") 
        (cuisine American) 
        (difficulty Easy)
        (ingredients "romaine lettuce, croutons, Caesar dressing") 
        (instructions "1. Toss lettuce with dressing. 2. Add croutons.")
    )
)