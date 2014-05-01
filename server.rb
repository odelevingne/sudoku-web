require 'sinatra'
require 'sinatra/partial' 
require 'rack-flash'
require_relative './helpers/application'
require_relative './lib/sudoku'
require_relative './lib/cell'

enable :sessions
set :session_secret, 'I am the secret key'
set :partial_template_engine, :erb

use Rack::Flash

def random_sudoku
  seed = (1..9).to_a.shuffle + Array.new(81-9, 0)
  sudoku = Sudoku.new(seed.join)
  sudoku.solve!
  sudoku.to_s.chars
end


def puzzle(sudoku,level)
	sudoku_to_solve = sudoku.dup
	level.times { sudoku_to_solve[rand(0..80)] = 0}
	sudoku_to_solve
end

get '/' do
	prepare_to_check_solution
	generate_new_puzzle_if_necessary
	@current_solution = session[:current_board_status] || sessions[:puzzle]
	@solution = session[:solution]
	@puzzle = session[:puzzle]
  	erb :index
end

def prepare_to_check_solution
	@check_solution = session[:check_solution]
	if @check_solution
		flash[:notice] = "Incorrect values are highlighted in yellow"
	end
	session[:check_solution] = nil
end

def generate_new_puzzle_if_necessary(level = 50)
	return if session[:current_board_status] && session[:puzzle] && session[:solution]
	sudoku = random_sudoku
	session[:solution] = sudoku
	session[:puzzle] = puzzle(sudoku,level)
	session[:current_board_status] = session[:puzzle]
end



get '/solution' do
	@current_solution = session[:solution]
	@puzzle = []
	@solution = @current_solution
	erb :index
end

post '/' do
	cells = box_order_to_row_order(params["cell"])
	session[:current_board_status] = cells.map{|value| value.to_i }.join
	session[:check_solution] = true
	redirect to("/")
end

post '/easy' do
		session.clear
		generate_new_puzzle_if_necessary(25)
		redirect to("/")
end

post '/medium' do
		session.clear
		generate_new_puzzle_if_necessary(70)
		redirect to("/")
end

post '/hard' do
		session.clear
		generate_new_puzzle_if_necessary(81)
		redirect to("/")
end

get '/solution' do
			@current_solution = sessions[:solution]
end


def box_order_to_row_order(cells)
	boxes = cells.each_slice(9).to_a
	(0..8).to_a.inject([]) {|memo, i|
	first_box_index = i / 3*3
	three_boxes = boxes[first_box_index, 3]
	three_rows_of_three = three_boxes.map do |box|
		row_number_in_a_box = i % 3
		first_cell_in_the_row_index = row_number_in_a_box * 3
		box[first_cell_in_the_row_index, 3]
	end
	memo +=three_rows_of_three.flatten
}
end


				



