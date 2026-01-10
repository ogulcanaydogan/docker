#!/usr/bin/env python3
import os
import json
from flask import Flask, render_template, request, jsonify
import redis

app = Flask(__name__, template_folder='/templates')

def get_redis():
    return redis.Redis(
        host=os.environ.get('REDIS_HOST', 'redis'),
        port=int(os.environ.get('REDIS_PORT', 6379)),
        password=os.environ.get('REDIS_PASSWORD') or None,
        decode_responses=True
    )

@app.route('/')
def index():
    return render_template('index.html')

@app.route('/api/keys')
def get_keys():
    try:
        r = get_redis()
        pattern = request.args.get('pattern', '*')
        keys = r.keys(pattern)[:100]  # Limit to 100 keys
        return jsonify({'keys': keys})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/key/<path:key>')
def get_key(key):
    try:
        r = get_redis()
        key_type = r.type(key)
        ttl = r.ttl(key)

        if key_type == 'string':
            value = r.get(key)
        elif key_type == 'list':
            value = r.lrange(key, 0, -1)
        elif key_type == 'set':
            value = list(r.smembers(key))
        elif key_type == 'hash':
            value = r.hgetall(key)
        elif key_type == 'zset':
            value = r.zrange(key, 0, -1, withscores=True)
        else:
            value = None

        return jsonify({
            'key': key,
            'type': key_type,
            'value': value,
            'ttl': ttl
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/key/<path:key>', methods=['DELETE'])
def delete_key(key):
    try:
        r = get_redis()
        r.delete(key)
        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/key', methods=['POST'])
def set_key():
    try:
        r = get_redis()
        data = request.json
        key = data.get('key')
        value = data.get('value')
        ttl = data.get('ttl')

        r.set(key, value)
        if ttl and int(ttl) > 0:
            r.expire(key, int(ttl))

        return jsonify({'success': True})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/info')
def get_info():
    try:
        r = get_redis()
        info = r.info()
        return jsonify({
            'version': info.get('redis_version'),
            'connected_clients': info.get('connected_clients'),
            'used_memory_human': info.get('used_memory_human'),
            'total_keys': r.dbsize()
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/health')
def health():
    try:
        r = get_redis()
        r.ping()
        return 'OK'
    except:
        return 'UNHEALTHY', 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8080))
    app.run(host='0.0.0.0', port=port)
