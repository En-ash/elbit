FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir flask
RUN apt-get update && apt-get install -y docker.io

COPY . .

EXPOSE 9090

CMD ["python3", "main.py"]