$(document).ready(function() {
    if (typeof web3 !== 'undefined') {
        web3 = new Web3(web3.currentProvider);
    } else {
        // set the provider you want from Web3.providers
        web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:7545"));
        console.log("7545")
    }
    if (web3.isConnected())
        console.log("ok");
    var contract = web3.eth.contract(abi);
    var Roulette = contract.at(address);
    web3.eth.defaultAccount = web3.eth.accounts[1];
    var currentCount = -2;
    var trans = new Object;
    var odds = new Object;
    var currentBets, currentMoney;
    Initialize();


    $("#Bet").click(function() {
        let bets = $("#bets").val();
        let money = $("#money").val();
        //console.log(typeof bets);
        // Roulette.owner(function (error, result) {
        //     if (!error) {
        //       console.log(result);
        //     }
        // });
        currentCount = parseInt(Roulette.getCount().toString());
        Roulette.Bet.sendTransaction(bets, { value: web3.toWei(money, 'ether'), gas: '67219750000', gasPrice: '2000000000' }, function(error) {
            if (error) {
                console.log(error);
                alert("wrong input!")
            }
        });
        if (bets in trans) {
            currentBets = trans[bets];
        } else {
            currentBets = bets.split(' ');
        }
        currentMoney = parseInt(money);
        console.log(currentBets);
    });

    $("#account").click(function() {
        console.log(web3.eth.defaultAccount);
        let addr = $("#address").val();
        console.log(addr);
        web3.eth.defaultAccount = addr;
        console.log(web3.eth.defaultAccount);
    });

    $("li a").first().css("background-color", "green");

    $("#blink").click(function() {
        blink(1);
    });

    $("#showResult").click(function() {
        console.log(Object.keys(trans).length);
        let count = Roulette.getCount().toString();
        console.log(count);
        console.log(currentCount == count);
        if (currentCount == count) {
            $("#result").val("waiting to run a lottery!");
        } else if (currentCount == count - 1) {
            let res = parseInt(getBallNum().toString());
            //console.log(typeof res + res < 40);
            blink(res);
            if (currentBets.indexOf(res) >= 0 || currentBets.indexOf(res.toString()) >= 0) {
                $("#result").val("You win " + odds[currentBets.length] * currentMoney + ' ethers!');
            } else {
                $("#result").val("You lose and " + res + " is the luckey number.");
            }
        } else {
            $("#result").val("You must bet first!");
        }
    });

    $("#showBalance").click(function() {
        web3.eth.getBalance(web3.eth.defaultAccount, function(error, result) {
            if (error) console.log(error);
            else {
                console.log(result.toString(10));
                $("#balance").val(web3.fromWei(result.toString(), 'ether') + 'ethers');
            }
        })
    });

    function getBallNum() {
        let res = Roulette.ballNumber().toString();
        //console.log(res);
        return res;
    };

    function getCount() {
        let res = Roulette.getCount();
        //console.log(res + typeof res);
        return res;
    }

    function blink(num) {
        let a0 = $("span").eq(num);
        let timer;
        let count = 0;
        cancelAnimationFrame(timer);
        timer = requestAnimationFrame(function fn() {
            if (count < 100) {
                let t = count % 10;
                if (t >= 0 && t < 5) {
                    a0.hide();
                } else {
                    a0.show();
                }
                ++count;
                timer = requestAnimationFrame(fn);
            } else {
                cancelAnimationFrame(timer);
            }
        });
    }

    function Initialize() {
        trans["little"] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];
        trans["big"] = [19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36];
        trans['odd'] = [1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35];
        trans['even'] = [2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36];
        trans['red'] = [1, 3, 5, 7, 9, 12, 14, 16, 18, 19, 21, 23, 25, 27, 30, 32, 34, 36];
        trans['black'] = [2, 4, 6, 8, 10, 11, 13, 15, 17, 20, 22, 24, 26, 28, 29, 31, 33, 35];
        trans['first'] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
        trans['second'] = [13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24];
        trans['third'] = [25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36];
        trans['row1'] = [3, 6, 9, 12, 15, 18, 21, 24, 27, 30, 33, 36];
        trans['row2'] = [2, 5, 8, 11, 14, 17, 20, 23, 26, 29, 32, 35];
        trans['row3'] = [1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34];
        trans['0'] = [0];
        odds[1] = 35;
        odds[2] = 17;
        odds[3] = 11;
        odds[4] = 8;
        odds[6] = 5;
        odds[12] = 2;
        odds[18] = 1;
    }
});