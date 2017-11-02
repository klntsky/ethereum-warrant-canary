var Canary = artifacts.require("Canary"),
    Web3 = require('web3'),
    web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

function sleep (n) {
    return new Promise((resolve, reject) => {
        setTimeout(resolve, n * 1000);
    });
}

var now = () => Date.now() / 1000;

contract("Canary", accounts => {
    var me = accounts[0],
        a = accounts[1],
        b = accounts[2],
        c = accounts[3],
        d = accounts[4],
        e = accounts[5];

    it("at least 6 unlocked accounts available", () => {
        assert(accounts.length > 6);
    });

    it("lifecycle", async () => {
        var updateInterval = 15;
        var canary = await Canary.new(updateInterval, "I'm alive!", { from: me });
        var deathTime1 = (await canary.getDeathTime.call()).toNumber();
        assert(deathTime1 > now(), "Canary is alive if time limit is not reached");

        await sleep(1.5);
        await canary.update({ from: me });
        var deathTime2 = (await canary.getDeathTime.call()).toNumber();
        assert(deathTime1 < deathTime2, "Canary's death can be deferred");

        await sleep(updateInterval + 1);

        var deathTime3 = (await canary.getDeathTime.call()).toNumber();
        assert(deathTime3 < now(), "Canary is dead after time limit is reached");

        await canary.update({ from: me });
        var deathTime4 = (await canary.getDeathTime.call()).toNumber();
        assert.equal(deathTime3, deathTime4, "Canary can't be updated if it is dead");
    });

    it("system of priveleges", async () => {
        var updateInterval = 60;
        var canary = await Canary.new(updateInterval, "I'm alive!", { from: me });
        var deathTime1 = (await canary.getDeathTime.call()).toNumber();
        assert(deathTime1 > now(), "Canary is alive if time limit is not reached");

        await canary.addOwner(a, { from: me });
        await sleep(1.5);
        await canary.update({ from: a });
        var deathTime2 = (await canary.getDeathTime.call()).toNumber();
        assert(deathTime1 < deathTime2, "New owner can update()");

        await sleep(1.5);
        await canary.update({ from: c });
        var deathTime3 = (await canary.getDeathTime.call()).toNumber();
        assert.equal(deathTime3, deathTime2, "Someone who is not owner can't update()");

        await sleep(1.5);
        await canary.removeOwner(me, { from: a });
        await canary.update({ from: me });
        var deathTime4 = (await canary.getDeathTime.call()).toNumber();
        assert.equal(deathTime4, deathTime3, "New owner can remove the old one, removed owner can't update the canary.");

        await sleep(1.5);
        await canary.addConfidant(c, { from: a });
        await canary.update({ from: c });
        var deathTime5 = (await canary.getDeathTime.call()).toNumber();
        assert(deathTime4 < deathTime5, "Confidant can be added, added confidant can update canary.");

        await sleep(1.5);
        await canary.addConfidant(d, { from: c});
        await canary.update({ from: d });
        var deathTime6 = (await canary.getDeathTime.call()).toNumber();
        assert(deathTime5 == deathTime6, "Confidant can't add new confidants.");

        await sleep(1.5);
        await canary.addOwner(e, { from: c });
        await canary.update({ from: e });
        var deathTime7 = (await canary.getDeathTime.call()).toNumber();
        assert(deathTime6 == deathTime7, "Confidant can't add new owners.");

        await sleep(1.5);
        await canary.removeConfidant(c, { from: c });
        await canary.update({ from: c });
        var deathTime8 = (await canary.getDeathTime.call()).toNumber();
        assert(deathTime7 < deathTime8, "Confidant can't remove confidants.");

        await sleep(1.5);
        await canary.removeOwner(a, { from: c });
        await canary.update({ from: a });
        var deathTime9 = (await canary.getDeathTime.call()).toNumber();
        assert(deathTime8 < deathTime9, "Confidant can't remove owners.");
    });
});
