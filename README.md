# DefAds
A module with a set of multiplatfoorm ads helper for Defold
Work with the following extensions/adplatforms:
- IronSource
- ApplovinMax (Android)
- Poki
- GameDistribution
- Yandex
- CrazyGames
- FBistance
- And simulate AD flow in Defold editor


## Installation
You can use DefMath in your own project by adding this project as a [Defold library dependency](http://www.defold.com/manuals/libraries/). Open your game.project file and in the dependencies field under project add:

	https://github.com/subsoap/defads/archive/master.zip
  
Once added, you must require the main Lua module via

```
local DefAds = require("defads.defads")
```
Then you must init DefAds to use
```
local ids = {
	ironsource = {
		['apple'] = {
			app_key = "XXXXXXXX"
		},
		['google'] = {
			app_key = "XXXXXXXX"
		}
	},
	maxsdk = {
		['apple'] = {
			banner = 'XXXXXXXX',
			interstitial = 'XXXXXXXX',
			rewarded = 'XXXXXXXX'
		},
		['google'] = {
			banner ='XXXXXXXX',
			interstitial = 'XXXXXXXX',
			rewarded = 'XXXXXXXX'
		},
		['amazon'] = {
			banner ='XXXXXXXX',
			interstitial = 'XXXXXXXX',
			rewarded = 'XXXXXXXX'
		}
	}
}

local cbs = { 
	before_show = function, 
	after_show = function, 
	game_start = function, 
	game_stop, = function
	log_ad_event = function
}

local p = "amazon" 

DefAds.init(ids[,cbs][,p])
```
Interstitial ads:
```
DefAds.is_ads()
DefAds.load_ads()
DefAds.show_ads(on_close)
	-- on_close = function() end
```
Rewarded ads:
```
DefAds.is_rewarded()
DefAds.load_rewarded()
DefAds.show_rewarded(on_reward, on_close)
	-- on_reward = function() end
	-- on_close = function() end
```

