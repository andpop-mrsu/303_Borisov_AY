import re
def devide_line(s):
    #выделение id
    id_end = re.match(r'\d*', s).end()
    id = s[:id_end]
    #выделение year
    year = "NULL"
    title = "NULL"
    genres = "NULL"
    if re.search(r'[(]\d\d\d\d[)]',s) is None:
        if re.search(r'(no genres listed)', s) is None:
            title_end = s.rfind(",")
            title = s[id_end+1: title_end]
            genres = s[title_end+1:]
        else:
            title = s[id_end+1:]
    else:
        #выделение year
        year_end = re.search(r'[(]\d\d\d\d[)]',s).end()
        year_start = re.search(r'[(]\d\d\d\d[)]',s).start()
        year = s[year_start+1:year_end-1]
        #выделение genres  
        genres = s[year_end+1:]
        #выделение title 
        title = s[id_end+1:year_start-1]
    
    title = title.replace("'", "‘")        
    return [id, title, year, genres]


with open("db_init.sql", "w", encoding="utf-8") as db_file:
    #создание или открытие БД
    print(".open movies_rating.db\n", file = db_file)
    #проверка на существование таблиц и их удаление, если они существуют
    print("DROP TABLE IF EXISTS movies;\n", file = db_file)
    print("DROP TABLE IF EXISTS ratings;\n", file = db_file)
    print("DROP TABLE IF EXISTS tags;\n", file = db_file)
    print("DROP TABLE IF EXISTS users;\n", file = db_file)
    #создание таблиц
    print("CREATE TABLE movies (id INTEGER NOT NULL PRIMARY KEY, title TEXT, year TEXT, genres TEXT);\n", file = db_file)
    print("CREATE TABLE ratings(id INTEGER NOT NULL PRIMARY KEY, user_id INTEGER, movie_id INTEGER, rating REAL, timestamp INTEGER);\n", file = db_file)
    print("CREATE TABLE tags(id INTEGER NOT NULL PRIMARY KEY, user_id INTEGER, movie_id INTEGER, tag TEXT, timestamp INTEGER);\n", file = db_file)
    print("CREATE TABLE users(id INTEGER NOT NULL PRIMARY KEY, name TEXT, email TEXT, gender TEXT, register_date TEXT, occupation TEXT);\n", file = db_file)
    #заполнение таблицы ratings
    print("INSERT INTO ratings (id, user_id, movie_id, rating, timestamp)\n", file = db_file)
    print("VALUES", end=' ', file = db_file)
    with open("ratings.csv","r") as ratings:
        file = ratings.readlines()[1:]
        k=1
        for i in file:
            fields = i[:-1].split(",")
            print(f"({k},{fields[0]},{fields[1]},{fields[2]},{fields[3]})", end='',file = db_file)
            if k == len(file):
                print(";",file = db_file)
            else:
                print(",",file = db_file)
            k+=1            
            
    #заполнение таблицы tags
    print("INSERT INTO tags (id, user_id, movie_id, tag, timestamp)\n", file = db_file)
    print("VALUES", end=' ', file = db_file)
    with open("tags.csv","r") as tags:
        file = tags.readlines()[1:]
        k=1
        for i in file:
            i = i.replace("'", "‘")
            fields = i[:-1].split(",")
            print(f"({k},{fields[0]},{fields[1]},'{fields[2]}',{fields[3]})", end='',file = db_file)
            if k == len(file):
                print(";",file = db_file)
            else:
                print(",",file = db_file)
            k+=1 
    #заполнение таблицы users
    print("INSERT INTO users (id, name, email, gender, register_date, occupation)\n", file = db_file)
    print("VALUES", end=' ', file = db_file)
    with open("users.txt","r") as users:
        file = users.readlines()[1:]
        k=1
        for i in file:
            i = i.replace("'", "‘")
            fields = i[:-1].split("|")
            print(f"({fields[0]},'{fields[1]}','{fields[2]}','{fields[3]}','{fields[4]}','{fields[5]}')", end='',file = db_file)
            if k == len(file):
                print(";",file = db_file)
            else:
                print(",",file = db_file)
            k+=1   
    #заполнение таблицы movies
    print("INSERT INTO movies (id, title, year, genres)\n", file = db_file)
    print("VALUES", end=' ', file = db_file)
    with open("movies.csv","r") as movies:
        file = movies.readlines()[1:]
        k=1
        for i in file:
            fields = devide_line(i[:-1])
            print(f"({fields[0]},'{fields[1]}',{fields[2]},'{fields[3]}')", end='',file = db_file)
            if k == len(file):
                print(";",file = db_file)
            else:
                print(",",file = db_file)
            k+=1               
    