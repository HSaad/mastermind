require 'colorize'

class Game

	def initialize
		@player = Player.new()
		@computer = Computer.new()
		@board = Board.new()
	end

	def start
		print_instructions()
		choose_role()
		set_code()

		while (!game_over?)
			@code_breaker.guess_code()
			@board.draw(@code_breaker.player_guess)
			@code_maker.feedback(@code_breaker.player_guess.last)
			@board.display_feedback(@code_maker.feedback_array.last)
		end

		restart if (play_again?)
	end

	def print_instructions
		puts "Welcome to Mastermind!"
		puts "\nMaster Mind is a code-breaking game for two players. One player (code maker) creates a secret code"\
 		"using colored pegs (black, white, red, yellow, green or blue) in four different slots. The" \
		"colors and their exact order constitute the code. The other player (code breaker) has twelve" \
		"attempts to guess the secret code. After each guess the code maker will give feedback on the" \
		"most recent guess. The code maker will tell the code breaker whether or not their guess contained" \
		"a correct color in the correct slot (red square for each one) and whether or not their guess contained" \
		"a correct color in the incorrect slot (white square for each one). The feedback received doesn't indicate" \
		"which exact slots are correct, only that one or more of your guess pegs includes an exact or near match." \
		"Duplicate colors are permitted. The code breaker only has twelve guesses!" 
		puts "To enter a guess, type the colors in the order you wish, using commas to separate the colors"
		puts "For example, typing 'red, blue, yellow, green' will give the guess: "
		puts "  ".colorize(:background => :red) + "  ".colorize(:background => :blue) + "  ".colorize(:background => :yellow) + "  ".colorize(:background => :green)
	end

	def choose_role
		puts "\nChoose your role: "
		puts "1: Code Maker"
		puts "2: Code Breaker"

		get_role()
	end

	def get_role
		opponent = gets.chomp
		if opponent == "1" || opponent.downcase == "code maker"
			@code_breaker = @computer
			@code_maker = @player
		elsif opponent == "2" || opponent.downcase == "code breaker"
			@code_breaker = @player
			@code_maker = @computer
		else
			choose_role()
		end
	end

	def set_code
		@code_maker.set_code
		@code = @code_maker.code 
	end

	def game_over?
		if check_win() 
			print_win
			return true
		elsif @code_breaker.number_of_guesses == 12
			print_lose
			return true
		else
			return false
		end
	end

	def check_win
		return false if @code_breaker.player_guess.last == nil
		
		(@code_breaker.player_guess.last).each_with_index do |color, index|
			if(color != @code[index])
				return false
			end
		end
		return true
	end

	def print_win
		if @code_breaker == @player
			puts "Congratulations!"
			puts "You Win! You broke the secret code!"
		else
			puts "Computer Wins!"
		end
	end

	def print_lose
		if @code_breaker == @player
			puts "You Lose!"
		else
			puts "Computer Loses!"
		end
	end

	def play_again?
		puts "Play Again? (y/n)"
		response = gets.chomp
		if(response.downcase == "y" || response.downcase == "yes")
			return true
		else
			return false
		end
	end

	def restart
		@player = Player.new()
		@computer = Computer.new()
		@board = Board.new()

		start()
	end

	class Board

		def initialize
		end

		def draw(board_array)
			board_array.each do |array|
				array.each do |color|
					print "   ".colorize(:background => color.strip.to_sym)
				end
				print "\n"
			end
		end

		def display_feedback(feedback_array)
			puts "Feedback: "
			puts "Red square: for each guessed color in the correct color and correct position"
 			puts "White square: for each guessed color in the correct color but is NOT in the correct position"
			
			feedback_array[0].times do
				print "  ".colorize(:background => :red) + " "
			end

			feedback_array[1].times do
				print "  ".colorize(:background => :white) + " "
			end
			puts "\n"
		end

	end

	class Player
		attr_accessor :role, :code, :number_of_guesses, :player_guess, :feedback_array
		
		def initialize()
			@number_of_guesses = 0
			@player_guess = []
			@code = []
			@feedback_array = []
		end

		def guess_code()
			puts "Your Guess: "
			guess = gets.chomp
			if valid_guess?(guess)
				@player_guess << guess.split(",")
				@number_of_guesses += 1
			end
		end

		def valid_guess?(guess)
			guesses = guess.split(",")

			if guesses.length != 4
				guess_code
				return false 
			end

			guesses.each do |color|
				color = color.downcase.strip
				if (color != "black" && color != "white" && color != "red" && color != "yellow" &&
					color != "green" && color != "blue")
					guess_code
					return false
				end
			end
			return true
		end

		def set_code
			puts "Your Code: "
			color_code = gets.chomp
			if valid_code?(color_code)
				@code = color_code.split(",") #fix spaces in color terms
			end
		end

		def valid_code?(code)
			codes = code.split(",")

			if codes.length != 4
				set_code
				return false 
			end
			
			codes.each do |color|
				color = color.downcase.strip
				if (color != "black" && color != "white" && color != "red" && color != "yellow" &&
					color != "green" && color != "blue")
					set_code
					return false
				end
			end
			return true
		end


		def feedback(array)
			correct_position = 0
			correct_color = 0
			array.each_with_index do |guess, index|
				if guess == @code[index]
					correct_position += 1
				elsif @code.include?(guess)
					correct_color += 1
				end
			end
			@feedback_array.push([correct_position, correct_color])
		end
	
	end


	class Computer < Player

		def set_code
			color_array = ["black", "white", "red", "yellow", "green", "blue"]
			puts "Setting Code ..."
			4.times { @code.push(color_array[rand(5)])}
		end

		def guess_code()
			color_array = ["black", "white", "red", "yellow", "green", "blue"]
			guess = "#{color_array[rand(5)]},#{color_array[rand(5)]},#{color_array[rand(5)]},#{color_array[rand(5)]}"
			if valid_guess?(guess)
				puts "Computer's Guess: "
				@player_guess << guess.split(",")
				@number_of_guesses += 1
			end
		end
		
	end

end

game = Game.new
game.start