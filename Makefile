include .env #in place of source .env on terminal

.PHONY: push, interaction

# GIT section

remove-add:
	git remote remove origin
	git remote add origin $(ORIGIN)

push:
	git add .
	git commit -m "readme"
	git push origin master

install:
	forge install Openzeppelin/openzeppelin-contracts --no-commit


anvilFees:
	anvil --order fees

deployfund:
	forge create --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL) src/Y_Frontrunning.sol:Victim 
	cast send 0x5FbDB2315678afecb367f032d93F642f64180aa3  "" --value 1ether --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL)
	cast rpc evm_setIntervalMining 30 --rpc-url $(RPC_URL_ANVIL)

#30 gwei

user:
	cast send --gas-price 1076732769 0x5FbDB2315678afecb367f032d93F642f64180aa3 "findSecret(string)" "answer" --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL_1)
#120 gwei
evil:
	cast send --gas-price 1000076732769 0x5FbDB2315678afecb367f032d93F642f64180aa3 "findSecret(string)" "answer" --rpc-url $(RPC_URL_ANVIL) --private-key $(PRIVATE_KEY_ANVIL_2)

automine:
	cast rpc evm_setAutomine true --rpc-url $(RPC_URL_ANVIL)

#user1,2,3
balances:
	cast balance 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266
	cast balance 0x70997970C51812dc3A010C7d01b50e0d17dc79C8 
	cast balance 0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC

