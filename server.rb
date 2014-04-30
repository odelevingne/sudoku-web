require 'sinatra'
require_relative './lib/sudoku'
require_relative './lib/cell'

enable :sessions

def random_sudoku
  seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
  sudoku = Sudoku.new(seed.join)
  sudoku.solve!
  sudoku.to_s.chars
end

def puzzle(sudoku)
	40.times { sudoku[rand(0..80)] = 0}
	sudoku
end

get '/' do
	sudoku = random_sudoku
	session[:solution] = sudoku
  	@current_solution = puzzle(sudoku)
  	erb :index
end

