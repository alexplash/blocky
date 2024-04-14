from flask import Flask, request, jsonify
import gensim
import gensim.downloader as api
from gensim.models import KeyedVectors
import os
import numpy as np

app = Flask(__name__)

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
    if phrase in ftModel:
        return ftModel[phrase]
    words = phrase.split()
    word_vectors = []
    for word in words:
        if word in ftModel:
            word_vectors.append(ftModel[word])
        else:
            return np.zeros(ftModel.vector_size)
    if word_vectors:
        return np.mean(word_vectors, axis = 0)
    return np.zeros(ftModel.vector_size)

@app.route('/similarity', methods = ['POST'])
def calculate_similarity():
    data = request.get_json()
    word1 = data.get('word1')
    word2 = data.get('word2')
    if not word1 or not word2:
        return jsonify({'error': 'Missing words'}), 400
    v1 = vectorize(word1)
    v2 = vectorize(word2)
    similarity = ftModel.cosine_similarities(v1, [v2])[0]
    similarity = float(similarity)
    return jsonify({'similarity': similarity})

if __name__ == '__main__':
    app.run(debug=True)