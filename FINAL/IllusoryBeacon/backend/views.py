import hashlib
import uuid
from pathlib import Path
from ujson import loads as json_loads
from ujson import dumps as json_dumps
from sanic.response import json, file
from email_validator import validate_email, EmailNotValidError
from tortoise.query_utils import Q
from tortoise.exceptions import DoesNotExist
import geohash2

from app import app, auth
from models import User, Item


# Utilities

def handle_no_auth(request):
    return json(dict(message='unauthorized'), status=401)


def sha256(plaintext):
    return hashlib.sha256(plaintext.encode('utf-8')).hexdigest()


def generate_uuid():
    return hashlib.md5(uuid.uuid1().bytes).hexdigest()


def get_image_path(image_uuid):
    return f'/var/data/images/{image_uuid}.jpg'


def check_image_existed(image_uuid):
    return Path(get_image_path(image_uuid)).is_file()


# Auth


@auth.serializer
def serializer(user):
    return {'uid': user.id, 'name': user.nickname}


@auth.user_loader
def load_user(token):
    if token is not None:
        return User.get(id=token['uid'])

# Views


@app.route("/")
async def welcome(request):
    return json({"msg": "Welcome to Illusory Beacon!"})


@app.route("/user/signup", methods=["POST"])
async def sign_up(request):
    data = request.json
    try:
        assert 'email' in data
        assert 'password' in data
        assert 'nickname' in data
    except AssertionError:
        return json({"error": "Empty field"})

    try:
        email = validate_email(data['email'])
        data['email'] = email["email"]  # replace with normalized form
    except EmailNotValidError as e:
        return json({"error": "Email illegal"})

    try:
        await User.get(email=data['email'])
        return json({"error": "Email already existed"})
    except DoesNotExist:
        pass

    try:
        await User.get(nickname=data['nickname'])
        return json({"error": "Nickname already used"})
    except DoesNotExist:
        pass

    data['password'] = sha256(data['password'])
    try:
        user = await User.create(**data)
        auth.login_user(request, user)
        return json({"id": user.id})
    except Exception:
        return json({"error": "Request data too long"})


@app.route("/user/login", methods=["POST"])
async def login(request):
    data = request.json
    try:
        assert 'email' in data
        assert 'password' in data
    except AssertionError:
        return json({"error": "Empty field"})

    try:
        user = await User.get(email=data['email'])
    except DoesNotExist:
        return json({"error": "User not existed"})

    if sha256(data['password']) != user.password:
        return json({"error": "Password mismatch"})
    auth.login_user(request, user)
    return json({"id": user.id})


@app.route("/user/logout")
@auth.login_required(handle_no_auth=handle_no_auth)
async def logout(request):
    auth.logout_user(request)
    return json({})


@app.route("/user/checkin")
@auth.login_required(handle_no_auth=handle_no_auth)
async def checkin(request):
    return json({})


@app.route("/user/status")
@auth.login_required(user_keyword='user', handle_no_auth=handle_no_auth)
async def user_status(request, user):
    post_images = await Item.filter(Q(user=user) & Q(type='image')).count()
    post_texts = await Item.filter(Q(user=user) & Q(type='text')).count()
    return json(dict(id=user.id, nickname=user.nickname, email=user.email, post_images=post_images, post_texts=post_texts))


@app.route("/item/new", methods=["POST"])
@auth.login_required(user_keyword='user', handle_no_auth=handle_no_auth)
async def post_item(request, user):
    data = request.json
    try:
        assert 'latitude' in data
        assert 'longitude' in data
        assert 'type' in data
        assert data['type'] in ('text', 'image')
        assert 'content' in data
    except AssertionError:
        return json({"error": "Empty field"})

    data['content'] = data['content'].strip()
    data['geohash'] = geohash2.encode(
        data['latitude'], data['longitude'], precision=7)
    if data['type'] == 'image' and not check_image_existed(data['content']):
        return json({"error": "Image not existed"})
    data['user'] = user
    try:
        item = await Item.create(**data)
        return json({"id": item.id, "type": item.type, "content": item.content})
    except Exception:
        return json({"error": "Abnormal data"})


@app.route("/image/new", methods=["POST"])
@auth.login_required(handle_no_auth=handle_no_auth)
def upload_image(request):
    image = request.files.get('image')
    if image is None:
        return json({"error": "Empty field"})
    image_uuid = generate_uuid()
    with open(get_image_path(image_uuid), 'wb') as f:
        f.write(image.body)
    return json({"id": image_uuid})


@app.route("/image/<image_uuid>")
async def image(request, image_uuid):
    image_path = get_image_path(image_uuid)
    if not check_image_existed(image_uuid):
        return json({"error": "Image not existed"}, status=404)
    return await file(image_path, headers={'Content-Type': 'image/jpeg'})


# WebSocket


@app.websocket('/beacons')
async def beacons(request, ws):
    while True:
        data = await ws.recv()
        try:
            data = json_loads(data)
            assert 'latitude' in data
            assert 'longitude' in data
        except Exception:
            await ws.send(json_dumps({"error": "Illegal data"}))
            continue
        data['latitude'] = round(float(data['latitude']), 6)
        data['longitude'] = round(float(data['longitude']), 6)
        limit = data.get('limit', 10)
        geohash = geohash2.encode(
            data['latitude'], data['longitude'], precision=7)
        beacons = await Item.filter(geohash=geohash).limit(limit)
        beacons_data = [
            dict(id=beacon.id, type=beacon.type, content=beacon.content)
            for beacon in beacons
        ]
        print(beacons_data)
        await ws.send(json_dumps(beacons_data))
