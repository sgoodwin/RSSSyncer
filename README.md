RSSSyncer!
==========

Intro:
------

RSS syncing server built with Sinatra and Redis (could be a redis cluster even)
The goal is to allow for a simple system to setup syncing the read/unread/whatever
status of news items in a timeline. The same system would work for things like
instagram and twitter as well as RSS.

Usage:
======

Syncing subscriptions:
----------------------

**GET** /subscriptions.(opml|json)
Returns a list of all subscriptions in either JSON or OPML(OPML with folders) formats.
This requests conditional GET requests, simply supply the UNIX timestamp from your last request.
When a timestamp is supplied, the system only returns the subscriptions that have changed 
since the timestamp.

**GET** /subscriptions/<subscription_id>.json
Returns the information about a specific subscription or returns a 404 error when that subscription
can't be found.

**POST** /subscriptions.json
Creates a new subscription if you provide the necessary parameters:

- html_url (optional): The web page that the feed belongs to.
- feed_url: The address to the feed itself.
- name: The display name for the feed.
- type: The type of feed such as rss, atom, instagram, etc
- tags: The tags (or folder names) associated with the feed.

Returns the JSON representation of the subscription upon creation or a 400 error upon failure.

**PUT** /subscriptions/<subscription_id>.json
Updates a given subscription with the same parameters as the previous POST request.

**DELETE** /subscriptions/<subscription_id>.json
Deletes a subscription from the system.

Syncing items:
--------------

**GET** /items.json
Returns a list of all items in either JSON or OPML(OPML with folders) formats.
This requests conditional GET requests, simply supply the UNIX timestamp from your last request.
When a timestamp is supplied, the system only returns the items that have changed 
since the timestamp.

**GET** /items/<item_id>.json
Returns the JSON representation of a stream item or a 404 error if that item does not exist.

**POST** /items.json
This request updates the status for items. Parameters
must be supplied as a JSON-encoded array of dictionaries, each with the following fields:

- datetime: The datetime from the stream item itself.
- status: An 8-bit number where the left-most bit indicates read/unread status.
- item_id: The guid of the stream item provided by the RSS feed it came from.

Things not done yet:
====================

- User authentication
- Input validation
- Battle hardening
- Testing ( I am developing a command-line-based rss reader to use to test the syncing system's facilities )