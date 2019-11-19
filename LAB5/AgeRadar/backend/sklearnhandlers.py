#!/usr/bin/python

from pymongo import MongoClient
import tornado.web

from tornado.web import HTTPError
from tornado.httpserver import HTTPServer
from tornado.ioloop import IOLoop
from tornado.options import define, options

from basehandler import BaseHandler

from sklearn.neighbors import KNeighborsClassifier
from sklearn import svm
import pickle
import threading
from bson.binary import Binary
import json
import numpy as np
import cv2
import hashlib


def update_model(user, algorithm, neighbors, f, l, db, model_cache):
    if algorithm == 'KNN':
        model = KNeighborsClassifier(n_neighbors=neighbors)
    elif algorithm == 'SVM':
        model = svm.SVC()
    else:
        return
    try:
        model.fit(f, l)
    except Exception:
        return
    model_bytes = pickle.dumps(model)
    db.models.update(
        {
            "user": user
        }, {"$set": {
            "model": Binary(model_bytes)
        }},
        upsert=True)
    model_cache[user] = model


class PrintHandlers(BaseHandler):

    @tornado.web.authenticated
    def get(self):
        '''Write out to screen the handlers used
        This is a nice debugging example!
        '''
        self.set_header("Content-Type", "application/json")
        self.write(self.application.handlers_string.replace('),', '),\n'))


class UploadLabeledDatapointHandler(BaseHandler):

    @tornado.web.authenticated
    def post(self):
        '''Save data point and class label to database
        '''
        fileinfo = self.request.files['image'][0]
        user = self.get_current_user()

        label = self.get_body_argument("label", default=None, strip=True)
        image = fileinfo['body']
        nparr = np.frombuffer(image, np.uint8)
        img_np = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        img_feature = [float(f) for f in cv2.resize(img_np, (32, 32)).flatten()]

        dbid = self.db.labeledinstances.insert({
            "feature": img_feature,
            "label": label,
            "user": user
        })
        self.write_json({
            "id": str(dbid),
            "label": label
        })


class UpdateModelForUser(BaseHandler):

    @tornado.web.authenticated
    def post(self):
        data = tornado.escape.json_decode(self.request.body)
        user = self.get_current_user()

        algorithm = data.get('algorithm', 'KNN')
        neighbors = int(data.get('neighbors', 1))

        features = []
        labels = []
        for inst in self.db.labeledinstances.find({"user": user}):
            features.append(inst['feature'])
            labels.append(inst['label'])

        t = threading.Thread(
            target=update_model,
            args=[user, algorithm, neighbors, features, labels, self.db, self.model_cache])
        t.daemon = True
        t.start()

        self.write_json({"status": "OK"})


class PredictOne(BaseHandler):

    @tornado.web.authenticated
    def post(self):
        '''Predict the class of a sent feature vector
        '''
        fileinfo = self.request.files['image'][0]
        user = self.get_current_user()

        image = fileinfo['body']
        nparr = np.frombuffer(image, np.uint8)
        img_np = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        img_feature = cv2.resize(img_np, (32, 32)).flatten().reshape(1, -1)

        if user not in self.model_cache.keys():
            tmp = self.db.models.find_one({"user": user})
            if tmp:
                self.model_cache[user] = pickle.loads(tmp['model'])
            else:
                raise tornado.web.HTTPError(406)
        predLabel = self.model_cache[user].predict(img_feature)[0]
        self.write_json({"prediction": str(predLabel)})


class SignupHandler(BaseHandler):

    def post(self):
        data = json.loads(self.request.body.decode("utf-8"))
        usr = data.get('username')
        pwd = data.get('password')
        try:
            assert usr
            assert pwd
            is_existed = self.db.users.find_one({"username": usr})
            assert is_existed is None
        except AssertionError:
            raise tornado.web.HTTPError(400)

        dbid = self.db.users.insert({
            "username": usr,
            "password": hashlib.sha256(pwd.encode('utf-8')).hexdigest()
        })
        self.set_secure_cookie("user", usr)
        self.write_json({"user_id": str(dbid)})


class LoginHandler(BaseHandler):

    def get(self):
        raise tornado.web.HTTPError(403)

    def post(self):
        data = json.loads(self.request.body.decode("utf-8"))
        usr = data.get('username')
        pwd = data.get('password')
        try:
            assert usr
            assert pwd
            user_found = self.db.users.find_one({"username": usr})
            assert user_found
            pwd_hash = hashlib.sha256(pwd.encode('utf-8')).hexdigest()
            assert user_found.get('password') == pwd_hash
        except AssertionError:
            raise tornado.web.HTTPError(403)

        self.set_secure_cookie("user", usr)
        self.write_json({"user_id": str(user_found['_id'])})


class LogoutHandler(BaseHandler):

    def get(self):
        self.clear_cookie("user")
