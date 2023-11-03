include .env #in place of source .env on terminal

.PHONY: push, interaction

# GIT section

remove-add:
	git remote remove origin
	git remote add origin $(ORIGIN)

push:
	git add .
	git commit -m "frontrunning, tests"
	git push origin master

install:
	forge install Openzeppelin/openzeppelin-contracts --no-commit

deploy:
	 forge create --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL) src/Y_Frontrunning.sol:Victim 

fund:
	cast send 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512  "" --value 1ether --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL)
	
findSecret-lowGas:
	cast send --gas-price 107846 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "findSecret(string)" "answer" --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL)

findSecret-highGas:
	cast send --gas-price 100 0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512 "findSecret(string)" "answer" --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL_1)