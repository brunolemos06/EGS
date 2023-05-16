FROM python:3.10.6

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set the working directory inside the container
WORKDIR /payments

# Copy requirements file
COPY requirements.txt .

# Install dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

#Copy rest of payments app
COPY payments/ .

# Expose port (still to decide)
EXPOSE 8000

# Run django makemigrations
CMD ["python3", "manage.py", "makemigrations"]

# Run django migrate
CMD ["python3", "manage.py", "migrate"]

# Run django runserver
CMD ["python3", "manage.py", "runserver"] 
# can add 0.0.0.0:8000 to specify host and port