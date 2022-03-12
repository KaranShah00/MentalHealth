import os

from flask import Flask, request, jsonify
import werkzeug
from deepface import DeepFace
import text2emotion as te

app = Flask(__name__)

@app.route('/upload', methods=["POST"])
def upload():
    if request.method == "POST":
        message = "Image uploaded successfully"
        obj = None
        imagefile = request.files['image']
        filename = werkzeug.utils.secure_filename(imagefile.filename)
        imagepath = "./uploaded_images/" + filename
        imagefile.save(imagepath)
        try:
            obj = DeepFace.analyze(img_path=imagepath, actions=['emotion'], detector_backend = 'retinaface')
            print(obj)
        except: 
            message = "Image could not be analysed"
        os.remove(imagepath)    
        print(message)
        return jsonify({
            "message": message,
            "result": obj,
        })

@app.route('/text', methods=["POST"])
def text():
    text = request.form['message']
    # print(text)
    return jsonify(te.get_emotion(text))

@app.route('/')
def home():
    d = {"message": "Hello World"}
    # obj = DeepFace.analyze(img_path="C:/Users/Yash Shah/Desktop/Karan/Flutter Projects/flask_flutter/uploaded_images/angry4.jpeg", actions=['emotion'], detector_backend = 'retinaface')
    # print(obj)
    return jsonify(d)

if __name__ == "__main__":
    app.debug = True
    app.run(host="0.0.0.0")

