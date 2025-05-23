# Use the official lightweight Python 3.9 image based on Alpine Linux 3.13
FROM python:3.9-alpine3.13

# Set a label to identify the image maintainer
LABEL maintainer="khanjee501"

# Ensures that Python output is sent straight to the terminal (helpful for logging in Docker)
ENV PYTHONUNBUFFERED 1

# Copy the requirements.txt and requirements.dev.txt file into the temporary directory in the image
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt

# Copy the Django application code from the host into the /app directory in the image
COPY ./app /app

# Set the working directory inside the container to /app
WORKDIR /app

# Expose port 8000 (used by Django’s development server)
EXPOSE 8000

# Create a virtual environment in /py,
# upgrade pip,
# install Python dependencies from requirements.txt,
# then clean up the temp files,
# and finally create a new system user called django-user without a home directory or password
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = 'true' ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

# Add the virtual environment’s bin directory to PATH
# This ensures Python and pip inside the venv are the default commands
ENV PATH="/py/bin:$PATH"

# Switch to the newly created non-root user for better security
USER django-user