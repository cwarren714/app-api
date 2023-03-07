FROM python:3.9-alpine3.13
LABEL maintainer="chandlerwarren"

# this ensures python messages get sent directly to console instead of being stuck in delay
ENV PYTHONUNBUFFERED 1

# copy from local location => container location
# ignores anything in the dockerignore
# expose port 8000
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000

# run block instead of individual lines, more efficient building
# virtual env to store dependencies - avoid conflicts with base image
# upgrade python package manager
# install list of requirements inside venv
# remmove /tmp directories -- lightweight as possible
# new user inside image instead of root user -- good in case app gest compromised
# update PATH environment variable with /py/bin 
# USER line should be last, everything before run as root without permissions
# ARG below gets overwritten by docker-composer ARG when working locally -- handled with if statement below
ARG DEV=false
RUN python -m venv /py && \
    /py/bin/pip install --upgrade pip && \
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    rm -rf /tmp && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user
ENV PATH="/py/bin:$PATH"

USER django-user