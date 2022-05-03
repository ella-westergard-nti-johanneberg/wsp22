require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

enable :sessions

before ('/movie/:rateid/rate') do
    validate()
end

before ('/movie/:editid/update') do
    validate()
end

before ('/movie/id/delete') do
    validate_admin()
end

before ('/movie/new') do
    validate()
end

get('/error') do
    slim(:error)
end

get('/adminerror') do
    slim(:error)
end

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
    if logTime()
        p "TEST"
        username = params[:username]
        password = params[:password]
        login(username, password)
    else
        redirect('/showlogin')
    end
 end

 get('/showaccount') do
    id = session[:id]
    @your_account = account(id)
    @your_rating = account_rating(id)
    @titles = index()
    slim(:"movies/account")
 end

get('/logout') do
    session[:id] = nil
    session[:auth] = 1
    redirect('/')
end


post('/users/new') do
    if logTime()
        username = params[:username]
        password = params[:password]
        password_confirm = params[:password_confirm]
        new_user(username, password, password_confirm)
    else
        redirect('/showregister')
    end
end

post('/admin/new') do
    if logTime()
        username = params[:username]
        password = params[:password]
        password_confirm = params[:password_confirm]
        new_user_admin(username, password, password_confirm)
    else
        redirect('/showadminregister')
    end
end

get("/new")do
    @genres = new_movie()
    slim(:"movies/new")
end

post("/movie/new") do
    movie = params[:movie]
    genre_id = params[:genre_id]
    link = params[:link]
    
    new_movie_post(movie, genre_id, link)
    redirect('/')
end

post("/movie/:id/delete") do
    id = params[:id]
   
    delete(id)
    
    redirect('/')
end

post("/movies/:movie_id/rate_delete") do
    movie_id = params[:movie_id]
    user_id = session[:id]

    rate_delete(movie_id, user_id)

    redirect('/showaccount')
end

get("/movie/:id/update") do
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

get('/movie/:id/rate') do
    

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
