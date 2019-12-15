from argparse import ArgumentParser
from tortoise.contrib.sanic import register_tortoise

from config import DB_CONFIG
from app import app
import views

if __name__ == '__main__':
    parser = ArgumentParser(description='Illusory Beacon Backend')
    parser.add_argument('--host', dest='host', type=str, default='0.0.0.0')
    parser.add_argument('--port', dest='port', type=int, default=8000)
    parser.add_argument('--workers', dest='workers', type=int, default=1)
    parser.add_argument('--debug', action="store_true")
    args = parser.parse_args()

    register_tortoise(
        app, config=DB_CONFIG, generate_schemas=True
    )

    app.run(host=args.host,
            port=args.port,
            workers=args.workers,
            debug=args.debug)
