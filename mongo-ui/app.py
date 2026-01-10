#!/usr/bin/env python3
import os
import json
from flask import Flask, render_template, request, jsonify
from pymongo import MongoClient
from bson import ObjectId, json_util

app = Flask(__name__, template_folder='/templates')

def get_client():
    return MongoClient(os.environ.get('MONGO_URI', 'mongodb://mongo:27017'))

def json_response(data):
    return app.response_class(
        response=json_util.dumps(data),
        mimetype='application/json'
    )

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/databases')
def get_databases():
    try:
        client = get_client()
        dbs = client.list_database_names()
        return jsonify({'databases': dbs})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/database/<db>/collections')
def get_collections(db):
    try:
        client = get_client()
        collections = client[db].list_collection_names()
        return jsonify({'collections': collections})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/database/<db>/collection/<collection>')
def get_documents(db, collection):
    try:
        client = get_client()
        limit = int(request.args.get('limit', 50))
        skip = int(request.args.get('skip', 0))

        query = {}
        query_str = request.args.get('query')
        if query_str:
            query = json.loads(query_str)

        docs = list(client[db][collection].find(query).skip(skip).limit(limit))
        count = client[db][collection].count_documents(query)

        return json_response({'documents': docs, 'total': count})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/database/<db>/collection/<collection>/<doc_id>')
def get_document(db, collection, doc_id):
    try:
        client = get_client()
        doc = client[db][collection].find_one({'_id': ObjectId(doc_id)})
        return json_response({'document': doc})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/database/<db>/collection/<collection>', methods=['POST'])
def insert_document(db, collection):
    try:
        client = get_client()
        doc = request.json
        result = client[db][collection].insert_one(doc)
        return jsonify({'inserted_id': str(result.inserted_id)})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/database/<db>/collection/<collection>/<doc_id>', methods=['DELETE'])
def delete_document(db, collection, doc_id):
    try:
        client = get_client()
        client[db][collection].delete_one({'_id': ObjectId(doc_id)})
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/stats')
def get_stats():
    try:
        client = get_client()
        server_info = client.server_info()
        return jsonify({
            'version': server_info.get('version'),
            'databases': len(client.list_database_names())
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health():
    try:
        client = get_client()
        client.server_info()
        return 'OK'
    except:
        return 'UNHEALTHY', 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
