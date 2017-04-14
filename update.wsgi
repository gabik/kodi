#!/usr/bin/python
# -*- coding: UTF-8 -*-

import subprocess

def get_html():
	upgrade_path = "/home/gabi/kodi/repo/repos/update.sh"
	process = subprocess.Popen(upgrade_path, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
	stdout_list = process.communicate()[0].split('\n')
	output = "<pre>"
	for i in stdout_list:
		if i is None:
			i = ""
		output += i + "\n"
	output += '</pre>'
	return output

def application (env, r):
    body = get_html()
    status = '200 OK'
    response_headers = [ ('Content-Type', 'text/html'), ('Content-Length', str (len (body) ) ) ]
    r (status, response_headers)
    return [body]

