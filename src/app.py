from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    return '<p>Hello, World!</p>'


if __name__ == '__main__':
    app.run(debug=True, ssl_context=('gencerts/server/server.pem', 'gencerts/server/server_private_key.pem'))