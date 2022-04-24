def connect_to_db(path)
    db = SQLite3::Database.new(path)
    db.results_as_hash = true
    return db
end

def index()
    db = connect_to_db("db/filmprojekt.db")
    return db.execute("SELECT * FROM movie")
end

def  login(username, password)
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
        p "fel lösen"
        redirect('/')
    end
end

def new_user_or_admin(username, password, password_confirm, auth)
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

def genres()
    db = connect_to_db("db/filmprojekt.db")
    return db.execute("SELECT * FROM genre")
end

def new_movie()
    db = connect_to_db("db/filmprojekt.db")
    return db.execute("SELECT * FROM genre")
end

def new_movie_post(movie, genre_id, link)
    db = connect_to_db("db/filmprojekt.db")
    db.execute("INSERT INTO movie (Name, link, Genre_id) VALUES (?, ?, ?)",movie, link, genre_id)
end

def delete(id)
    db = connect_to_db("db/filmprojekt.db")
    db.execute("DELETE FROM movie WHERE Id='#{id}'")
end

def update()
    db = connect_to_db("db/filmprojekt.db")
    return db.execute("SELECT * FROM movie WHERE Id=?", @editid).first
end

def update_post(movie, genre_id, link, editid)
    db = connect_to_db("db/filmprojekt.db")
    db.execute("UPDATE movie SET Name = ?, Genre_id = ?, link = ?  WHERE Id=?", movie, genre_id, link, editid)
end

def rate(rateid)
    db = connect_to_db("db/filmprojekt.db")
    db.execute("SELECT * FROM movie WHERE id=?", rateid).first
end

def rate_post(user_rate, movie_id, user_id)
    db = connect_to_db("db/filmprojekt.db")
    db.execute("INSERT INTO user_movie_relation (rating, user_id, movie_id) VALUES (?,?,?)", user_rate, user_id, movie_id)
end