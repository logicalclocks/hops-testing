# Copyright 2016 Google Inc. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ==============================================================================

#!/usr/bin/env python2.7

"""A client that talks to tensorflow_model_server loaded with mnist model.

The client downloads test images of mnist data set, queries the service with
such test images to get predictions, and calculates the inference error rate.

Typical usage example:

    mnist_client.py --num_tests=100 --server=localhost:9000
"""

from __future__ import print_function

import sys
import threading
import thread

import json

# This is a placeholder for a Google-internal import.

import numpy
import requests
import tensorflow as tf

import time

import mnist_input_data

import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

tf.app.flags.DEFINE_integer('concurrency', 1,
                            'maximum number of concurrent inference requests')
tf.app.flags.DEFINE_integer('num_tests', 20, 'Number of test images')
tf.app.flags.DEFINE_string('server', '', 'PredictionService host:port')
tf.app.flags.DEFINE_string('work_dir', '/tmp', 'Working directory. ')
FLAGS = tf.app.flags.FLAGS


def do_inference(num_tests, token, test_data_set):
    """Tests PredictionService with concurrent requests.

    Args:
      hostport: Host:port address of the PredictionService.
      work_dir: The full path of working directory for test data set.
      num_tests: Number of test images to use.
      token: JWT token to authorize the request

    Raises:
      IOError: An error occurred processing test data set.
    """

    for _ in range(num_tests):
        image, label = test_data_set.next_batch(1)
        request_data = {}
        request_data['signature_name'] = 'predict_images'
        request_data['instances'] = image[0].reshape(1, image[0].size).tolist()

        r = requests.post("https://localhost:8181/hopsworks-api/api/project/2/inference/models/model:predict",
                          headers={'Authorization': token},
                          data=json.dumps(request_data),
                          verify=False)
        # print(r.text)

def main(_):
    #if FLAGS.num_tests > 10000:
    #  print('num_tests should not be greater than 10k')
    #  return
    #if not FLAGS.server:
    #  print('please specify server host:port')
    #  return
    #error_rate = do_inference(FLAGS.server, FLAGS.work_dir,
    #                          FLAGS.concurrency, FLAGS.num_tests)
    #print('\nInference error rate: %s%%' % (error_rate * 100))


    test_data = mnist_input_data.read_data_sets(FLAGS.work_dir).test

    credentials = {}
    credentials['email'] = "admin@hopsworks.ai"
    credentials['password'] = "admin"

    login_request = requests.post('https://localhost:8181/hopsworks-api/api/auth/login',
                                  data=credentials, verify=False)

    token = login_request.headers['Authorization']

    thread_requests = FLAGS.num_tests / FLAGS.concurrency
    threads = []

    start = time.time()

    for i in range(0, FLAGS.concurrency):
        thread = threading.Thread(target=do_inference,
            args=(thread_requests, token, test_data))
        thread.start()
        threads.append(thread)

    for t in threads:
        t.join()

    end = time.time()
    print("Time:", end-start)

if __name__ == '__main__':
    tf.app.run()

