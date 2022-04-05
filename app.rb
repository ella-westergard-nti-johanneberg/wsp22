require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

enable :sessions

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
    result = db.execute("SELECT * FROM user WHERE username = ?",username).first
    if result == nil
      redirect("/")
      p "Fel"
    end
    pwdigest = result["pwdigest"]
    id = result["id"]
    auth = result["authority"]
    if BCrypt::Password.new(pwdigest) == password
      session[:id] = id
      session[:auth] = auth
      redirect('/')
    else
      redirect('/')
      p "fel lösen"
    end
 end


post('/users/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]

    if(password == password_confirm)
      password_digest = BCrypt::Password.create(password)
      authority = 1
      db = connect_to_db("db/filmprojekt.db")
      db.execute("INSERT INTO user (username,pwdigest,authority) VALUES (?,?,?)",username,password_digest,authority)
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

get('/showlogin')  do
    slim(:login)
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

get ('/movie/rate/:id') do
    id = params[:id].to_i
    db = connect_to_db("db/filmprojekt.db")
    user_id = session[id]
    db.results_as_hash = true
    result = db.execute("SELECT * FROM movie WHERE id= ?", id).first
    slim(:"movies/rate",locals:{result:result})
end


post('/movie/:id/rated') do
  movie_id = params[:id].to_i
  rating = params[:rating].to_i
  user_id = session[:id]
  db = connect_to_db("db/filmprojekt.db")
  db.execute("INSERT INTO users_titles (user_id,movie_id,rating) VALUES (?,?,?)", user_id,movie_id,rating).first
  redirect('/')
end