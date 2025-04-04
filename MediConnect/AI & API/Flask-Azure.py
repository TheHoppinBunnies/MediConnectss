#!/usr/bin/env python
# coding: utf-8

import json
import logging
import os
import sys
import time
import uuid
from flask import Flask, request, jsonify
from flask_cors import CORS
import requests
import threading

# Configure logging
logging.basicConfig(stream=sys.stdout, level=logging.INFO,
                    format="[%(asctime)s] %(message)s", datefmt="%m/%d/%Y %I:%M:%S %p %Z")
logger = logging.getLogger(__name__)

# Create Flask app
app = Flask(__name__)
CORS(app)  # Enable Cross-Origin Resource Sharing

# Configuration
SPEECH_ENDPOINT = os.getenv('SPEECH_ENDPOINT', "https://eastus2.api.cognitive.microsoft.com")
SUBSCRIPTION_KEY = os.getenv("SUBSCRIPTION_KEY", 'd875f948f1234f0cbb710d2b13736d59')
API_VERSION = "2024-04-15-preview"
PASSWORDLESS_AUTHENTICATION = False

# Store job status information
jobs_status = {}


def _create_job_id():
    # Create a unique job ID
    return str(uuid.uuid4())


def _authenticate():
    # if PASSWORDLESS_AUTHENTICATION:
    #     # Add your passwordless authentication implementation here
    #     # This is placeholder code
    #     from azure.identity import DefaultAzureCredential
    #     credential = DefaultAzureCredential()
    #     token = credential.get_token('https://cognitiveservices.azure.com/.default')
    #     return {'Authorization': f'Bearer {token.token}'}
    # else:
    return {'Ocp-Apim-Subscription-Key': SUBSCRIPTION_KEY}


def submit_synthesis(job_id, text_content, voice="en-US-AndrewMultilingualNeural",
                     avatar_character="Lisa", avatar_style="casual-sitting"):
    url = f'{SPEECH_ENDPOINT}/avatar/batchsyntheses/{job_id}?api-version={API_VERSION}'
    header = {
        'Content-Type': 'application/json'
    }
    header.update(_authenticate())
    isCustomized = False

    payload = {
        'synthesisConfig': {
            "voice": voice,
        },
        "customVoices": {},
        "inputKind": "plainText",
        "inputs": [
            {
                "content": text_content,
            },
        ],
        "avatarConfig": {
            "customized": isCustomized,
            "talkingAvatarCharacter": avatar_character,
            "talkingAvatarStyle": avatar_style,
            "videoFormat": "mp4",
            "videoCodec": "h264",
            "subtitleType": "soft_embedded",
            "backgroundColor": "#FFFFFFFF",
        }
    }

    response = requests.put(url, json.dumps(payload), headers=header)
    if response.status_code < 400:
        logger.info('Batch avatar synthesis job submitted successfully')
        logger.info(f'Job ID: {response.json()["id"]}')
        return True, response.json()
    else:
        logger.error(f'Failed to submit batch avatar synthesis job: [{response.status_code}], {response.text}')
        return False, {"error": response.text}


def get_synthesis_status(job_id):
    url = f'{SPEECH_ENDPOINT}/avatar/batchsyntheses/{job_id}?api-version={API_VERSION}'
    header = _authenticate()

    response = requests.get(url, headers=header)
    if response.status_code < 400:
        logger.debug('Get batch synthesis job successfully')
        logger.debug(response.json())
        result = response.json()
        return True, result
    else:
        logger.error(f'Failed to get batch synthesis job: {response.text}')
        return False, {"error": response.text}


def monitor_job(job_id):
    """Monitor job status in background thread"""
    while True:
        success, result = get_synthesis_status(job_id)

        if not success:
            jobs_status[job_id] = {"status": "Error", "error": result.get("error", "Unknown error")}
            break

        status = result.get("status")
        jobs_status[job_id] = result

        if status == "Succeeded" or status == "Failed":
            logger.info(f"Job {job_id} finished with status {status}")
            break

        # Wait before checking again
        time.sleep(5)


# API Routes

@app.route('/api/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "healthy"})


@app.route('/api/submit', methods=['POST'])
def submit_job():
    """Submit a new synthesis job"""
    data = request.json

    # Get parameters from request or use defaults
    text_content = data.get('text', "Hi, I'm a virtual assistant created by Microsoft.")
    voice = data.get('voice', "en-US-AndrewMultilingualNeural")
    avatar_character = data.get('character', "Lisa")
    avatar_style = data.get('style', "casual-sitting")

    # Create a new job ID
    job_id = _create_job_id()

    # Submit the job
    success, result = submit_synthesis(job_id, text_content, voice, avatar_character, avatar_style)

    if success:
        # Store initial job status
        jobs_status[job_id] = {"status": "Running", "id": job_id}

        # Start monitoring thread
        thread = threading.Thread(target=monitor_job, args=(job_id,))
        thread.daemon = True
        thread.start()

        return jsonify({
            "success": True,
            "job_id": job_id
        })
    else:
        return jsonify({
            "success": False,
            "error": result.get("error", "Unknown error")
        }), 500


@app.route('/api/status/<job_id>', methods=['GET'])
def check_status(job_id):
    """Check the status of a job"""
    # First check our local cache
    if job_id in jobs_status:
        # If status is not final, get fresh status from API
        cached_status = jobs_status[job_id].get("status")
        if cached_status not in ["Succeeded", "Failed", "Error"]:
            success, result = get_synthesis_status(job_id)
            if success:
                jobs_status[job_id] = result
                return jsonify(result)
            else:
                return jsonify(result), 500
        else:
            return jsonify(jobs_status[job_id])
    else:
        # If not in cache, check directly
        success, result = get_synthesis_status(job_id)
        if success:
            jobs_status[job_id] = result
            return jsonify(result)
        else:
            return jsonify(result), 500


@app.route('/api/jobs', methods=['GET'])
def list_jobs():
    """List all known jobs"""
    return jsonify({"jobs": list(jobs_status.keys())})


if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=True)