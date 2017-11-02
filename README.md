# About

> A warrant canary is a method by which a communications service provider aims to inform its users that the provider has not been served with a secret government subpoena.
> 
> Source: [Wikipedia](https://en.wikipedia.org/wiki/Warrant_canary)

In general, it can be used to spawn a public notification on some event in cases where the user is not allowed to do so, either because of law enforcements or for some other reason.

It can also be used to prove that the owner of a canary was alive at a given time.

# Why ethereum?

Because blockchain transactions are non-revesible and smart contract's state can be inspected at any time.

Even if you choose to host your own canary in form of, for example, weekly-updatable PGP-signed message, you should take care of it's availability, and no matter how much you pay for a hosting service, the server may go down, creating uncertainity. Blockchain eliminates that problem.

# Implementation

## Permission system

To control canary's operation, two-level permission system is used, which divides all users in two groups: **owners** and **confidants**.

**Owners** can:

- update canary
- add owners
- remove owners
- add confidants
- remove confidants

**Confidants** can:

- update canary

All the users, also including all the people aside (who have no permissions at all) can trigger `CanaryDied` event if the canary was not updated by the time set at `aliveUntil`.

### Contract events

####  event CanaryUpdated(address)

Fired on canary updates.

####  event UpdateIntervalChanged(address, uint, uint);

Fired on update interval changes. Fields are: event triggering initiator, old value, new value.

####  event CanaryDied(address, uint, uint);

Fired only after canary's death. Arguments are: event triggering initiator, time of death, last update.

### Contract methods

#### function Canary (uint, string)

Constructor of the contract. Arguments are: update interval (in seconds) and description of the canary.

#### function update () alive onlyTrusted returns (bool)

Update the canary (has effect only if called by owners or confidants).

#### setUpdateInterval (uint) alive onlyOwners

Set update interval.

#### function getDeathTime () constant returns (uint)

Get probable death time.

#### function spawnDeathNotification ()

Fire `CanaryDied` event if the canary is dead.

#### function addOwner (address) alive onlyOwners returns (bool)

Add new owner. Can be called by owners only.

#### function removeOwner (address) alive onlyOwners returns (bool) 

Remove existing owner. Can be called by owners only.

#### function addConfidant (address) alive onlyOwners returns (bool)

Add new confidant. Can be called by owners only.

#### function removeConfidant (address) alive onlyOwners returns (bool)

Remove existing confidant. Can be called by owners only.

### Method modifiers

#### alive

Permits execution iff canary is alive.

#### onlyOwners

Permits execution only if `msg.sender` is owner.

#### onlyTrusted

Permits execution if `msg.sender` is owner or confidant.

# License

WTFPL