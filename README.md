# devops-netology. 
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

hotfix
