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
	@db.execute 'CREATE TABLE IF NOT exists Posts1
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		nickname TEXT
		)'

		@db.execute 'CREATE TABLE IF NOT exists Comments
		(
			id INTEGER PRIMARY KEY AUTOINCREMENT,
			created_date DATE,
			content TEXT,
			post_id INTEGER
			)'
end
#before вызывается каждый раз при перезагрузке
before do
	#инициализация БД
  init_db
end

get '/' do
	#выводим посты
	@results = @db.execute 'select * from Posts1 order by id desc'
	erb :index
end
# обработчик get-запроса (браузер получает страницу с сервера)
get '/new' do
  erb :new
end

post '/new' do
	#получает пересмнную из post-запроса
  content = params[:content]
	nickname = params[:nickname]
  if content.length <=0
		@error =  'Введите текст поста'
		return erb :new
	end
	if nickname.length <=0
		@error =  'Введите свое имя чёрт возьми'
		return erb :new
	end
	#сохранение данныв в DB
	@db.execute 'insert into Posts1 (content, nickname, created_date ) values (?, ?, datetime())', [content, nickname]

	redirect to '/'
end

#вывод информации о посте

get '/details/:post_id' do
	#получаем переменную из URL
	post_id = params[:post_id]
 # получаем список постов. (у нас только один пост)
	results = @db.execute 'select * from Posts1 where id = ?', [post_id]
	#выбираем этотт пост в переменную row
	@row = results[0]

	#вывод комментарием для аоста
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	erb :details
end
	#обработчик post запроса. отправляем коммент на сервер
post '/details/:post_id' do
	#получаем переменную из URL
	post_id = params[:post_id]
	#получает пересмнную из post-запроса
	content = params[:content]
	if content.length <=0
		@error =  'Введите текст комментария'
	redirect to ('/details/' + post_id)
	end
	#сохранение данныв в DB
	@db.execute 'insert into Comments
		(
			content,
			created_date,
			post_id
		)
			values
		(
			?,
			datetime(),
			?
			)', [content, post_id]

	redirect to ('/details/' + post_id)
end
