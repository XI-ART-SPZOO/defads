# DefAds
A module with a set of multiplatfoorm ads functions for Defold

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

