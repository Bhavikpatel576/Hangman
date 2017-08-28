require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"
require "sinatra/content_for"
require "yaml"

configure do 
	enable :sessions
	set :erb, :escape_html => true
end

def validate_character(letter)
	session[:word].include?(letter)
end

def add_letter(letter, answer_string)
	if validate_character(letter) #this line doesn't account for number of attempts
		session[:word].chars.each_with_index do |word_char, idx|
			if word_char == letter
				answer_string[idx] = word_char
			end
		end
	else
		session[:incorrect_letters] << letter
		session[:attempts] -= 1
	end
end

def check_game_status
	return true if session[:attempts] == 0
	session[:string_answer] == session[:word].chars
end

def valid_letter?(letter)
	!session[:incorrect_letters].include?(letter)
end

def data_path
	if ENV["RACK_ENV"] == "test"
		File.expand_path("../test/data", __FILE__)
	else
		File.expand_path("../data", __FILE__)
	end
end

get "/" do
	if session[:gameover] == true || session[:word] == nil
		redirect "/new"
	end
	@string_answer = session[:string_answer]
	if check_game_status
		redirect "/end"
	else
		erb :home, layout: :layout
	end
end

get "/new" do
	content = File.readlines("data/word_list.txt")
	@string = content[rand(content.size)].chomp
	session[:word] = @string
	session[:gameover] = false
	session[:attempts] = 6
	session[:string_answer] = Array.new(@string.length) { |v| v = '-' }
	session[:incorrect_letters] = []
	redirect "/"
end

get "/end" do 
	session[:gameover] = true
	@test = if session[:attempts] == 0
		"lost"
	elsif session[:string_answer] == session[:word]
		"won"
	end
	erb :gameover, layout: :layout
end

post "/" do 
	letter = params[:guess]
	if valid_letter?(letter)
		add_letter(letter, session[:string_answer])
		@string_answer = session[:string_answer]
		redirect "/"
	else
		session[:message] = "You've already entered that letter"
		@string_answer = session[:string_answer]
		erb :home, layout: :layout
	end
end

