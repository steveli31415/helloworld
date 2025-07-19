from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_world():
    return 'Hello, AWS! Version 0.0.1'

@app.route('/time')
def get_time():
    return {'time': datetime.now().isoformat()}

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
