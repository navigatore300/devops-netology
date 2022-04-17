#!/usr/bin/env python3
import os
from os.path import expanduser

home_dir = expanduser("~")
project_dir = 'PycharmProjects/devops-netology'

path = f"{home_dir}/{project_dir}"


bash_command = [f"cd {path}", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if (result.find('modified') != -1) or (result.find('изменено') != -1):
        prepare_result = result.replace('\tmodified:      ', '')
        prepare_result = result.replace('\tизменено:      ', '')
        print(os.path.join(path, prepare_result))


#
# #!/usr/bin/env python3
#
# import os
#
# path = "~/netology/sysadm-homeworks"
# resolved_path = os.path.normpath(os.path.abspath(os.path.expanduser(os.path.expandvars(path))))
# bash_command = [f"cd {resolved_path}", "git status"]
# result_os = os.popen(' && '.join(bash_command)).read()
# for result in result_os.split('\n'):
#     if result.find('modified') != -1:
#         prepare_result = result.replace('\tmodified:   ', '')
#         print(os.path.join(resolved_path, prepare_result))