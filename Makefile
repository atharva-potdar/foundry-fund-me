-include .env

.PHONY: build deploy-sepolia

# Thank you Cyfrin!
all: clean remove install update build test

clean  :; forge clean

remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install cyfrin/foundry-devops && forge install smartcontractkit/chainlink-brownie-contracts && forge install foundry-rs/forge-std

update:; forge update

build:; forge build

forge:; forge test
# Thank you Cyfrin!

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(ETH_SP_RPC_URL) --account metamaskKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvvv