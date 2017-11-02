pragma solidity ^0.4.13;

contract Canary {

  uint updateInterval;
  uint aliveUntil;
  uint lastUpdate;
  string description;
  bool isDeathNotificationIssued = false;

  mapping (address => bool) owners;
  mapping (address => bool) confidants;

  uint32 ownersCount = 0;
  uint32 confidantsCount = 0;

  event CanaryUpdated(address indexed initiator);
  event UpdateIntervalChanged(address indexed initiator, uint from, uint to);
  event CanaryDied(address indexed initiator, uint wasAliveUntil, uint _lastUpdate);

  function Canary (uint _updateInterval,
                   string _description) {
    updateInterval = _updateInterval;
    description = _description;
    aliveUntil = now + updateInterval;
    lastUpdate = now;
    owners[msg.sender] = true;
    ownersCount = 1;
  }

  function update () alive onlyTrusted returns (bool success) {
    aliveUntil = now + updateInterval;
    lastUpdate = now;
    CanaryUpdated(msg.sender);
    return true;
  }

  function setUpdateInterval (uint interval) alive onlyOwners {
    UpdateIntervalChanged(msg.sender, updateInterval, interval);
    updateInterval = interval;
  }

  function getDeathTime () constant returns (uint) {
    return aliveUntil;
  }

  function spawnDeathNotification () {
    if (aliveUntil < now && !isDeathNotificationIssued) {
      CanaryDied(msg.sender, aliveUntil, lastUpdate);
      isDeathNotificationIssued = true;
    }
  }

  // Returns false iff the given owner is already added.
  function addOwner (address addr) alive onlyOwners returns (bool) {
    if (owners[addr]) {
      return false;
    }
    owners[addr] = true;
    ownersCount += 1;
    return true;
  }

  // Returns false iff the given owner does not exist.
  function removeOwner (address addr) alive onlyOwners returns (bool) {
    if (!owners[addr]) {
      return false;
    }
    owners[addr] = false;
    ownersCount -= 1;
    return true;
  }

  // Returns false iff the given confidant is already added.
  function addConfidant (address addr) alive onlyOwners returns (bool) {
    if (confidants[addr]) {
      return false;
    }
    confidants[addr] = true;
    confidantsCount += 1;
    return true;
  }

  // Returns false iff the given confidant does not exist.
  function removeConfidant (address addr) alive onlyOwners returns (bool) {
    if (!confidants[addr]) {
      return false;
    }
    confidants[addr] = false;
    confidantsCount -= 1;
    return true;
  }

  modifier alive {
    if (aliveUntil > now) {
      _;
    } else {
      spawnDeathNotification();
    }
  }

  modifier onlyOwners {
    if (owners[msg.sender]) {
      _;
    }
  }

  modifier onlyTrusted {
    if (owners[msg.sender] || confidants[msg.sender]) {
      _;
    }
  }

  function () payable {
    revert();
  }
}
