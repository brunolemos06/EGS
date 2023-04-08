import sqlite3

conn = sqlite3.connect('compuser.db')
print("Opened database successfully")

conn.execute('CREATE TABLE compuser (auth_id VARCHAR(80) PRIMARY KEY, chat_id VARCHAR(120) UNIQUE, review_id INTEGER UNIQUE, trip_id VARCHAR(120) UNIQUE)')
print("Table Union compuser successfully")

conn.close()

# conn = sqlite3.connect('users.db')
# print("Opened database successfully")
# conn.execute('DROP TABLE IF EXISTS SocialUser')
# conn.execute('DROP TABLE IF EXISTS User')
# print("Table dropped successfully")
# conn.close()