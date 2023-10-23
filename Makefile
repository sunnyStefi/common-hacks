include .env #source .env on terminal

#to put in order and comment better
.PHONY: push, interaction

# GIT section

set-remote:
	git remote remove origin
	git remote add origin $(ORIGIN)

push:
	git add .
	git commit -m "added set remote to makefile"
	git push origin master


# Tool to know exactly !which function! my tx is calling
#
# 0. Check contract address
# 1. Compare the selector returned by this sig 
# with the selector on metamask data tx
# 2. Decode with calldata (below)
#
# NB. the signature name on metamask on AAVE for depositing ETH is different from the actual called
# Deposit E T H (Address, Address, Uint16) >> go trough the code instead!
# depositETH(address,address,uint16)
# source: contract code & 4byte.directory
verify-selector-on-metamask:
	cast sig 'depositETH(address,address,uint16)'

# Shows the real input that the function is using
# @params takes function sig + tx data
# @return calls
# 
decode:
	cast --calldata-decode "depositETH(address,address,uint16)" 0x474cf53d00000000000000000000000087870bca3f3fd6335c3f4ce8392d69350b4fa4e2000000000000000000000000449dabbfeb5aabc3a9477c02f47933b19250d72a0000000000000000000000000000000000000000000000000000000000000000

#mif some packeges are already installed -> lazy && operator
install:
	forge install OpenZeppelin/openzeppelin-contracts --no-commit
	OpenZeppelin/openzeppelin-contracts-upgradeable  --no-commit
	Cyfrin/foundry-devops@0.0.11 --no-commit
	forge install smartcontractkit/chainlink-brownie-contracts@0.6.1
	forge install foundry-rs/forge-std@v1.5.3 --no-commit
	forge install transmissions11/solmate@v6 --no-commit

#simulation if --broadcast is not present
deploy:
	forge script script/BoxDeploy.s.sol:BoxDeploy --rpc-url $(RPC_URL_SEPOLIA_ALCHEMY) --private-key $(PRIVATE_KEY_METAMASK) --broadcast

# DevOpsTools requires --ffi
upgrade:
	forge script script/BoxUpgrade.s.sol:BoxUpgrade --rpc-url $(RPC_URL_SEPOLIA_ALCHEMY) --private-key $(PRIVATE_KEY_METAMASK) --ffi --broadcast

check-version-upgraded:
	cast call 0x41836F1bc0e1E6b5d9445a0b550830D5BF578778 "version()" --rpc-url $(RPC_URL_SEPOLIA_ALCHEMY) 

#call box2 function
setNumber:
	cast send 0x41836F1bc0e1E6b5d9445a0b550830D5BF578778 "setNumber()" 77 --rpc-url $(RPC_URL_SEPOLIA_ALCHEMY) --private-key $(PRIVATE_KEY_METAMASK)

interaction-sepolia:
	forge script script/Interactions.s.sol:$(INTERACTION) --private-key $(PRIVATE_KEY_METAMASK) --rpc-url $(RPC_URL_SEPOLIA_ALCHEMY) --broadcast

test-fork:
	forge test --mt testPerformUpkeepRunsWhenCheckUpkeepIsTrue --fork-url $(RPC_URL_SEPOLIA_ALCHEMY)  -vvvv


dependencies:
	   brew install jq

deploy-sepolia:
	forge script script/HappyNFTDeploy.s.sol:HappyNFTDeploy --rpc-url $(RPC_URL_SEPOLIA_ALCHEMY) --private-key $(PRIVATE_KEY_METAMASK) --broadcast --verify --etherscan-api-key $(API_KEY_ETHERSCAN) -vvvv

deploy-anvil:
	forge script script/HappyNFTDeploy.s.sol:HappyNFTDeploy --rpc-url $(RPC_URL_ANVIL)  --private-key $(PRIVATE_KEY_ANVIL) --gas-limit 4700000 --broadcast -vvvv

mint-sepolia:
	forge script script/Interactions.s.sol:MintProgrammatically --rpc-url $(RPC_URL_SEPOLIA_ALCHEMY) --private-key $(PRIVATE_KEY_METAMASK) --broadcast --verify --etherscan-api-key $(API_KEY_ETHERSCAN) -vvvv

test-sepolia:
	forge test --rpc-url $(RPC_URL_SEPOLIA_ALCHEMY)

convert-svg-base64:
	base64 -i img/guineaPig2.svg

decode:
	cast call 0x5FbDB2315678afecb367f032d93F642f64180aa3 "decodeString()" --rpc-url $(RPC_URL_ANVIL)  --private-key $(PRIVATE_KEY_ANVIL) 