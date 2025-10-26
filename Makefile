-include .env

.PHONY: all clean remove install update build test format deploy-sepolia fund-sepolia withdraw-sepolia

# Thank you Cyfrin!
all: clean remove install update build test format

clean  :; forge clean

remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "Force update modules"

install :; forge install cyfrin/foundry-devops && forge install smartcontractkit/chainlink-brownie-contracts && forge install foundry-rs/forge-std

update :; forge update

build :; forge build

test :; forge test

format :; forge fmt
# Thank you Cyfrin!

deploy-sepolia:
	forge script script/DeployFundMe.s.sol:DeployFundMe --rpc-url $(ETH_SP_RPC_URL) --account metamaskKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvvv

fund-sepolia:
	forge script script/Interactions.s.sol:FundFundMe --rpc-url $(ETH_SP_RPC_URL) --account metamaskKey --broadcast -vvvvv

withdraw-sepolia:
	forge script script/Interactions.s.sol:WithdrawFundMe --rpc-url $(ETH_SP_RPC_URL) --account metamaskKey --broadcast -vvvvv