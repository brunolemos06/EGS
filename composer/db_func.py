import sqlite3 as sql
#FUNCTION TO CREATE INITIAL ENTRY 
def create_entry(auth_id):
    try:
        with sql.connect("compuser.db") as con:
            cur = con.cursor()
            cur.execute("INSERT INTO compuser (auth_id) VALUES (?)", (auth_id))
            con.commit()
            success = True
    except:
        con.rollback()
        success = False
    finally:
        con.close()
        return success

#FUNCTION TO CREATE FULL INITIAL ENTRY
def create_full_entry(auth_id, chat_id, review_id, trip_id):
    try:
        with sql.connect("compuser.db") as con:
            cur = con.cursor()
            cur.execute("INSERT INTO compuser (auth_id, chat_id, review_id, trip_id) VALUES (?, ?, ?, ?)", (auth_id, chat_id, review_id, trip_id))
            con.commit()
            success = True
    except:
        con.rollback()
        success = False
    finally:
        con.close()
        return success

#CHECK IF ENTRY ALREADY EXISTS
def get_entry(auth_id):
    try:
        with sql.connect("compuser.db") as con:
            cur = con.cursor()
            cur.execute("SELECT * FROM compuser WHERE auth_id = ?", (auth_id))
            entry = cur.fetchone()
            if not entry:
                return None
            return entry
    except:
        con.rollback()
        return None
    finally:
        con.close()