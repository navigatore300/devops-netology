#!/usr/bin/env python3
# -*- coding: utf-8 -*-
from sys import platform
import os
from os.path import expanduser

home_dir = expanduser("~")
project_dir = '\\PythonProject\\devops-netology'

path = f"{home_dir}{project_dir}"

bash_command = [f"cd {path}", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(os.path.join(path, prepare_result))