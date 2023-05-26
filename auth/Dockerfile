FROM python:3.10.6

# Set the working directory inside the container
WORKDIR /auth_backend

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy rest of flask auth app
COPY app.py .
COPY client_secret_google.json .
COPY sqlite_setup.py .
COPY clean_db.py .
COPY user.py .
COPY users.db .

# Expose port (still to decide)
EXPOSE 5100

#CLEAN DB 
CMD ["python3", "clean_db.py"]

#SETUP DB
CMD ["python3", "sqlite_setup.py"]

# Define startup command
CMD ["python3", "app.py"]


