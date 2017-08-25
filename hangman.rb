require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"
require "sinatra/content_for"
require "redcarpet"
require "yaml"
require "pry"

configure do 
	enable :sessions
	set :erb, :escape_html => true
end

before do
	@string = "concentrate"
	session[:attempts] ||= 6
end

def validate_character(letter)
	@string.include?(letter)
end

def add_letter(letter, answer_string)
	if validate_character(letter) #this line doesn't account for number of attempts
		@string.chars.each_with_index do |word_char, idx|
			if word_char == letter
				answer_string[idx] = word_char
			end
		end
	else
		session[:attempts] -= 1
	end
end

def check_game_status
	session[:string_answer] == session[:word]

get "/" do
	@string_answer = session[:string_answer]
	if check_game_status
		redirect "/end"
	else
		erb :home, layout: :layout
	end
end

get "/new" do
	session[:word] = @string.chars
	session[:string_answer] = Array.new(@string.length) { |v| v = '-' }
	redirect to("/")
end

get "/end" do 
	erb :gameover
end

post "/" do 
	letter = params[:guess]
	add_letter(letter, session[:string_answer])
	@string_answer = session[:string_answer]
	redirect "/"
	# erb :home, layout: :layout
end

