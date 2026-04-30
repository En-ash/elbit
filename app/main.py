import subprocess, json
import logging
from logging.handlers import RotatingFileHandler
from flask import Flask, render_template, request

#region Logging Configuration
def setup_logging():
    """Configure application logging with file and console handlers."""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s %(levelname)s: %(message)s',
        handlers=[
            RotatingFileHandler('app.log', maxBytes=10_000_000, backupCount=3),
            logging.StreamHandler()
        ]
    )
    return logging.getLogger(__name__)

logger = setup_logging()
#endregion

#region Get Docker Containers
def get_docker_containers():
    try:
        result = subprocess.run(
            ['docker', 'ps', '--format', '{{.ID}} {{.Names}}'],
            capture_output=True, text=True, timeout=10
        )
        if result.returncode != 0:
            logger.error(f"Docker command failed: {result.stderr}")
            return []

        containers = []
        for line in result.stdout.strip().split('\n'):
            if line:
                container_id, name = line.split(maxsplit=1)
                containers.append({'id': container_id, 'name': name})

        logger.info(f"Retrieved {len(containers)} containers")
        return containers

    except subprocess.TimeoutExpired:
        error = "Docker command timed out after 10 seconds"
        logger.error(error)
        return error
    except FileNotFoundError:
        error = "Docker command not found - Docker may not be installed"
        logger.error(error)
        return error
    except Exception as e:
        error = f"Unexpected error getting containers: {e}"
        logger.exception(error)
        return e
#endregion

#region Routing

app = Flask(__name__)

# Request logging middleware
@app.before_request
def log_request():
    logger.info(f"Request: {request.method} {request.path} - IP: {request.remote_addr}")

@app.route("/")
def index():
    logger.debug("Index endpoint called")
    result = get_docker_containers()
    
    if isinstance(result, str):
        return {"error": result}, 500
    elif isinstance(result, Exception):
        return {"error": str(result)}, 500
    
    js = json.dumps(result)
    return js

#endregion

#region Error Handlers

@app.errorhandler(404)
def not_found(e):
    logger.warning(f"404 error: {request.url}")
    return {"error": "Not found"}, 404

@app.errorhandler(500)
def server_error(e):
    logger.error(f"500 error: {str(e)}")
    return {"error": "Internal server error"}, 500

#endregion

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=9090)