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

CMD ["bin/start_server.sh"]
