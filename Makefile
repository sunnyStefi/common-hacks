include .env #in place of source .env on terminal

.PHONY: push, interaction

# GIT section

remove-add:
	git remote remove origin
	git remote add origin $(ORIGIN)

push:
	git add .
	git commit -m "hacks 45, crosso"
	git push origin master
