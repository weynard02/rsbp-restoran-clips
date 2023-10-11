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

(deftemplate RecipeCreated
    (slot name) 
    (slot cuisine) 
    (slot difficulty) 
    (slot ingredients) 
)

(deftemplate RecipeOrdered
    (slot name) 
    (slot cuisine) 
    (slot difficulty) 
    (slot ingredients) 
)

(deftemplate SetMatch
   (slot name)
   (slot recipe1-name)
   (slot recipe2-name)
)

; Create Rules

(defrule GetUserPreferences
    (not (User (name ?name)))
    =>
    ; inputs for user
    (printout t "insert your name !")
    (bind ?name (read))
    (if (eq ?name exit)
        then (exit) 
    else
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
    
    (assert (RecipeRecommended))
    (assert (RecipeCreated
        (name ?recipe)
        (cuisine ?cuisine)
        (difficulty ?difficulty)
        (ingredients ?ingredients)
    ))
    (assert (RecipeOrdered
        (name ?recipe)
        (cuisine ?cuisine)
        (difficulty ?difficulty)
        (ingredients ?ingredients)
    ))
    
)

(defrule RecommendOtherRecipe
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
    (not (RecipeRecommended))
    =>
    (printout t "There are other recipe that you might like!" crlf)
    (if (eq ?cuisine ?cuisine-pref)
        then 
        (printout t "Based on your cuisine preference, we recommend: " ?recipe crlf)
        (printout t "Ingredients: " ?ingredients crlf)
        (printout t "Enjoy your meal!" crlf)
        (assert (RecipeCreated
            (name ?recipe)
            (cuisine ?cuisine)
            (difficulty ?difficulty)
            (ingredients ?ingredients)
        ))
        (assert (RecipeOrdered
            (name ?recipe)
            (cuisine ?cuisine)
            (difficulty ?difficulty)
            (ingredients ?ingredients)
        ))
        (assert (RecipeRecommended))
        
    else
        (if (eq ?difficulty ?difficulty-pref)
            then
            (printout t "Based on your difficulty preference, we recommend: " ?recipe crlf)
            (printout t "Ingredients: " ?ingredients crlf)
            (printout t "Enjoy your meal!" crlf)
            (assert (RecipeCreated
                (name ?recipe)
                (cuisine ?cuisine)
                (difficulty ?difficulty)
                (ingredients ?ingredients)
            ))
            (assert (RecipeOrdered
                (name ?recipe)
                (cuisine ?cuisine)
                (difficulty ?difficulty)
                (ingredients ?ingredients)
            ))
            (assert (RecipeRecommended))
            
        else 
            (if (str-compare ?ingredients ?ingredient-pref)
                then
                (printout t "Based on your ingredient preference, we recommend: " ?recipe crlf)
                (printout t "Ingredients: " ?ingredients crlf)
                (printout t "Enjoy your meal!" crlf)
                (assert (RecipeCreated
                    (name ?recipe)
                    (cuisine ?cuisine)
                    (difficulty ?difficulty)
                    (ingredients ?ingredients)
                ))
                (assert (RecipeOrdered
                    (name ?recipe)
                    (cuisine ?cuisine)
                    (difficulty ?difficulty)
                    (ingredients ?ingredients)
                ))
                (assert (RecipeRecommended))
                
            else 
            )
        )
    )
)

(defrule SaySorry
    (not (RecipeRecommended))
    =>
    (printout t "Sorry, we couldn't find a recipe that exactly matches your preferences." crlf)
)

(defrule SetMatchCheck
   (RecipeCreated
        (name ?recipe1)
        (cuisine ?cuisine1)
        (difficulty ?difficulty1)
        (ingredients ?ingredients1)
    )
   (RecipeCreated
        (name ?recipe2)
        (cuisine ?cuisine2)
        (difficulty ?difficulty2)
        (ingredients ?ingredients2)
    )
   (SetMatch
         (name ?name_set)
         (recipe1-name ?recipe_match1)
         (recipe2-name ?recipe_match2)
    )
 (test (and (eq ?recipe1 ?recipe_match1)(eq ?recipe2 ?recipe_match2)))
   =>
    (printout t "BEST MATCH!!! , You Got " ?name_set crlf)
)

(defrule GetUserRating
    (User 
        (name ?user-name)
        (cuisine-preference ?cuisine-pref)
        (difficulty-preference ?difficulty-pref)
        (ingredient-preference ?ingredient-pref)
    )
    ?recipeOrdered <-   (RecipeOrdered 
        (name ?recipe)
        (cuisine ?cuisine)
        (difficulty ?difficulty)
        (ingredients ?ingredients)
    )
    (RecipeRecommended)
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
    (retract ?recipeOrdered)
        
    
)


(defrule ExitRecommendationWithRating
   ?user <- (User (name ?name))
   ?recom <- (RecipeRecommended)
   =>
   (printout t "Thank you for using the personalized recipe recommender, " ?name "!" crlf)
   (printout t "Don't forget to check out more recipes and share your feedback. Enjoy your meals!" crlf)
   (retract ?recom)
   (retract ?user)
   ;(exit)
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

   (Recipe 
          (name "Chicken Alfredo Pasta") 
          (cuisine Italian) 
          (difficulty Moderate)
          (ingredients "fettuccine, chicken breast, heavy cream, garlic, Parmesan cheese") 
          (instructions "1. Cook fettuccine. 2. Sauté chicken and garlic. 3. Add heavy cream. 4. Mix with pasta. 5. Sprinkle Parmesan.")
   )

   (Recipe 
          (name "Vegetarian Stir-Fry") 
          (cuisine Asian) 
          (difficulty Easy)
          (ingredients "tofu, broccoli, bell peppers, soy sauce, ginger, garlic") 
          (instructions "1. Sauté tofu. 2. Stir-fry vegetables with garlic and ginger. 3. Add soy sauce. 4. Combine all ingredients.")
   )

   (Recipe 
          (name "Beef Tacos") 
          (cuisine Mexican) 
          (difficulty Easy)
          (ingredients "ground beef, taco seasoning, tortillas, lettuce, tomatoes, cheese") 
          (instructions "1. Cook beef with taco seasoning. 2. Fill tortillas with beef, lettuce, tomatoes, and cheese.")
   )

   (Recipe 
          (name "Mushroom Risotto") 
          (cuisine Italian) 
          (difficulty Moderate)
          (ingredients "Arborio rice, mushrooms, onion, white wine, Parmesan cheese") 
          (instructions "1. Sauté onions and mushrooms. 2. Add Arborio rice. 3. Deglaze with white wine. 4. Stir in Parmesan.")
   )

   (Recipe 
          (name "Grilled Salmon") 
          (cuisine Seafood) 
          (difficulty Easy)
          (ingredients "salmon fillets, lemon, olive oil, garlic, dill") 
          (instructions "1. Marinate salmon in olive oil, lemon, and garlic. 2. Grill until cooked. 3. Sprinkle with dill.")
   )

   (Recipe 
          (name "Caprese Salad") 
          (cuisine Malaysian) 
          (difficulty Easy)
          (ingredients "tomatoes, fresh mozzarella, basil, balsamic glaze") 
          (instructions "1. Slice tomatoes and mozzarella. 2. Arrange with basil. 3. Drizzle with balsamic glaze.")
   )

   (Recipe 
          (name "Shrimp Scampi") 
          (cuisine Italian) 
          (difficulty Moderate)
          (ingredients "shrimp, linguine, garlic, butter, white wine, lemon") 
          (instructions "1. Cook linguine. 2. Sauté shrimp and garlic in butter. 3. Deglaze with white wine. 4. Squeeze lemon.")
   )

   (Recipe 
          (name "Chicken Curry") 
          (cuisine Indian) 
          (difficulty Moderate)
          (ingredients "chicken, curry powder, coconut milk, onion, garlic, ginger") 
          (instructions "1. Sauté onions, garlic, and ginger. 2. Add chicken and curry powder. 3. Pour coconut milk. 4. Simmer until cooked.")  
   )

   (Recipe 
          (name "Homemade Pizza") 
          (cuisine Italian) 
          (difficulty Moderate)
          (ingredients "pizza dough, tomato sauce, mozzarella cheese, toppings of choice") 
          (instructions "1. Roll out pizza dough. 2. Spread tomato sauce and cheese. 3. Add toppings. 4. Bake until crust is golden.")
   )

   (Recipe 
          (name "Greek Salad") 
          (cuisine Mediterranean) 
          (difficulty Easy)
          (ingredients "cucumbers, tomatoes, olives, feta cheese, red onion, olive oil") 
          (instructions "1. Chop vegetables and feta. 2. Mix with olives and red onion. 3. Drizzle with olive oil.")
   )

   (Recipe 
          (name "Pasta Primavera") 
          (cuisine Polandian) 
          (difficulty Easy)
          (ingredients "penne pasta, assorted vegetables, garlic, olive oil, Parmesan cheese") 
          (instructions "1. Cook penne pasta. 2. Sauté vegetables and garlic in olive oil. 3. Toss with pasta. 4. Sprinkle with Parmesan.")
   ) 

   (Recipe 
          (name "Beef and Broccoli Stir-Fry") 
          (cuisine Asian) 
          (difficulty Easy)
          (ingredients "beef sirloin, broccoli, soy sauce, garlic, ginger") 
          (instructions "1. Slice beef and stir-fry with garlic and ginger. 2. Add broccoli. 3. Pour soy sauce. 4. Cook until beef is done.")
   )
    (SetMatch
        (name "PerfectBody")
        (recipe1-name "Caesar Salad")
        (recipe2-name "Spaghetti Carbonara")
    )
)