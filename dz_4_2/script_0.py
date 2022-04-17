#!/usr/bin/env python3
# -*- codng: utf8 -*-

import os, sys

# sys.stdout = codecs.getwriter('utf-8')(sys.stdout,'replace')

bash_command = ["cd D:\\netology_dz_git\\dz_4_2>", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result.encode('utf8').decode(sys.stdout.encoding))
        break