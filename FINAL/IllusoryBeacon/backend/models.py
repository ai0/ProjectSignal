from tortoise.models import Model
from tortoise import fields


class User(Model):
    id = fields.IntField(pk=True)
    email = fields.CharField(max_length=64, unique=True, index=True)
    password = fields.CharField(max_length=255)
    nickname = fields.CharField(max_length=16, unique=True, index=True)
    created_at = fields.DatetimeField(auto_now_add=True)


class Item(Model):
    id = fields.IntField(pk=True)
    geohash = fields.CharField(max_length=24, index=True)
    latitude = fields.FloatField()
    longitude = fields.FloatField()
    type = fields.CharField(max_length=24)
    content = fields.CharField(max_length=255)
    user = fields.ForeignKeyField("models.User")
    posted_at = fields.DatetimeField(auto_now_add=True)
