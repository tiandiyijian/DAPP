pragma solidity ^0.4.18;

contract Roulette {
    struct player {
        address addr;
        uint money;
        uint8[] bets;
    }
    
    uint8 public ballNumber;
    player[8] public players;
    uint8 public playerNum;
    uint8 public maxPlayers;
    address public owner;
    mapping(string => uint8[]) private trans;
    mapping(uint8 => uint8) private odds;
    uint private randomNonce;
    uint256 public count;
    
    function Roulette(uint8 n) public payable {
        require(n <= 8 && n > 1);
        trans["little"] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18];
        trans["big"] = [19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36];
        trans['odd'] = [1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,35];
        trans['even'] = [2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,34,36];
        trans['red'] = [1,3,5,7,9,12,14,16,18,19,21,23,25,27,30,32,34,36];
        trans['black'] = [2,4,6,8,10,11,13,15,17,20,22,24,26,28,29,31,33,35];
        trans['first'] = [1,2,3,4,5,6,7,8,9,10,11,12];
        trans['second'] = [13,14,15,16,17,18,19,20,21,22,23,24];
        trans['third'] = [25,26,27,28,29,30,31,32,33,34,35,36];
        trans['row1'] = [3,6,9,12,15,18,21,24,27,30,33,36];
        trans['row2'] = [2,5,8,11,14,17,20,23,26,29,32,35];
        trans['row3'] = [1,4,7,10,13,16,19,22,25,28,31,34];
        trans['0'] = [0];
        odds[1] = 35;
        odds[2] = 17;
        odds[3] = 11;
        odds[4] = 8;
        odds[6] = 5;
        odds[12] = 2;
        odds[18] = 1;
        count = 0;
        owner = msg.sender;
        playerNum = 0;
        randomNonce = 0;
        maxPlayers = n;
    }
    
    
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    
    function getCount() public view returns (uint256) {
        return count;
    }
    
    function Bet(string s) public payable returns(bool) {
        require(msg.value >= 1000000000000000000);
        if(trans[s].length == 0) {
            bytes memory b = bytes(s);
            uint len = b.length-1;
            require(uint8(b[0]) >= 48 && uint8(b[0]) <= 57);
            uint8[] memory temBets = new uint8[](6);
            uint i;
            uint numOfBets = 0;
            uint8 oneBet = 0;
            for (i = 0; i < b.length; i++) {
                uint c = uint(b[i]);
                if (c >= 48 && c <= 57) {
                    oneBet = oneBet * 10 + uint8(c - 48);
                }
                else if (c == 32) {
                    require(uint(b[i-1]) != 32);
                    temBets[numOfBets++] = oneBet;
                    require(numOfBets <= 5);
                    oneBet = 0;
                }
                else {
                    require(1 == 0);
                }
            }
            i--;
            require(uint8(b[i]) != 32);
            temBets[numOfBets++] = oneBet;
            uint8[] memory bets = new uint8[](numOfBets);
            for(i = 0; i < numOfBets; i++) bets[i] = temBets[i];
            require(judge(bets));
            trans[s] = bets;
        }
        players[playerNum++] = player(msg.sender, msg.value, trans[s]);
        if(playerNum == maxPlayers) {
            runlottery(maxPlayers);
            playerNum = 0;
        }
        return true;
    }

    function runlottery(uint8 currentPlayerNums) private {
        ballNumber = uint8(uint256(keccak256(now, msg.sender, randomNonce)) % 37);
        randomNonce++;
        count++;
        uint8 i = 0;
        for(; i < currentPlayerNums; ++i) {
            uint8 numOfBets = uint8(players[i].bets.length);
            uint8 l = 0;
            uint8 r = numOfBets - 1;
            while(l <= r) {
                uint8 mid = l + (r-l)/2;
                if(players[i].bets[mid] == ballNumber) {
                    players[i].addr.transfer(players[i].money * (1 + odds[numOfBets]));
                    break;
                }
                else if(players[i].bets[mid] > ballNumber) r = mid - 1;
                else l = mid + 1;
            }
        }
    }
    
    function runlotteryNow() public {
        require(msg.sender == owner);
        require(playerNum > 0);
        runlottery(playerNum);
        playerNum = 0;
    } 
    
    function collectMoney() public payable returns (uint) {
        return msg.value;
    }
    
    function transferToOwner(uint256 ethers) public {
        require(msg.sender == owner);
        owner.transfer(ethers * 1000000000000000000);
    }
    
    function judge(uint8[] tem) private pure returns (bool) {//判断押注是否合法
        uint len = tem.length;
        if(len == 1) {//单个数字押注
            return judgeOneNum(tem[0]);
        }
        else if(len == 2) {//双个数字押注
            if(judgeOneNum(tem[0]) && judgeOneNum(tem[1]) && tem[0] != 0) {//两个数字押注的时候不可以有0
                if(tem[1] == tem[0] + 1 || tem[1] == tem[0] + 3) {
                    return true;
                }
                else return false;
            }
            else {
                return false;
            }
        }
        else if(len == 3) {
            if(judgeOneNum(tem[0]) && judgeOneNum(tem[1]) && judgeOneNum(tem[2])) {
                if(tem[0] % 3 == 1 && tem[1] == tem[0] + 1 && tem[2] == tem[0] + 2) {
                    return true;
                }
                else return false;
            }
            else return false;
        }
        else if(len == 4) {//四个数字押注
            if(judgeOneNum(tem[0]) && judgeOneNum(tem[1]) && judgeOneNum(tem[2]) && judgeOneNum(tem[3])) {
                if(tem[1] == tem[0] + 1 && tem[2] == tem[0] + 3 && tem[3] == tem[0] + 4 && (tem[0] - 1) / 3 == (tem[1] - 1) / 3) {
                    return true;
                }
                else return false;
            }
            else {
                return false;
            }
        }
        else if (len == 6) {//六个数字押注
            if(judgeOneNum(tem[0]) && judgeOneNum(tem[1]) && judgeOneNum(tem[2]) && judgeOneNum(tem[3]) && judgeOneNum(tem[4]) && judgeOneNum(tem[5])) {
                if(tem[0] % 3 == 1 && tem[1] == tem[0] + 1 && tem[2] == tem[0] + 2 && tem[3] == tem[0] + 3 && tem[4] == tem[0] + 4 && tem[5] == tem[0] + 5) {
                    return true;
                }
                else return false;
            }
            else return false;
        }
        else return false;
    }
    
    function judgeOneNum(uint8 tem) pure private returns (bool) {
        return tem >= 0 && tem < 37;
    }
    

}
    