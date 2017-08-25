require "sinatra"
require "sinatra/reloader" if development?
require "tilt/erubis"
require "sinatra/content_for"
require "redcarpet"
require "yaml"
require "pry"

configure do 
	enable :session
	set :erb, :escape_html => true
end

before do
	@string = "concentrate"
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

get "/" do
	@string_answer = session[:string_answer]
	binding.pry
	erb :home, layout: :layout
end

get "/new" do
	# session[:string_answer] = Array.new(@string.length) { |v| v = '-' }
	session[:string_answer] = ["a","b"]
	binding.pry
	redirect "/"
end

get "/end" do 

end

post "/" do 
	letter = params[:guess]
	add_letter(letter, session[:string_answer])
	@string_answer = session[:string_answer]
	erb :home, layout: :layout
end

