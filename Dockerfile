# Install Python
FROM python:3-alpine

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

RUN apk update && \
    apk add openjdk8 && \
    apk add bash && \
    apk add curl && \
    apk add ruby && \
    apk add ruby-full

EXPOSE 25566 8080 8123

# Make volume for EFS to attach to
RUN mkdir -p /mnt/efs_data
RUN chown -R app_user:app_user /mnt/efs_data
VOLUME /mnt/efs_data

CMD ["bin/start_server.sh"]
