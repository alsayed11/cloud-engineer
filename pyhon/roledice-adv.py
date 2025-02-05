import random as diceroll

# Function to prompt and return user's guess
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
print("Welcome to the Dice Guessing Game!")

# Define difficulty levels
difficulty_levels = {
    "easy": {"min_val": 1, "max_val": 10, "max_attempts": 7},
    "medium": {"min_val": 1, "max_val": 50, "max_attempts": 5},
    "hard": {"min_val": 1, "max_val": 100, "max_attempts": 3}
}

# Let the user choose a difficulty level
while True:
    difficulty = input("Choose a difficulty level (easy, medium, hard): ").lower()
    if difficulty in difficulty_levels:
        break
    else:
        print("Invalid difficulty level. Please choose 'easy', 'medium', or 'hard'.")

# Set the game parameters based on the chosen difficulty
min_val = difficulty_levels[difficulty]["min_val"]
max_val = difficulty_levels[difficulty]["max_val"]
max_attempts = difficulty_levels[difficulty]["max_attempts"]

# Ask if the user wants hints
hints_enabled = input("Would you like hints (too high/too low)? (yes/no): ").lower() == 'yes'

# Simulate a dice being rolled, random result between min_val and max_val (inclusive)
randomDiceRollResult = diceroll.randint(min_val, max_val)

print(f"Let's begin! You have {max_attempts} attempts to guess the number between {min_val} and {max_val}.")

attempts = 0

while attempts < max_attempts:
    your_guess = getUserGuess(min_val, max_val)
    
    if your_guess is None:  # User chose to quit
        print(f"You gave up! The correct number was {randomDiceRollResult}.")
        break
    
    attempts += 1
    
    if your_guess == randomDiceRollResult:
        print("Correct! You win!")
        break
    elif hints_enabled:
        if your_guess < randomDiceRollResult:
            print("Nope! Your guess is too low.")
        else:
            print("Nope! Your guess is too high.")
    else:
        print("Nope! Try again.")
    
    if attempts == max_attempts:
        print(f"Sorry, you've used all {max_attempts} attempts. The correct number was {randomDiceRollResult}.")
else:
    print("Game over!")
