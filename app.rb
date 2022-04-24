require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

enable :sessions


get('/') do
    slim(:start)
end

get('/movies') do
    @movies = index()
    slim(:"movies/index")
end

get('/showregister') do
    slim(:register)
end

get('/showadminregister') do
    slim(:adminregister)
end

get('/showlogin') do
    slim(:login)
end

post('/login') do
    username = params[:username]
    password = params[:password]
    login(username, password)
 end

get('/logout') do
    session[:id] = nil
    session[:auth] = 1
    redirect('/')
end


post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    new_user(username, password, password_confirm)
end

post('/admin/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]
    new_user_admin(username, password, password_confirm)
end


get("/new")do
    @genres = new_movie()
    slim(:"movies/new")
end

post("/newmovie") do
    movie = params[:movie]
    genre_id = params[:genre_id]
    link = params[:link]
    
    new_movie_post(movie, genre_id, link)

    redirect('/')
end

post("/movies/delete/:id") do
    id = params[:id]
   
    delete(id)
    
    redirect('/movies')
end

get("/movies/update/:id") do
    @editid = params[:id]

    @genres = genres()
    @editmovie = update()

    slim(:"movies/edit")
end

get('/showlogin')  do
    slim(:login)
end 


post("/movie/:editid/update") do
    movie = params[:newmoviename]
    genre_id = params[:genre_id]
    link = params[:link]
    editid = params[:editid]

    update_post(movie, genre_id, link, editid)
    redirect('/movies')
end

get('/movie/rate/:id') do
    

    @rateid = params[:id]
    @ratetitle = rate(@rateid)

    slim(:"movies/rate")
end


post('/movie/:rateid/rate') do
    
    user_rate = params[:user_rate]
    movie_id = params[:rateid]
    user_id = session[:id]
    
    rate_post(user_rate, movie_id, user_id)
    
    redirect('/')
end
