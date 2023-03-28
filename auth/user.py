from flask_login import UserMixin

from db import get_db

class User(UserMixin):
    def __init__(self, id_, provider_id, provider):
        self.id = id_
        self.provider_id = provider_id
        self.provider = provider

    @staticmethod
    def get(provider_id, provider):
        db = get_db()
        user = db.execute(
            "SELECT * FROM user WHERE provider_id = ? AND provider = ?", (provider_id, provider)
        ).fetchone()
        if not user:
            return None

        user = User(
            id_=user[0], provider_id=user[1], provider=user[2]
        )
        return user

    @staticmethod
    def create(id_, provider_id, provider):
        db = get_db()
        db.execute(
            "INSERT INTO user (id, provider_id, provider) "
            "VALUES (?, ?, ?)",
            (id_, provider_id, provider),
        )
        db.commit()

    def is_active(self):
        return True
    
    def is_anonymous(self):
        return False
    
    def get_id(self):
        return self.id