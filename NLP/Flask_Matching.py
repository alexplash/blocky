from flask import Flask, request, jsonify
from flask_cors import CORS
import gensim.downloader as api
from gensim.models import KeyedVectors
import os
import numpy as np
from gradio_client import Client

app = Flask(__name__)
CORS(app)

Model_Path = 'VSModel_Cache/fasttext-wiki-news-subwords-300.model'

def load_model():
    model_dir = 'VSModel_Cache'
    model_path = os.path.join(model_dir, 'fasttext-wiki-news-subwords-300.model')
    
    if not os.path.exists(model_dir):
        os.makedirs(model_dir)
        print("Created directory: ", model_dir)
    
    if os.path.exists(model_path):
        model = KeyedVectors.load(model_path)
        print("Model loaded from disk.")
    else:
        model = api.load("fasttext-wiki-news-subwords-300")
        model.save(model_path)
        print("Model downloaded and saved to disk.")
    return model

ftModel = load_model()

def vectorize(phrase):
    words = phrase.split()
    word_vectors = [ftModel[word] for word in words if word in ftModel]
    if not word_vectors:
        return None
    return np.mean(word_vectors, axis=0)

hf_client = Client("alexplash/blockymatchingSpace")

@app.route('/similarity', methods = ['POST'])
def calculate_similarity():
    data = request.get_json()
    word1 = data.get('word1')
    word2 = data.get('word2')
    if not word1 or not word2:
        return jsonify({'error': 'Missing words'}), 400
    v1 = vectorize(word1)
    v2 = vectorize(word2)
    if v1 is None or v2 is None:
        return jsonify({'similarity': 0})
    similarity = float(ftModel.cosine_similarities(v1, [v2])[0])
    return jsonify({'similarity': similarity})

@app.route('/categorize', methods = ['POST'])
def categorize():
    data = request.get_json()
    if 'input' not in data:
        return jsonify({'error': 'No input provided'}), 400
    
    try:
        result = hf_client.predict(
            input=data['input'],
            api_name="/predict"
        )
        return jsonify({'result': result})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True)