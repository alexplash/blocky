from flask import Flask, request, jsonify
from flask_cors import CORS
import gensim.downloader as api
from gensim.models import KeyedVectors
import os
from dotenv import load_dotenv
import numpy as np
from gradio_client import Client
import google.generativeai as genai

load_dotenv()

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

os.environ['GOOGLE_API_KEY'] = os.getenv('GOOGLE_API_KEY')
genai.configure(api_key=os.environ['GOOGLE_API_KEY'])
model = genai.GenerativeModel(model_name="gemini-pro")

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
    
@app.route("/firstchat", methods=['POST'])
def chat1():
    data = request.get_json()
    providerName = data.get('username')
    dataType = data.get('dataType')
    dataUnit = data.get('dataUnit')
    dataPrice = data.get('dataPrice')
    license = data.get('license')
    discount = data.get('discount')
    contactInfo = data.get('contactInfo')

    first_prompt = [
        f"You are a secretary, representing {providerName}. He/She is a data provider, who is attempting to sell his/her unique data to a me, a data seeker. Your job is to use the {providerName}'s configurations, and explain them clearly and professionally to me."
        f"Here are the Data Provider's configurations: This is how he/she describes his/her expertise and data niche: '{dataType}'. This is how he/she defines what a single unit of his/her data is: '{dataUnit}'. This is how he/she defines the price, in ETH, that he/she charges for each unit of his/her data: '{dataPrice}'. This is the ownership license he/she have specified for any sale of his/her data: '{license}'. This is the potential discount opportunity he/she have defined for Data Seekers: '{discount}'. This is the contact information that he/she have chosen to share: '{contactInfo}'. If there is not explicit discount or contact info provided, then dont even mention them in your description to me."
        "Now, using these configurations that the Data Provider has set, act as his/her secretary. Clearly and professionally explain to me all of what the Data Provider has specified here. Fit this all into one paragraph, and don't title this anything. Just go straight into the description. Refer to the data provider using his/her name."
    ]
    first_response = model.generate_content(first_prompt)
    return jsonify({"response": first_response.text})

@app.route("/secondchat", methods=['POST'])
def chat2():
    data = request.get_json()
    providerName = data.get('username')
    firstResponse = data.get('firstResponse')
    answer1 = data.get('answer1')
    answer2 = data.get('answer2')

    second_prompt = [
        f"You are a secretary, representing {providerName}. He/She is a data provider, who is attempting to sell his/her unique data to a me, a data seeker."
        f"This is how you, the secretary, have already described {providerName}'s specifications and data to me, the Data Seeker: {firstResponse}."
        f"You then asked me this first follow up question: 'Describe clearly exactly what data you need from {providerName}'. I answered this question with this answer: {answer1}."
        f"You then asked me this second follow up question: 'How many units of ${providerName}'s data would you like? Make sure to use their unit definition'. I answered this question with this answer: {answer2}."
        f"Now, using my description of {providerName}'s specifications, as well as my answers to your follow up questions, draft up a solidity smart contract for the ETH main net. Be very thourough and careful in the definition of this contract. Pay close attention to whether or not {providerName} has offered any discount on their data unit price. If my answers to your follow up questions meet the discount requirements that {providerName} has set, then let make sure to use the discount price rather than the standard price when creating the contract."
    ]
    second_response = model.generate_content(second_prompt)
    return jsonify({"Contract": second_response.text})

if __name__ == '__main__':
    app.run(debug=True)