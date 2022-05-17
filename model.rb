module Model
    # Attempts to open a new database connection
    # @return [Array] containing all the data from the database
    def connect_to_db(path)
        db = SQLite3::Database.new(path)
        db.results_as_hash = true
        return db
    end
    #Attempts to select all movies
    # @update [Integer] containing the average rate of all rates on each movie
    # @return [Array] containing all the movies from the database
    # @see Model#connect_to_db
    def index()
        db = connect_to_db("db/filmprojekt.db")
        movies = db.execute("SELECT * FROM movie")
        movies.each do |movie|
            avg_rate = db.execute("SELECT AVG(rating) FROM user_movie_relation WHERE movie_id = ?", movie['Id']).first['AVG(rating)']
            p avg_rate
            db.execute("UPDATE movie SET avg_rate = ? WHERE id = ?",avg_rate, movie['Id'])
        end
        movies = db.execute("SELECT * FROM movie")
        return movies
    end
     # Attempts to check if user can login
     # @see Model#connect_to_db
    def  login(username, password)
        db = connect_to_db("db/filmprojekt.db")
        result = db.execute("SELECT * FROM user WHERE username = ?",username).first
        if result == nil
          return false
        end
        pwdigest = result["pwdigest"]
        id = result["id"]
        auth = result["authority"]
        if BCrypt::Password.new(pwdigest) == password
          return[id, auth]
        else
            return false
        end
    end
    #Attempts to select all user info
    # @return [Hash] containing all user account information
    def account(id)
        db = connect_to_db("db/filmprojekt.db")
        return db.execute("SELECT * FROM user WHERE id = ?", id).first
    end
    #Attempts to select all the users ratings
    # @return [Hash] containing all the users ratings
    def account_rating(id)
        db = connect_to_db("db/filmprojekt.db")
        return db.execute("SELECT * FROM user_movie_relation WHERE user_id =?", id)
    end
    # Attempts to register user
    # @param [String] password, the password input
    # @param [String] username, the user username
    # @return [Boolean] whether the user registration succeeds 
    # @see Model#connect_to_db
    def new_user(username, password, password_confirm)
        if(password == password_confirm)
            password_digest = BCrypt::Password.create(password)
            authority = 1
            db = connect_to_db("db/filmprojekt.db")
            db.execute("INSERT INTO user (username,pwdigest,authority) VALUES (?,?,?)",username,password_digest,authority)
            return true
          else
            return false
            "Lösenorden matchade inte"
          end
    end
    # Attempts to register user
    # @param [String] password, the password input
    # @param [String] username, the user username
    # @return [Boolean] whether the user registration succeeds 
    # @see Model#connect_to_db
    def new_user_admin(username, password, password_confirm)
        if(password == password_confirm)
            password_digest = BCrypt::Password.create(password)
            authority = 2
            db = connect_to_db("db/filmprojekt.db")
            db.execute("INSERT INTO user (username,pwdigest,authority) VALUES (?,?,?)",username,password_digest,authority)
            return true
          else
            "Lösenorden matchade inte"
            return false
          end
    end
    # Attempts to check if the user is logged in or not
    # @return [Boolean] true if the user is not logged in and false if the user is logged in
    def id_nil(id)
        return id == nil
    end
     #Attempts to select all the available genres
     # @return [Hash] containing all the avaible genres
     # @see Model#connect_to_db
    def genres()
        db = connect_to_db("db/filmprojekt.db")
        return db.execute("SELECT * FROM genre")
    end
    # Attempts to create a new movie in database
    #
    def new_movie_post(movie, genre_id, link, user_id)
        db = connect_to_db("db/filmprojekt.db")
        db.execute("INSERT INTO movie (Name, link, Genre_id, user_id) VALUES (?, ?, ?, ?)",movie, link, genre_id, user_id)
    end
    # Attempts to delete an existing show in database
    def delete(id)
        db = connect_to_db("db/filmprojekt.db")
        db.execute("DELETE FROM movie WHERE Id='#{id}'")
        db.execute("DELETE FROM user_movie_relation WHERE movie_id='#{id}'")
    end
    # Attempts to retrieve all movie info with a specified id
    # @return [Hash] containing all movie info with a specified if
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


        if db.execute("SELECT rating FROM user_movie_relation WHERE user_id = ? AND movie_id = ?", user_id, movie_id).first == nil
            db.execute("INSERT INTO user_movie_relation (rating, user_id, movie_id) VALUES (?,?,?)", user_rate, user_id, movie_id)
        else
            db.execute("UPDATE user_movie_relation SET rating = ? WHERE user_id = ? AND movie_id = ?", user_rate, user_id, movie_id)
        end
    end

    def rate_delete(movie_id, user_id)
        db = connect_to_db("db/filmprojekt.db")
        db.execute("DELETE FROM user_movie_relation WHERE movie_id = ? AND user_id = ?", movie_id, user_id)
    end
    # Attempts to check if the user id is what is required and if the user has the correct authorization
    # @return [Boolean] whetever the above stated is true

    def ownership(user_id,movie_id, authority, exception_authority)
        db = connect_to_db("db/filmprojekt.db")
        owner = db.execute("SELECT user_id FROM movie WHERE Id = ?", movie_id).first["user_id"]
        if user_id == owner || authority == exception_authority
            return true
        else
            return false
        end
    end
    # Attempts to check if too many inputs are recieved in close proximity
    # @param [Integer] latestTime, the latest logged time
    # @return [Boolean] whether the inputs are recieved in close proximity
    # @see Model#connect_to_db
    def logTime(stress, timeLogged)
        tempTime = Time.now.to_i

        if timeLogged == nil
            timeLogged = 0
        end
        difTime = tempTime - timeLogged

        if difTime < 1.5
            timeLogged = tempTime
            stress = true
            return false
        else
            timeLogged = tempTime
            stress = false
            return true
        end
    end
end
def isEmpty(text)
    if text == nil
        return true
    elsif text == "" || text.scan(/ /).empty? == false 
        return true
    else
        return false
    end
end