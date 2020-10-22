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
# configureвызывается каждый раз при конфигарации приложения
# когда именился код программы и перезагрузилась страница
configure do
	#инициализация БД
	init_db
	#создает таблицу если таблица не сущестует
	@db.execute 'CREATE TABLE IF NOT exists Posts
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT
		)'
end
#before вызывается каждый раз при перезагрузке
before do
	#инициализация БД
  init_db
end

get '/' do
	#выводим посты
	@results = @db.execute 'select * from Posts order by id desc'
	erb :index
end
# обработчик get-запроса (браузер получает страницу с сервера)
get '/new' do
  erb :new
end

post '/new' do
	#получает пересмнную из post-запроса
  content = params[:content]
  if content.length <=0
		@error =  'Введите текст поста'
		return erb :new
	end
	#сохранение данныв в DB
	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]
	erb "You typed #{content}"
end
