require 'sinatra'
require_relative './lib/sudoku'
require_relative './lib/cell'

enable :sessions
set :session_secret, '*&(^B234'

def random_sudoku
  seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
  sudoku = Sudoku.new(seed.join)
  sudoku.solve!
  sudoku.to_s.chars
end

def puzzle(sudoku)
	sudoku_to_solve = sudoku.dup
	40.times { sudoku_to_solve[rand(0..80)] = 0}
	sudoku_to_solve
end

get '/' do
	sudoku_solution = random_sudoku
	session[:solution] = sudoku_solution
  	@current_solution = puzzle(sudoku_solution)
  	erb :index
end

get '/solution' do
	@current_solution = session[:solution]
	erb :index
end
