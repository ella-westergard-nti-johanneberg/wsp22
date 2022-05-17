require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require_relative './model.rb'

enable :sessions
include Model

# Attempts to check if the client has authorization
before do
    if session[:auth] == nil && (request.path_info != '/login' && request.path_info != '/user' && request.path_info != '/showregister' && request.path_info != '/error' && request.path_info != '/' && request.path_info != '/showlogin' && request.path_info != '/admin' && request.path_info != '/showadminregister' && request.path_info != '/showaccount' && request.path_info != '/logout')
      redirect('/error')
    end
end

# Displays an error message
get('/error') do
    slim(:error)
end
# Displays an error message
get('/adminerror') do
    slim(:error)
end
# Display Landing Page
get('/') do
    slim(:start)
end
#Displays all movies
get('/movies') do
    @movies = index()
    slim(:"movies/index")
end
# Displays a register form
get('/showregister') do
    slim(:register)
end
# Displays a register form
get('/showadminregister') do
    slim(:adminregister)
end
# Displays a login form
get('/showlogin') do
    slim(:login)
end
# Login 
post('/login') do
    if logTime(session[:stress], session[:timeLogged])
        username = params[:username]
        password = params[:password]
        sessions = login(username, password)

        if sessions == false
            redirect('/error')
        else
            session[:id] = sessions[0]
            session[:auth] = sessions[1]
        end
        redirect('/')
    else
        redirect('/showlogin')
    end
 end
#Displays user account
 get('/showaccount') do
    id = session[:id]
    @your_account = account(id)
    @your_rating = account_rating(id)
    @titles = index()

    if id_nil(id)
        redirect('/error')
    end
    slim(:"movies/account")
 end

get('/logout') do
    session[:id] = nil
    session[:auth] = 1
    redirect('/')
end

# Creates new user
# @param [String] username, the user username
# @param [String] password, the user password
# @param [String] password_confirm, the users confirmed password
post('/users') do
    if logTime(session[:stress], session[:timeLogged])
        username = params[:username]
        password = params[:password]
        password_confirm = params[:password_confirm]
        if new_user(username, password, password_confirm) == false
            redirect('error')
        end
        redirect('/')
    else
        redirect('/showregister')
    end
end
#Creates new admin user
post('/admin') do
    if logTime(session[:stress], session[:timeLogged])
        username = params[:username]
        password = params[:password]
        password_confirm = params[:password_confirm]
        new_user_admin(username, password, password_confirm)
    else
        redirect('/showadminregister')
    end
end

# Displays a form to post new movie
get("/new")do
    id = session[:id]
    @genres = genres()

    if id_nil(id)
        redirect('/error')
    end

    slim(:"movies/new")
end
# Creates a new movie
post("/movie") do
    movie = params[:movie]
    genre_id = params[:genre_id]
    link = params[:link]
    user_id = session[:id]
    
    new_movie_post(movie, genre_id, link, user_id)
    redirect('/')
end
# Deletes an existing movie
post("/movie/:id/:user_id/delete") do
    id = params[:id]
    user_id = params[:user_id].to_i

    if authority(session[:id], session[:auth], user_id, 2) == false
        redirect('/error')
    end
   
    delete(id)
    
    redirect('/')
end
# Deletes an existing rating for movie
post("/movies/:movie_id/rate_delete") do
    movie_id = params[:movie_id]
    user_id = params[:user_id]

    if session[:id] != user_id
        redirect('/error')
    end

    rate_delete(movie_id, user_id)

    redirect('/showaccount')
end
# Displays a edit movie form
get("/movie/:id/:user_id/update") do
    @editid = params[:id]
    user_id = params[:user_id].to_i

    if authority(session[:id], session[:auth], user_id, 2) == false
        redirect('/error')
    end

    @genres = genres()
    @editmovie = update()

    slim(:"movies/edit")
end

# Updates an existing movie
post("/movie/:editid/update") do
    movie = params[:newmoviename]
    genre_id = params[:genre_id]
    link = params[:link]
    editid = params[:editid]
    
    update_post(movie, genre_id, link, editid)
    redirect('/movies')
end
# Displays a rating form
get('/movie/:id/rate') do

    @rateid = params[:id]
    @ratetitle = rate(@rateid)
    if session[:id]==nil
        redirect('/error')
    end
    slim(:"movies/rate")
end

# Rating a existing movie
post('/movie/:rateid/rate') do
    
    user_rate = params[:user_rate]
    movie_id = params[:rateid]
    user_id = session[:id]
    
    rate_post(user_rate, movie_id, user_id)
    
    redirect('/')
end
