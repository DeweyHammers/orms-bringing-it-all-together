class Dog
    attr_accessor :name, :breed
    attr_reader :id

    def initialize(name:, breed:, id:nil)
        @name = name 
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = 
        <<-SQL
          CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            bread TEXT
          );
        SQL

        DB[:conn].execute(sql)
    end

    def self.drop_table
      DB[:conn].execute("DROP TABLE dogs") 
    end

    def save
      if self.id
        self.update 
      else
        sql = 
        <<-SQL
          INSERT INTO dogs (name, breed)
          VALUES (?, ?);
        SQL

        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end

    def update
      sql = 
      <<-SQL
        UPDATE dogs 
        SET name = ?, breed = ? 
        WHERE id = ?;
      SQL

      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def self.create(name:, breed:)
      dog = Dog.new(name: name, breed: breed)
      dog.save
      dog
    end

    def self.new_from_db(array)
      Dog.new(name: array[1],breed: array[2],id: array[0])
    end

    def self.find_by_id(id)
      sql = 
      <<-SQL
        SELECT * 
        FROM dogs
        WHERE id = ?
      SQL

      result = DB[:conn].execute(sql, id).first
      Dog.new_from_db(result)
    end

    def self.find_by_name(name)
      sql =
      <<-SQL
        SELECT * 
        FROM dogs 
        WHERE name = ?
      SQL

      result = DB[:conn].execute(sql, name).first
      Dog.new_from_db(result)
    end

    def self.find_or_create_by(name:, breed:)
      sql = 
      <<-SQL
        SELECT * 
        FROM dogs 
        WHERE name = ? 
        AND breed = ?;
      SQL

      result = DB[:conn].execute(sql, name, breed).first
      result ? Dog.new_from_db(result) : Dog.create(name: name,breed: breed)
    end
end