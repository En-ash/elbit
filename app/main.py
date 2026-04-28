import subprocess, json

# Execute docker ps and capture output
def get_docker_containers():
    result = subprocess.run(
        ['docker', 'ps', '--format', '{{.ID}} {{.Names}}'],
        capture_output=True, text=True
    )

    containers = []
    for line in result.stdout.strip().split('\n'):
        if line:
            container_id, name = line.split(maxsplit=1)
            containers.append({'id': container_id, 'name': name})

    return containers



from flask import Flask, render_template, request


app = Flask(__name__)

@app.route("/")
def index():

    #return render_template("index.html", containers = get_docker_containers())
    js = json.dumps(get_docker_containers())
    print(js)
    return js


if __name__ == "__main__":
    app.run(host='0.0.0.0', port=9090)