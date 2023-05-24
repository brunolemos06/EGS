# Use an official Python runtime as the base image
FROM python:3.7.3-slim

# Set the working directory in the container
WORKDIR /review

# Copy the requirements file to the container
COPY requirements.txt .

# Install the Python dependencies
RUN pip3 install --no-cache-dir -r requirements.txt

# Copy the Flask app code to the container
COPY . .

# Expose port 5005 to the outside world
EXPOSE 5005

# Create tables on database
CMD ["python3", "create_db.py"]
# Run the Flask application
CMD ["python3", "main.py"]