ShareToReddit
=============

An iOS UIActivity for posting an image to Reddit. See the demo app for basic usage.

To use this you need an Imgur API key. Go to [api.imgur.com](http://api.imgur.com) and look for the 'register' link, and once you get your Client ID, build the example app and you'll get an error telling you where to enter it.

Or if you just want to test-drive the UI, leave garbage in for the Imgur the client-ID and it'll mostly work but fail to actually post.

Right now this is limited to what I needed from it:
 - iOS7 only
 - iPad only
 - Shares only a single UIImage at a time
 - No localisation

None of the above should be particularly hard to fix.

Features:
 - Reddit credentials are stored in the keychain (as a username+cookie), and the user can add several several for fast switching between alts.
 - Captchas handled for low-karma posters
 - You can supply a list of suggested subreddits to post to, plus the UI will present the most recently used ones.
 - NSFW flagging

If you want to ship this in a commercial app, you need to sign up with [Mashape](https://www.mashape.com/imgur/apiv3), who meter Imgur's API usage.
Their free plan allows 1250 free uploads per day, and after that it's 1¢ per 10 uploads.

You'll also need permission from licensing@reddit.com to use the Reddit logo, or else you can replace reddit7.png with something else.

Questions / suggestions welcome, but having gotten this to where I need it for [my app](http://chunkyreader.com) it's not a super high-priority project for me.
