#!/usr/bin/env python2

from __future__ import print_function
import re
import os
import sys
import glob
import pprint

from collections import defaultdict

class Results(object):
    def __init__(self):
        self.LATENCIES = defaultdict(dict)
        self.ERRORS = defaultdict(dict)
        self.REQUESTS = defaultdict(lambda: defaultdict(int))
        self.MEMORY = defaultdict(lambda: defaultdict(int))
        self.CPU = defaultdict(lambda: defaultdict(int))

class Parser(object):

    RESULTS = defaultdict(Results)
    DIGITS_RE = re.compile(r'\d+')
    LATENCY_RE = re.compile(r'([\d\.]+)(\w+)')
    LATENCY_MULTIPLIERS = {
        'us': 0.001,
        'ms': 1.0,
        's': 1000.0
    }

    def process(self, directory):
        for fileName in sorted(os.listdir(directory)):
            with open(os.path.join(directory, fileName), 'r') as f:
                parts = self._fileHandler(fileName)
                if parts['type'] == 'log':
                    self._logHandler(directory, parts['server'], parts['connections'], f)
                elif parts['type'] == 'stats':
                    self._statsHandler(directory, parts['server'], parts['connections'], f)
                else:
                    raise ValueError('Unknown type: %s' % parts['type'])

    def _fileHandler(self, fileName):
        parts = fileName.split('.')
        return {
            'server': parts[0],
            'connections': int(parts[1]),
            'type': parts[2]
        }

    def _logHandler(self, directory, server, connections, content):
        for line in content:
            parts = [ part for part in line.split(' ') if part ]
            if parts[0] == 'Latency':
                digits, unit = self.LATENCY_RE.match(parts[1]).groups()
                self.RESULTS[directory].LATENCIES[server][connections] = float(digits) * self.LATENCY_MULTIPLIERS[unit]
            elif 'Requests' in parts[0]:
                self.RESULTS[directory].REQUESTS[server][connections] = float(parts[1])
            elif 'Socket' == parts[0]:
                self.RESULTS[directory].ERRORS[server][connections] = sum(
                    int(i) for i in self.DIGITS_RE.findall(line)
                )

    def _statsHandler(self, directory, server, connections, content):
        for line in content:
            parts = [ part for part in line.split(' ') if part ]
            if 'CONTAINER' not in parts[0]:
                cpu = float(parts[1].rstrip('%'))
                memory = float(parts[2])
                if cpu > self.RESULTS[directory].CPU[server][connections]:
                    self.RESULTS[directory].CPU[server][connections] = cpu
                if memory > self.RESULTS[directory].MEMORY[server][connections]:
                    self.RESULTS[directory].MEMORY[server][connections] = memory

class Output(object):

    def analyze(self, results):

        self._servers = sorted(
            results.itervalues().next().REQUESTS.iterkeys()
        )
        self._counts = sorted(
            results.itervalues().next().REQUESTS.itervalues().next().keys()
        )
        self._header = self._csv(['server'] + self._counts)

        self._requests(results)
        self._latency(results)
        self._cpu(results)
        self._memory(results)
        self._errors(results)

    def _csv(self, row):
        return ','.join(str(cell) for cell in row)

    def _best(self, data, metric, server, count):
        # Sort the vaules, removing the extremes
        values = sorted(
            getattr(data[directory], metric)[server].get(count, 0)
            for directory in data
        )[1:-1]

        # Average the remaining values
        return sum(values)/len(values)

    def _requests(self, results):
        print()
        print('REQUESTS')
        print(self._header)
        for server in self._servers:
            print(
                self._csv(
                    [server] + [
                        self._best(results, 'REQUESTS', server, count)
                        for count in self._counts
                    ]
                )
            )

    def _latency(self, results):
        print()
        print('LATENCIES')
        print(self._header)
        for server in self._servers:
            print(
                self._csv(
                    [server] + [
                        self._best(results, 'LATENCIES', server, count)
                        for count in self._counts
                    ]
                )
            )

    def _cpu(self, results):
        print()
        print('CPU')
        print(self._header)
        for server in self._servers:
            print(
                self._csv(
                    [server] + [
                        self._best(results, 'CPU', server, count)
                        for count in self._counts
                    ]
                )
            )

    def _memory(self, results):
        print()
        print('MEMORY')
        print(self._header)
        for server in self._servers:
            print(
                self._csv(
                    [server] + [
                        self._best(results, 'MEMORY', server, count)
                        for count in self._counts
                    ]
                )
            )

    def _errors(self, results):
        print()
        print('ERRORS')
        print(self._header)
        for server in self._servers:
            print(
                self._csv(
                    [server] + [
                        self._best(results, 'ERRORS', server, count)
                        for count in self._counts
                    ]
                )
            )

if __name__ == '__main__':
    parser = Parser()
    for directory in sys.argv[1:]:
        parser.process(directory)

    output = Output()
    output.analyze(parser.RESULTS)
