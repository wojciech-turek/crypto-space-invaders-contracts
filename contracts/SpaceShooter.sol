// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract CryptoSpaceInvaders is
    ERC1155,
    Ownable,
    ERC1155Burnable,
    ERC1155Supply
{
    uint256 public constant CREDITS = 0;
    uint256 public creditPrice = 1 ether;

    // add highest score that can be set
    uint256 public highestScore = 0;
    address public highestScorer = address(0);

    uint256 public leagueDuration = 2 days;

    uint256 public leagueStart = 0;

    uint256 public leagueNumber = 0;

    bytes32 public leagueSponsor = "";

    uint256 public leagueReward = 0;

    // We could add more types of tokens here for example NFT badges, NFT space ships with different stats, different types of weapons, etc.

    // Below API does not exist, but is added as an example
    constructor()
        ERC1155("https://api.cryptospaceinvaders.com/api/token/{id}")
    {}

    // Burn a single credit for playing the game
    // @param _id - the id of the token to burn
    function burnCredit(uint256 _id) public {
        require(
            leagueStart + leagueDuration > block.timestamp,
            "League is not active"
        );
        require(leagueStart != 0, "Game has not started yet");
        _burn(_msgSender(), _id, 10**18);
    }

    // Mint specific amount of credits for playing the game
    // @param _account - the account to mint the credits to
    // @param _id - the id of the token to mint
    // @param _amount - the amount of credits to mint
    function buyCredit(
        address _account,
        uint256 _id,
        uint256 _amount
    ) public payable {
        require(msg.value >= _amount * creditPrice, "Insufficient value");
        _mint(_account, _id, _amount * (10**18), "");

        // send half of the value to the owner and allocate rest towards leagueReward
        uint256 ownerShare = msg.value / 2;
        leagueReward += msg.value - ownerShare;
        payable(owner()).transfer(ownerShare);
    }

    // Withdraw accumulated funds
    function withdrawAccumulated() public onlyOwner {
        payable(_msgSender()).transfer(address(this).balance);
    }

    // Allow users to sponsor the game
    function sponsorLeague(bytes32 _sponsorName) public payable {
        require(msg.value >= 10 ether, "Insufficient value");
        require(leagueSponsor == "", "League already sponsored");

        leagueReward += msg.value;
        leagueSponsor = _sponsorName;
    }

    // Sets the price of a credit
    // @param newPrice The price of a credit in wei
    function setCreditPrice(uint256 newPrice) public onlyOwner {
        creditPrice = newPrice;
    }

    // Sets the highest score
    // @param _score The new highest score
    function setHighestScore(uint256 _score, address _scorer) public {
        require(_score > highestScore, "Score is not higher than current");
        require(
            _scorer != address(0),
            "Scorer address cannot be the zero address"
        );
        // require that the league has started
        require(block.timestamp >= leagueStart, "League has not started yet");
        // require that the league has not ended
        require(
            block.timestamp <= leagueStart + leagueDuration,
            "League has ended"
        );
        highestScore = _score;
        highestScorer = _scorer;
    }

    // Sets the league duration
    // @param _duration The new league duration
    function setLeagueDuration(uint256 _duration) public onlyOwner {
        leagueDuration = _duration;
    }

    // Wrap up league, send rewards and start new league
    function wrapUpLeagueAndStartNew() public {
        require(
            block.timestamp >= leagueStart + leagueDuration,
            "League is not over yet"
        );
        // Send rewards to top player
        payable(highestScorer).transfer(leagueReward);
        leagueReward = 0;
        leagueSponsor = "";

        // Start new league
        leagueStart = block.timestamp;
        leagueNumber++;
    }

    function startFirstLeague() public onlyOwner {
        leagueStart = block.timestamp;
        leagueNumber = 1;
    }

    // Default functions
    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public onlyOwner {
        _mintBatch(to, ids, amounts, data);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public onlyOwner {
        _mint(account, id, amount, data);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
