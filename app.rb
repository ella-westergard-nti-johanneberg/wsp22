require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end


get('/') do
    slim(:start)
end

get('/showregister') do
    slim(:register)
end

get('/showlogin') do
    slim(:login)
end

post('/login') do
    username = params[:username]
    password = params[:password]

    db = connect_to_db("db/filmprojekt.db")

    result = db.execute("SELECT * FROM user WHERE username = ?", username).first
    pwdigest = result["pwdigest"]
    id = result["id"]

    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      redirect('/')
    else
      "Fel lösenord!"
    end
end


post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]

    if(password == password_confirm)
      password_digest = BCrypt::Password.create(password)
      db = connect_to_db("db/filmprojekt.db")
      db.execute("INSERT INTO user (username,pwdigest) VALUES (?,?)",username,password_digest)
      redirect('/')
    else
      "Lösenorden matchade inte"
    end
end

get('/movies') do
    db = connect_to_db("db/filmprojekt.db")
    @movies = db.execute("SELECT * FROM movie")

    p "movies:#{@movies}"
    slim(:"movies/index")
end

=begin
    get('/')  do
    db = connect_to_db("db/filmprojekt.db")
    #result = db.execute("SELECT * FROM movie")
    @result = db.execute("SELECT * FROM movie")
    #slim(:start, locals: {movies: result})
    slim(:start)
end 
=end

get("/new")do
    db = connect_to_db("db/filmprojekt.db")
    @genres = db.execute("SELECT * FROM genre")


    slim(:"movies/new")
end

post("/newmovie") do
    
    movie = params[:movie]
    genre_id = params[:genre_id]
    link = params[:link]

    db = connect_to_db("db/filmprojekt.db")
    db.execute("INSERT INTO movie (Name, link, Genre_id) VALUES (?, ?, ?)",movie, link, genre_id)
    redirect('/')
end

post("/movies/delete/:id") do
    id = params[:id]
    db = connect_to_db("db/filmprojekt.db")
    db.execute("DELETE FROM movie WHERE Id='#{id}'")
    redirect('/movies')
end

get("/movies/update/:id") do
    @editid = params[:id]


    db = connect_to_db("db/filmprojekt.db")
    @genres = db.execute("SELECT * FROM genre")
    @movies = db.execute("SELECT * FROM movie")
    @editmovie = db.execute("SELECT * FROM movie WHERE Id=?", @editid).first
    p @editmovie
    slim(:"movies/edit")
end

get('/movies/:id/rate') do 
    @rate = params[:id]
    @ratetitle = db.execute("SELECT * FROM movie WHERE id=?", @rateid).first
   
    p @ratetitle

    slim(:"movies/rate")
end
post('/movies/:rateid/rate') do
    db = connect_to_db("db/filmprojekt.db")
    user_rate = params[:user_rate]

    p db.execute("SELECT user_id FROM user_movive_relation WHERE EXISTS user_id = ?", session[:id])
end

get('/showlogin')  do
    slim(:login)
end 

post('/login') do

end

post("/movie/:editid/update") do
    
    movie = params[:newmoviename]
    genre_id = params[:genre_id]
    link = params[:link]
    editid = params[:editid]

    db = connect_to_db("db/filmprojekt.db")
    db.execute("UPDATE movie SET Name = ?, Genre_id = ?, link = ?  WHERE Id=?", movie, genre_id, link, editid)
    redirect('/movies')
end

