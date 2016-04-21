WSGI Benchmarks
===============

Introduction
------------

The current setup is based on a quad core machine:

  * 2 cores are dedicated to docker / WSGI server
  * 2 cores are dedicated to web server stress tester

Pull requests are welcome!

Steps to reproduce benchmarks
-----------------------------

### 1. Install docker ###

Please consult instructions for your distro

### 2. Run benchmark.sh ###

Run benchmark.sh as a user that has docker permissions (it will automatically create the image), passing in directories to store results

    for directory in round*; do
        ./benchmark.sh $directory
    done

### 3. Run results.py ###

Results.py will parse the results, producing a CSV file. Pass in the directories used in the previous step

    ./results.py round* > results.csv
