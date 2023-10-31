include .env #in place of source .env on terminal

.PHONY: push, interaction

# GIT section

remove-add:
	git remote remove origin
	git remote add origin $(ORIGIN)

push:
	git add .
	git commit -m "finished contract 45 - attacker crossover-contract victim,suicidal"
	git push origin master

install:
	forge install Openzeppelin/openzeppelin-contracts --no-commit
