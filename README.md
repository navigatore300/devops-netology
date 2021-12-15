# Домашнее задание к занятию «2.4. Инструменты Git»

## 1. Найдите полный хеш и комментарий коммита, хеш которого начинается на aefea.

Выполним команду:

	git show aefea -s

Результат:

	commit aefead2207ef7e2aa5dc81a34aedf0cad4c32545
	Author: Alisdair McDiarmid <alisdair@users.noreply.github.com>
	Date:   Thu Jun 18 10:29:58 2020 -0400
	
	Update CHANGELOG.md
---
**ОТВЕТ:**

Полный хеш:		aefead2207ef7e2aa5dc81a34aedf0cad4c32545

Комментарий коммита: 	Update CHANGELOG.md

---
## 2. Какому тегу соответствует коммит 85024d3?

Выполним команду:

	git show 85024d3 -s

Результат:

	commit 85024d3100126de36331c6982bfaac02cdab9e76 (tag: v0.12.23)
	Author: tf-release-bot <terraform@hashicorp.com>
	Date:   Thu Mar 5 20:56:10 2020 +0000

	    v0.12.23

---

**ОТВЕТ:**

tag: v0.12.23

---

## 3. Сколько родителей у коммита b8d720? Напишите их хеши.

Выполним команду:

	git show b8d720

Результат:

	commit b8d720f8340221f2146e4e4870bf2ee0bc48f2d5
	Merge: 56cd7859e 9ea88f22f
	Author: Chris Griggs <cgriggs@hashicorp.com>
	Date:   Tue Jan 21 17:45:48 2020 -0800
	
	    Merge pull request #23916 from hashicorp/cgriggs01-stable
	
	    [Cherrypick] community links

---

**ОТВЕТ:**

Два родителя: 56cd7859e 9ea88f22f

---

## 4. Перечислите хеши и комментарии всех коммитов которые были сделаны между тегами v0.12.23 и v0.12.24.

Выполним команду:

	git log v0.12.23..v0.12.24 --oneline

---

**ОТВЕТ:**

	33ff1c03b (tag: v0.12.24) v0.12.24
	b14b74c49 [Website] vmc provider links
	3f235065b Update CHANGELOG.md
	6ae64e247 registry: Fix panic when server is unreachable
	5c619ca1b website: Remove links to the getting started guide's old location
	06275647e Update CHANGELOG.md
	d5f9411f5 command: Fix bug when using terraform login on Windows
	4b6d06cc5 Update CHANGELOG.md
	dd01a3507 Update CHANGELOG.md
	225466bc3 Cleanup after v0.12.23 release

---

## 5. Найдите коммит в котором была создана функция func providerSource, ее определение в коде выглядит так func providerSource(...) (вместо троеточего перечислены аргументы).

Выполним команду:

	git show -S'func providerSource' 

Результат:
	
	
	commit 5af1e6234ab6da412fb8637393c5a17a1b293663
	Author: Martin Atkins <mart@degeneration.co.uk>
	Date:   Tue Apr 21 16:28:59 2020 -0700
	
	    main: Honor explicit provider_installation CLI config when present

	commit 8c928e83589d90a031f811fae52a81be7153e82f
	Author: Martin Atkins <mart@degeneration.co.uk>
	Date:   Thu Apr 2 18:04:39 2020 -0700

	    main: Consult local directories as potential mirrors of providers

Вероятнее всего функция определена в более раннем комите. Поэтому смотрим его.

Выполним команду:

	git show 8c928e83589d90a031f811fae52a81be7153e82f | grep -i 'func providerSource('

Видим что да она была добавлена признак "+"
	
	+func providerSource(services *disco.Disco) getproviders.Source {

Для точного определения:

	git grep --heading -n -i 'func providerSource' 8c928e83589d90a031f811fae52a81be7153e82f

Результат: 

	8c928e83589d90a031f811fae52a81be7153e82f:provider_source.go
	19:func providerSource(services *disco.Disco) getproviders.Source {

---

**ОТВЕТ:**

Функция была определена в комите 8c928e83589d90a031f811fae52a81be7153e82f в файле provider_source.go в 19 строке

---

## 6. Найдите все коммиты в которых была изменена функция globalPluginDirs.

Выполним команду:
    
    git log -SglobalPluginDirs

Результат: 

    commit 35a058fb3ddfae9cfee0b3893822c9a95b920f4c
    Author: Martin Atkins <mart@degeneration.co.uk>
    Date:   Thu Oct 19 17:40:20 2017 -0700
    
        main: configure credentials from the CLI config file
    
    commit c0b17610965450a89598da491ce9b6b5cbd6393f
    Author: James Bardin <j.bardin@gmail.com>
    Date:   Mon Jun 12 15:04:40 2017 -0400
    
        prevent log output during init
    
        The extra output shouldn't be seen by the user, and is causing TFE to
        fail.
    
    commit 8364383c359a6b738a436d1b7745ccdce178df47
    Author: Martin Atkins <mart@degeneration.co.uk>
    Date:   Thu Apr 13 18:05:58 2017 -0700
    
        Push plugin discovery down into command package

Найдем в каком файле определяется функция

    git grep --heading -n -i 'globalPluginDirs'

Результат:

    commands.go
    88:             GlobalPluginDirs: globalPluginDirs(),
    430:    helperPlugins := pluginDiscovery.FindPlugins("credentials", globalPluginDirs())
    internal/command/cliconfig/config_unix.go
    34:             // FIXME: homeDir gets called from globalPluginDirs during init, before
    internal/command/meta.go
    72:     GlobalPluginDirs []string // Additional paths to search for plugins
    internal/command/plugins.go
    91:     dirs = append(dirs, m.GlobalPluginDirs...)
    plugins.go
    12:// globalPluginDirs returns directories that should be searched for
    18:func globalPluginDirs() []string {

Видим что функция определяется в файле plugins.go

---
**ОТВЕТ:** 

 Результат приведенной ниже команды покажет историю изменения функции
 
git log -L :globalPluginDirs:plugins.go

---

## 7. Кто автор функции synchronizedWriters?

Выполним команду:

    git log -SsynchronizedWriters

Результат:

	commit bdfea50cc85161dea41be0fe3381fd98731ff786
	Author: James Bardin <j.bardin@gmail.com>
	Date:   Mon Nov 30 18:02:04 2020 -0500
	
	    remove unused

	commit fd4f7eb0b935e5a838810564fd549afe710ae19a
	Author: James Bardin <j.bardin@gmail.com>
	Date:   Wed Oct 21 13:06:23 2020 -0400
	
	    remove prefixed io

	commit 5ac311e2a91e381e2f52234668b49ba670aa0fe5
	Author: Martin Atkins <mart@degeneration.co.uk>
	Date:   Wed May 3 16:25:41 2017 -0700

Выполним команду:

    git grep --heading -n -i 'synchronizedWriters' 5ac311e2a91e381e2f52234668b49ba670aa0fe5

Результат:


	5ac311e2a91e381e2f52234668b49ba670aa0fe5:main.go
	267:            wrapped := synchronizedWriters(stdout, stderr)
	5ac311e2a91e381e2f52234668b49ba670aa0fe5:synchronized_writers.go
	13:// synchronizedWriters takes a set of writers and returns wrappers that ensure
	15:func synchronizedWriters(targets ...io.Writer) []io.Writer {

Выполним команду:

    git checkout 5ac311e2a91e381e2f52234668b49ba670aa0fe5
	
    git blame -L 15,15 synchronized_writers.go

Результат:

	5ac311e2a9 (Martin Atkins 2017-05-03 16:25:41 -0700 15) func synchronizedWriters(targets ...io.Writer) []io.Writer {

---

**ОТВЕТ:**

Автор: Martin Atkins 2017-05-03 16:25:41

---
