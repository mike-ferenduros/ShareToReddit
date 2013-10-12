ShareToReddit
=============

An iOS UIActivity for posting an image to Reddit. See the demo app for basic usage.

To use this you need an Imgur API key. Go to [api.imgur.com](http://api.imgur.com) and look for the 'register' link. Try and build the example and you should get an error telling you where to put the client id.

Right now this is limited to what I needed it to do:
 - iOS7 only
 - iPad only
 - Shares a single UIImage

None of the above should be particularly hard to fix.

Reddit credentials are stored in the keychain as raw username/passwords, and it'll remember multiple at a time for fast switching between alts.

If you want to ship this in a commercial app, you also need to sign up with [Mashape](https://www.mashape.com/imgur/apiv3), who meter Imgur's API usage.
Their free plan allows 1250 free uploads per day, and after that it's 1¢ per 10 uploads.

Questions / suggestions welcome, but gotten this to where I need it for [my app](http://chunkyreader.com) it's not a super high-priority project for me.
