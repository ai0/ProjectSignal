from sanic import Sanic
from sanic_auth import Auth
from sanic_session import Session, InMemorySessionInterface

app = Sanic(__name__)
auth = Auth(app)
session = Session(app, interface=InMemorySessionInterface())
