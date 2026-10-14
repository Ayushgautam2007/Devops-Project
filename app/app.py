from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/", methods=["GET"])
def home():
    return jsonify({
        "message": "Welcome to DevOps CI/CD Project",
        "version": "v1"
    })


@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "healthy"
    }), 200


@app.route("/api/users", methods=["GET"])
def users():
    return jsonify({
        "users": [
            {"id": 1, "name": "Ayush"},
            {"id": 2, "name": "DevOps"}
        ]
    }), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
