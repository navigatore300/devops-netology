# devops-netology. 

Домашнее задание к занятию «2.4. Инструменты Git»

# 1. Найдите полный хеш и комментарий коммита, хеш которого начинается на `aefea`.
## Выполним команду:
git show aefea -s

# Результат:
commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
Date:   Thu Jun 18 10:29:58 2020 -0400

    Update CHANGELOG.md


# 2. Какому тегу соответствует коммит `85024d3`?
4. Сколько родителей у коммита `b8d720`? Напишите их хеши.
5. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами  v0.12.23 и v0.12.24.
6. Найдите коммит в котором была создана функция `func providerSource`, ее определение в коде выглядит 
так `func providerSource(...)` (вместо троеточего перечислены аргументы).
1. Найдите все коммиты в которых была изменена функция `globalPluginDirs`.
1. Кто автор функции `synchronizedWriters`? 


Домашнее задание к занятию «2.1. Системы контроля версий.»

## Добавлен файл .gitignore  папку terraform


**/.terraform/*		На любой глубине в папке .terraform все файлы находящиеся в ней игнорируются git-ом

*.tfstate		Вcе файлы с расширением .tfstate на любой глубине игрорируются

*.tfstate.*		Все файлы содержащие в имели в любом месте .tfstate. на любой глубине игнорируются

crash.log		Файл crash.log на любой глубине игнорируется

*.tfvars		Вcе файлы с расширением .tfvars на любой глубине игрорируются

override.tf		Файл override.tf на любой глубине игнорируется

override.tf.json	Файл override.tf на любой глубине игнорируется

*_override.tf		Все файлы оканчивающиеся на _override.tf и _override.tf.json на любой глубине игнорируются

*_override.tf.json

.terraformrc		Файл .terraformrc на любой глубине игнорируется

terraform.rc		Файл terraform.rc на любой глубине игнорируется

add line in branch fix

one line

edit branch_test
