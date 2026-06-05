from google import genai
from flask import Flask, request, jsonify
from flask_cors import CORS
from flask_sqlalchemy import SQLAlchemy
import requests
from time import time
last_call ={}
@app.before_request
def limit_requests():
    ip=request.remote_addr
    now = time()
    if ip in last_call and now-last_call[ip]<3:
        return jsonify({"error":"Too many requests,slow down!"}),429
    last_call[ip]=now
app = Flask(__name__)
CORS(app)
client = genai.Client(
    api_key="AIzaSyDneYlLWlUSZiiNasjwRM_lcE-gfNiNEFE"
)


app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///trips.db'

db = SQLAlchemy(app)


class Trip(db.Model):

    id = db.Column(db.Integer, primary_key=True)

    city = db.Column(db.String(100))

    transport = db.Column(db.String(50))

    wallet = db.Column(db.Boolean)

    charger = db.Column(db.Boolean)
    identity_card = db.Column(db.Boolean)
    medications= db.Column(db.Boolean)
    toiletries = db.Column(db.Boolean)
    cash = db.Column(db.Boolean)


@app.route('/add_trip', methods=["POST"])
def add_trip():
    try:
        data = request.get_json(force=True)

        print("GOT REQUEST:", data)

        new_trip = Trip(

            city=data['city'],
            transport=data['transport'],
            wallet=data['wallet'],
            charger=data['charger'],
            identity_card=data['identity_card'],
            medications=data['medications'],
            toiletries=data['toiletries'],
            cash=data['cash']

         )

        db.session.add(new_trip)

        db.session.commit()

        return jsonify({
        "message": "Trip saved successfully"
    })
    except Exception as e:
        print("ADD_TRIP ERROR:",e)
        return jsonify({"error":str(e)}),500


@app.route('/get_trips', methods=["GET"])
def get_trips():

    trips = Trip.query.all()

    all_trips = []

    for trip in trips:

        all_trips.append({

            "city": trip.city,
            "transport": trip.transport,
            "wallet": trip.wallet,
            "charger": trip.charger,
            "identity_card":trip.identity_card,
            "medications":trip.medications,
            "toiletries":trip.toiletries,
            "cash":trip.cash
        })

    return jsonify(all_trips)

@app.route('/weather/<city>', methods=["GET"])
def get_weather(city):

    api_key ="80dea22a6348146caa79df3ae54d41a1"

    url = f"https://api.openweathermap.org/data/2.5/weather?q={city}&appid={api_key}&units=metric"

    response = requests.get(url)

    data = response.json()

    print(data)
    print(url)
    print("CITY Received:",city)
    if 'main' not in data:

        return jsonify({
            "error": "Weather data not found",
            "response": data
        })

    return jsonify({

        "temperature": data['main']['temp'],

        "description": data['weather'][0]['description']

    })
@app.route('/ask_ai', methods=["POST"])
def ask_ai():
    try:
        data = request.get_json()

        if not data or 'question' not in data:
            return jsonify({"error": "Question is required"}), 400

        user_question = data['question']
        travel_prompt = f""" You are a smart Travel Assistant AI.
        User question: {user_question}
        Give helpful travel-related answers including places,tips,and suggestions.
        """
        response = client.models.generate_content(
            model="gemini-2.5-flash",
            contents=travel_prompt
        )
        print("FULL RESPONSE:", response)
        reply=None
        try:
            reply = response.text
        except:
            reply = None
        if not reply and response.candidates:
            reply = response.candidates[0].content.parts[0].text
        if not reply:
            reply = "Sorry, I couldn't generate a response right now."
        

        return jsonify({"reply": reply})

    except Exception as e:
        print("GEMINI ERROR:", str(e))
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':

    with app.app_context():
        db.create_all()

    app.run(host="0.0.0.0",
           port=10000,
           debug=True
           )