#encoding: utf-8
#https://vimeo.com/105911565
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'seprosorium.db'
	@db.results_as_hash = true
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT exists Posts
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT
		)'
end

before do
  init_db
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School</a>"
end

get '/new' do
  erb :new
end

post '/new' do
  content = params[:content]

	erb "You typed #{content}"
end
