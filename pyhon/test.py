import random as diceroll

# Python function to prompt and return user's guess
def getUserGuess(min_val, max_val):
    while True:
        try:
            user_input = input(f"What do you think the dice rolled value is from ({min_val} to {max_val})? (Type 'quit' to give up): ")
            if user_input.lower() == 'quit':
                return None  # User wants to quit
            user_guess = int(user_input)
            if min_val <= user_guess <= max_val:
                return user_guess
            else:
                print(f"Please enter a number between {min_val} and {max_val}.")
        except ValueError:
            print("Invalid input. Please enter a valid number or 'quit' to give up.")

############################## MAIN application code ######################
# Simulate a dice being rolled, random result between 1 to 100 (inclusive)
###########################################################################
min_val = 1
max_val = 100
randomDiceRollResult = diceroll.randint(min_val, max_val)
max_attempts = 5  # Maximum number of attempts allowed
attempts = 0

print(f"Welcome to the Dice Guessing Game! You have {max_attempts} attempts to guess the number between {min_val} and {max_val}.")

while attempts < max_attempts:
    your_guess = getUserGuess(min_val, max_val)
    
    if your_guess is None:  # User chose to quit
        print(f"You gave up! The correct number was {randomDiceRollResult}.")
        break
    
    attempts += 1
    
    if your_guess == randomDiceRollResult:
        print("Correct! You win!")
        break
    elif your_guess < randomDiceRollResult:
        print("Nope! Your guess is too low.")
    else:
        print("Nope! Your guess is too high.")
    
    if attempts == max_attempts:
        print(f"Sorry, you've used all {max_attempts} attempts. The correct number was {randomDiceRollResult}.")
else:
    print("Game over!")
