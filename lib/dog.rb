class Dog
    attr_accessor :id, :name, :breed

    def initialize(id: nil, name:, breed:)
        @id = id
        @name = name
        @breed = breed
    end

    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL

        DB[:conn].execute(sql)
    end

    def save
        if self.id
          self.update
        else
          sql = <<-SQL
            INSERT INTO dogs (name, breed) 
            VALUES (?, ?)
          SQL
          DB[:conn].execute(sql, self.name, self.breed)
          @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end 
        self
      end

    def self.create(hash)
        dog = Dog.new(hash)
        hash.each do |k,v|
            dog.send(("#{k}="), v)
        end
        dog.save
    end

    def self.new_from_db(array)
        Dog.new(id: array[0], name: array[1], breed: array[2])
    end

    def self.find_by_id(id)
        sql = "SELECT * FROM dogs WHERE id = ?"
        result = DB[:conn].execute(sql, id)
        new_from_db(result[0])
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if !dog.empty?
            info = dog[0]
            dog = new_from_db(info)
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name(name)
        sql = "SELECT * FROM dogs WHERE name = ?"
        result = DB[:conn].execute(sql, name)
        new_from_db(result[0])
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end