# Install Python
FROM python:3-alpine

COPY . .

EXPOSE 25566 8080 8123

RUN pip install --no-cache-dir -r requirements.txt && \
    apk update && \
    apk add nfs-utils && \
    apk add openjdk8 && \
    apk add bash && \
    apk add curl && \
    apk add ruby && \
    apk add ruby-full

CMD ["bin/start_server.sh"]
