### Как сдавать задания

Вы уже изучили блок «Системы управления версиями», и начиная с этого занятия все ваши работы будут приниматься ссылками на .md-файлы, размещённые в вашем публичном репозитории.

Скопируйте в свой .md-файл содержимое этого файла; исходники можно посмотреть [здесь](https://raw.githubusercontent.com/netology-code/sysadm-homeworks/devsys10/04-script-02-py/README.md). Заполните недостающие части документа решением задач (заменяйте `???`, ОСТАЛЬНОЕ В ШАБЛОНЕ НЕ ТРОГАЙТЕ чтобы не сломать форматирование текста, подсветку синтаксиса и прочее, иначе можно отправиться на доработку) и отправляйте на проверку. Вместо логов можно вставить скриншоты по желани.

# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательная задача 1

Есть скрипт:
```python
#!/usr/bin/env python3
a = 1
b = '2'
c = a + b
```

### Вопросы:
| Вопрос  | Ответ |
| ------------- | ------------- |
| Какое значение будет присвоено переменной `c`?  | TypeError: unsupported operand type(s) for +: 'int' and 'str'  |
| Как получить для переменной `c` значение 12?  | c = (a + int(b)) * int(b) * int(b)  |
| Как получить для переменной `c` значение 3?  | c = a + int(b)  |

## Обязательная задача 2
Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

```python
#!/usr/bin/env python3

import os

bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
is_change = False
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(prepare_result)
        break
```

### Ваш скрипт:
```python
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
```

### Вывод скрипта при запуске при тестировании:
```
/usr/bin/python3.8 /home/userr/PycharmProjects/devops-netology/dz_4_2/test.py
/home/userr/PycharmProjects/devops-netology/dz_4_2/script0.py
/home/userr/PycharmProjects/devops-netology/dz_4_2/test.py

Process finished with exit code 0
```

## Обязательная задача 3
1. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

### Ваш скрипт:
```python
#!/usr/bin/env python3

import os
import sys
import subprocess
import re

try:
    path = sys.argv[1]
except IndexError:
    path = "~/PycharmProjects/devops-netology"

resolved_path = os.path.expanduser(path)

try:
    result_os = subprocess.Popen(["git", "status", "--porcelain"], stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT, cwd=resolved_path, text=True).communicate()[0].split('\n')
except FileNotFoundError:
    print(
        f'Не могу найти папку {path}'
    )
    exit()

if result_os[0].find('fatal:') >= 0:
    print(
        f'В папке {resolved_path} нет git репозитория. Поищите в другой папке.')
    exit()

list = {"M": "modified", "R": "renamed", "\?": "untracked"}

for result in result_os:
    for element in list.keys():
        regexp = re.compile(r"^ *" + element + "{1,2} *")
        if regexp.search(result):
            prepare_result = re.sub(regexp, '', result).split(' -> ')
            if list[element] == 'renamed':
                print(
                    f'{list[element]}:\t {os.path.join(resolved_path, prepare_result[1])} <- {prepare_result[0]}')
            else:
                print(
                    f'{list[element]}:\t {os.path.join(resolved_path, prepare_result[0])}')
```

### Вывод скрипта при запуске при тестировании:
```
/usr/bin/python3.8 /snap/pycharm-professional/278/plugins/python/helpers/pydev/pydevd.py --multiproc --qt-support=auto --client 127.0.0.1 --port 41877 --file /home/userr/PycharmProjects/devops-netology/dz_4_2/1.py
Connected to pydev debugger (build 213.7172.26)
untracked:	 /home/userr/PycharmProjects/devops-netology/.idea/
untracked:	 /home/userr/PycharmProjects/devops-netology/dz_4_2/1.py

Process finished with exit code 0
```

## Обязательная задача 4
1. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: `drive.google.com`, `mail.google.com`, `google.com`.

### Ваш скрипт:
```python
# /usr/bin/env python3

import socket
import time

hosts = {"drive.google.com": {"ipv4": "192.168.0.1"}, "mail.google.com": {
    "ipv4": "172.16.0.1"}, "google.com": {"ipv4": "10.0.0.1"}}

while True:
    for host in hosts.keys():
        cur_ip = hosts[host]["ipv4"]
        check_ip = socket.gethostbyname(host)
        if check_ip != cur_ip:
            print(f"""[ERROR] {host} IP mismatch: {cur_ip} {check_ip}""")
            hosts[host]["ipv4"] = check_ip
        else:
            print(f"""{host} - {cur_ip}""")
    time.sleep(2)
```

### Вывод скрипта при запуске при тестировании:
```
/usr/bin/python3.8 /home/userr/PycharmProjects/devops-netology/dz_4_2/2.py
[ERROR] drive.google.com IP mismatch: 192.168.0.1 74.125.131.194
[ERROR] mail.google.com IP mismatch: 172.16.0.1 216.58.210.133
[ERROR] google.com IP mismatch: 10.0.0.1 216.58.209.174
drive.google.com - 74.125.131.194
mail.google.com - 216.58.210.133
google.com - 216.58.209.174
```

## Дополнительное задание (со звездочкой*) - необязательно к выполнению

Так получилось, что мы очень часто вносим правки в конфигурацию своей системы прямо на сервере. Но так как вся наша команда разработки держит файлы конфигурации в github и пользуется gitflow, то нам приходится каждый раз переносить архив с нашими изменениями с сервера на наш локальный компьютер, формировать новую ветку, коммитить в неё изменения, создавать pull request (PR) и только после выполнения Merge мы наконец можем официально подтвердить, что новая конфигурация применена. Мы хотим максимально автоматизировать всю цепочку действий. Для этого нам нужно написать скрипт, который будет в директории с локальным репозиторием обращаться по API к github, создавать PR для вливания текущей выбранной ветки в master с сообщением, которое мы вписываем в первый параметр при обращении к py-файлу (сообщение не может быть пустым). При желании, можно добавить к указанному функционалу создание новой ветки, commit и push в неё изменений конфигурации. С директорией локального репозитория можно делать всё, что угодно. Также, принимаем во внимание, что Merge Conflict у нас отсутствуют и их точно не будет при push, как в свою ветку, так и при слиянии в master. Важно получить конечный результат с созданным PR, в котором применяются наши изменения. 

### Ваш скрипт:
```python
???
```

### Вывод скрипта при запуске при тестировании:
```
???
```****