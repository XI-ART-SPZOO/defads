local ad_ids = {}

local M = {
	supported_apis = {},
	reward = nil,
	fbinstant = {
		rewarded = { id = 0, ready = false },
		interstitial = { id = 0, ready = false }
	},
	mediate = false,
	mediation = { list = { "ironsource" }, counter = 1, providers = { "ironsource" } },
	before_show = function() end,
	after_show = function() end,
	is_show_ads_n = 3,
	is_show_ads_time = 0,
	is_show_ads_dtime = 300,
	game_start = function() end,
	game_stop = function() end,
	log_ad_revenue = function() end
}

local function i_closed(inc) 
	M.after_show()
	if M.onComplete then M.onComplete(); M.onComplete = nil end; M.load_ads() 
end

local function r_earned() 
	if M.onReward then 
		M.reward = M.onReward(M.reward_source)
		M.onReward = nil 
	end 
end

local function r_closed() 
	M.after_show()
	if M.onComplete then 
		M.onComplete( M.reward )
		M.reward = nil
		M.onComplete = nil 
	end 
	M.load_rewarded() 
end

local function ads_after_init() 
	print("ADS:INIT --> LOAD ADS")
	M.load_ads()
	M.load_rewarded()
end

local function ironsource_listener(self, message_id, message)
	print("ADS:IS LISTENER",message_id, message)
	local function log_ad( m )
		if not m then return end
		local e = { 
			adplatform = "ironSource", 
			source = m.ad_network, 
			format = m.ad_unit, 
			unit_name = m.instance_name, 
			currency = "USD", 
			value = m.revenue 
		}
		-- instance_id = "ca-app-pub-7455545751289212/4693124441",
		-- instance_name = "Bidding", 		segment_name = "",
		-- precision = "BID", 				country = "PL",
		-- ad_unit = "interstitial", 		auction_id = "4c77bfb0-3448-11ee-92b5-17696b7ab2fe_1969848048",
		-- encrypted_cpm = "", 				ad_network = "admob",
		-- ab = "A", 						revenue = 0.121511903,
		-- event = 3, 						lifetime_revenue = 3.289511903
		if M.log_ad_revenue then M.log_ad_revenue( e ) end
	end
	if message_id == ironsource.MSG_INIT then
		if message.event == ironsource.EVENT_INIT_COMPLETE then 
			print("ADS:IS --> Ironsource initialized!")
			if _DEBUG then pprint(ironsource.validate_integration()) end
			ads_after_init() 
			if not Data.Options:get("consent") then 
				ironsource.load_consent_view("pre")
				Data.Options:set("consent",true)
				Data.Options:save()
			end
		end
	elseif message_id == ironsource.MSG_REWARDED then
		if message.event == ironsource.EVENT_AD_AVAILABLE then
		elseif message.event == ironsource.EVENT_AD_UNAVAILABLE then
		elseif message.event == ironsource.EVENT_AD_OPENED then
		elseif message.event == ironsource.EVENT_AD_CLOSED then 
			r_closed()
		elseif message.event == ironsource.EVENT_AD_REWARDED then 
			r_earned()
			log_ad( message )
		elseif message.event == ironsource.EVENT_AD_SHOW_FAILED then
		elseif message.event == ironsource.EVENT_AD_CLICKED then
		end
	elseif message_id == ironsource.MSG_INTERSTITIAL then
		if message.event == ironsource.EVENT_AD_READY then
		elseif message.event == ironsource.EVENT_AD_LOAD_FAILED then
		elseif message.event == ironsource.EVENT_AD_OPENED then
		elseif message.event == ironsource.EVENT_AD_CLOSED then
			i_closed()
		elseif message.event == ironsource.EVENT_AD_SHOW_FAILED then
		elseif message.event == ironsource.EVENT_AD_CLICKED then
		elseif message.event == ironsource.EVENT_AD_SHOW_SUCCEEDED then 
			log_ad( message )
		end
	elseif message_id == ironsource.MSG_CONSENT then
		if message.event == ironsource.EVENT_CONSENT_LOADED then 
			ironsource.show_consent_view("pre") -- Consent View was loaded successfully -- massage.consent_view_type
		elseif message.event == ironsource.EVENT_CONSENT_SHOWN then -- Consent view was displayed successfully -- massage.consent_view_type
		elseif message.event == ironsource.EVENT_CONSENT_LOAD_FAILED then -- Consent view was failed to load -- massage.consent_view_type, massage.error_code, massage.error_message
		elseif message.event == ironsource.EVENT_CONSENT_SHOW_FAILED then -- Consent view was not displayed, due to error -- massage.consent_view_type, massage.error_code, massage.error_message
		elseif message.event == ironsource.EVENT_CONSENT_ACCEPTED then 
			ironsource.request_idfa() -- The user pressed the Settings or Next buttons -- massage.consent_view_type
		elseif message.event == ironsource.EVENT_CONSENT_DISMISSED then -- The user dismiss consent -- massage.consent_view_type
		end
	elseif message_id == ironsource.MSG_IDFA then
		if message.event == ironsource.EVENT_STATUS_AUTHORIZED then -- ATTrackingManagerAuthorizationStatusAuthorized
		elseif message.event == ironsource.EVENT_STATUS_DENIED then -- ATTrackingManagerAuthorizationStatusDenied
		elseif message.event == ironsource.EVENT_STATUS_NOT_DETERMINED then -- ATTrackingManagerAuthorizationStatusNotDetermined
		elseif message.event == ironsource.EVENT_STATUS_RESTRICTED then -- ATTrackingManagerAuthorizationStatusRestricted
		elseif message.event == ironsource.EVENT_NOT_SUPPORTED then -- IDFA request not supported on this platform or OS version
		end
	end
end

local function maxsdk_listener(self, message_id, message)
	print("ADS:MAX LISTENER", message_id, message)
	if message_id == maxsdk.MSG_INITIALIZATION then 
		ads_after_init()
	elseif message_id == maxsdk.MSG_INTERSTITIAL then
		if message.event == maxsdk.EVENT_CLOSED then 
			i_closed() --print("EVENT_CLOSED: Interstitial AD closed")
		elseif message.event == maxsdk.EVENT_CLICKED then -- print("EVENT_CLICKED: Interstitial AD clicked")
		elseif message.event == maxsdk.EVENT_FAILED_TO_SHOW then -- print("EVENT_FAILED_TO_SHOW: Interstitial AD failed to show", message.code, message.error)
		elseif message.event == maxsdk.EVENT_OPENING then -- print("EVENT_OPENING: Interstitial AD is opening")
		elseif message.event == maxsdk.EVENT_FAILED_TO_LOAD then -- print("EVENT_FAILED_TO_LOAD: Interstitial AD failed to load", message.code, message.error)
		elseif message.event == maxsdk.EVENT_LOADED then -- print("EVENT_LOADED: Interstitial AD loaded. Network:", message.network)
		elseif message.event == maxsdk.EVENT_NOT_LOADED then -- print("EVENT_NOT_LOADED: can't call show_interstitial() before EVENT_LOADED", message.code, message.error)
		elseif message.event == maxsdk.EVENT_REVENUE_PAID then -- print("EVENT_REVENUE_PAID: Interstitial AD revenue: ", message.revenue, message.network)
		end
	elseif message_id == maxsdk.MSG_REWARDED then
		if message.event == maxsdk.EVENT_CLOSED then 
			r_closed() -- print("EVENT_CLOSED: Rewarded AD closed")
		elseif message.event == maxsdk.EVENT_FAILED_TO_SHOW then -- print("EVENT_FAILED_TO_SHOW: Rewarded AD failed to show", message.code, message.error)
		elseif message.event == maxsdk.EVENT_OPENING then -- print("EVENT_OPENING: Rewarded AD is opening")
		elseif message.event == maxsdk.EVENT_FAILED_TO_LOAD then -- print("EVENT_FAILED_TO_LOAD: Rewarded AD failed to load", message.code, message.error)
		elseif message.event == maxsdk.EVENT_LOADED then -- print("EVENT_LOADED: Rewarded AD loaded. Network:", message.network)
		elseif message.event == maxsdk.EVENT_NOT_LOADED then -- print("EVENT_NOT_LOADED: can't call show_rewarded() before EVENT_LOADED", message.code, message.error)
		elseif message.event == maxsdk.EVENT_EARNED_REWARD then 
			r_earned() -- print("EVENT_EARNED_REWARD: Reward: ", message.amount, message.type)
		elseif message.event == maxsdk.EVENT_REVENUE_PAID then -- print("EVENT_REVENUE_PAID: Rewarded AD revenue: ", message.revenue, message.network)
		end
	elseif message_id == maxsdk.MSG_BANNER then
		if message.event == maxsdk.EVENT_LOADED then -- print("EVENT_LOADED: Banner AD loaded. Network:", message.network)
		elseif message.event == maxsdk.EVENT_OPENING then -- print("EVENT_OPENING: Banner AD is opening")
		elseif message.event == maxsdk.EVENT_FAILED_TO_LOAD then -- print("EVENT_FAILED_TO_LOAD: Banner AD failed to load", message.code, message.error)
		elseif message.event == maxsdk.EVENT_FAILED_TO_SHOW then -- print("EVENT_FAILED_TO_SHOW: Banner AD failed to show", message.code, message.error)
		elseif message.event == maxsdk.EVENT_EXPANDED then -- print("EVENT_EXPANDED: Banner AD expanded")
		elseif message.event == maxsdk.EVENT_COLLAPSED then -- print("EVENT_COLLAPSED: Banner AD coppalsed")
		elseif message.event == maxsdk.EVENT_CLICKED then -- print("EVENT_CLICKED: Banner AD clicked")
		elseif message.event == maxsdk.EVENT_CLOSED then -- print("EVENT_CLOSED: Banner AD closed")
		elseif message.event == maxsdk.EVENT_DESTROYED then -- print("EVENT_DESTROYED: Banner AD destroyed")
		elseif message.event == maxsdk.EVENT_NOT_LOADED then -- print("EVENT_NOT_LOADED: can't call show_banner() before EVENT_LOADED", message.code, message.error)
		elseif message.event == maxsdk.EVENT_REVENUE_PAID then -- print("EVENT_REVENUE_PAID: Banner AD revenue: ", message.revenue, message.network)
		end
	end
end

function M.restore()
end

function M.init(ids,cbs,p) -- cbs = { before_show, after_show, game_start, game_stop, log_ad_event }
	ad_ids = ids

	if p then 
	else
		local s = sys.get_sys_info().system_name
		if s=="HTML5" then 
		elseif s=="Android" then p = "google"
		elseif s=="iPhone OS" then p = "apple"
		end
		if not p then
			if yagames then p = "yagames" 
			elseif gdsdk then p = "gdsdk" 
			elseif crazy_games then p = "crazygames"
			elseif fbinstant then p = "instant" 
			elseif poki_sdk then p = "poki" 
			end
		end
	end
	M.adplatform = p or "none"
	print("ADS:ADS --> Init ADS with adplatform =", M.adplatform)

	M.before_show = p.before_show or M.before_show
	M.after_show = p.after_show or M.after_show
	M.initialized = true

	if maxsdk then 
		print("ADS:INIT --> Init maxsdk")
		maxsdk.set_fb_data_processing_options("LDU", 0, 0)
		maxsdk.set_has_user_consent(true) -- GDPR
		maxsdk.set_is_age_restricted_user(false)
		maxsdk.set_do_not_sell(false) -- CCPA for all others mediated networks
		maxsdk.set_muted(false)
		maxsdk.set_verbose_logging(true)
		maxsdk.set_callback(maxsdk_listener)
		maxsdk.initialize()
	end

	if ironsource then 
		print("ADS:INIT --> Init ironsource")
		local app_key = ad_ids.ironsource[M.adplatform].app_key
		ironsource.set_callback(ironsource_listener)
		ironsource.set_consent(true)
		if _DEBUG then
			ironsource.set_adapters_debug(true)
			ironsource.set_metadata("is_test_suite", "enable")
		end
		ironsource.init(app_key)
	end

	if fbinstant then
		print("ADS:INIT --> Init fbinstant")
		local apis = json.decode(fbinstant.get_supported_apis())
		for api,_ in pairs(apis) do
			M.supported_apis[api] = true
		end
		ads_after_init()
	end

	if yagames then
		M.yagames = true
	elseif M.adplatform=="crazygames" then
		M.crazygames = true
		crazy_games.init()  
		crazy_games.init_listeners()  
		crazy_games.add_event_listeners()
		-- crazy_games.clear_event_listeners()
		M.game_start = function() crazy_games.gameplay_start() end
		M.game_stop = function()crazy_games.gameplay_stop() end
		jstodef.add_listener(function(_, message_id, message)  
			if (message_id == "CrazyGame_adStared") then  
				M.before_show(message)
			elseif (message_id == "CrazyGame_adFinished") then  
				r_earned(); r_closed()
			elseif (message_id == "CrazyGame_adError") then  
				r_closed()
			end
		end)
	elseif M.adplatform=="gdsdk" then
		M.gdsdk = true
		local listener = function(self, event, message)
			pprint("ADS:GD LISTENER", event, message)
			if event == gdsdk.SDK_GAME_PAUSE then M.before_show(message)
			elseif event == gdsdk.SDK_GAME_START then r_closed()
			elseif event == gdsdk.SDK_ERROR then r_closed()
			elseif event == gdsdk.SDK_REWARDED_WATCH_COMPLETE then r_earned()
			elseif event == gdsdk.AD_ERROR then r_closed()
			elseif event == gdsdk.AD_SDK_CANCELED then r_closed()
			end
		end
		gdsdk.set_listener(listener)
	elseif M.adplatform=="poki" then
		M.poki = true
		-- poki_sdk.gameplay_start()
		-- poki_sdk.gameplay_stop()
	end

	if M.adplatform == "none" then ads_after_init() end
	M.set_mediation()
end

function M.set_mediation(m,p)
	if not M.mediate and (M.adplatform=="apple" or M.adplatform=="google") and m then 
		M.mediation = { list = m, counter = 1, providers = p }
	else
		M.mediation = { list = { M.adplatform }, counter = 1, providers = { M.adplatform } }
	end
end

function M.set_show_ads(n)
	M.is_show_ads_n = n
end

function M.set_ads_dtime(t)
	M.is_show_ads_dtime = t
end

function M.is_show_ads(n)
	n = n or M.is_show_ads_n + 1
	local f = M.is_show_ads_time < os.time()
	return f and (M.is_show_ads_n<n) and (M.is_show_ads_n>0)
end

local show_helper = {
	rewarded = {
		maxsdk = function(sl) 
			sl("maxsdk"); maxsdk.show_rewarded() 
		end,
		ironsource = function(sl) 
			sl("ironsource"); ironsource.show_rewarded_video() 
		end,
	},
	ads = {
		maxsdk = function() 
			maxsdk.show_interstitial() 
		end,
		ironsource = function(sl) 
			ironsource.show_interstitial() 
		end
	}
} 

function M.show_next_mobile_ads( atype, sl, bs )
	local result = false
	local loaded = {
		maxsdk = atype=="rewarded" and (maxsdk and maxsdk.is_rewarded_loaded()) or (maxsdk and maxsdk.is_interstitial_loaded()),
		ironsource = atype=="rewarded" and (ironsource and ironsource.is_rewarded_video_available()) or (ironsource and ironsource.is_interstitial_ready()),
	}
	pprint("ADS: mediation.list", M.mediation.list)
	print("ADS: mediation.counter",M.mediation.counter)
	local current = M.mediation.list[M.mediation.counter]
	if current then
		if loaded[current] then
			bs()
			show_helper[atype][current](sl)
			M.mediation.counter = M.mediation.counter < #M.mediation.list and (M.mediation.counter + 1) or 1
			result = true
		else
			for i=1,#M.mediation.providers do
				local p = M.mediation.providers[i]
				if loaded[p] then 
					bs()
					show_helper[atype][p](sl)
					result = true
				end
				if result then break end
			end
		end
	end
	return result
end

function M.get_adplatform()
	return M.adplatform
end

function M.is_banner()
	return admob and admob.is_loaded('banner') or (M.adplatform=="none")
end

function M.is_ads()
	local f = (maxsdk and maxsdk.is_interstitial_loaded())
	f = f or (ironsource and ironsource.is_interstitial_ready())
	-- FBINSTANT
	f = f or M.fbinstant.interstitial.ready
	-- YAGAMES
	f = f or M.yagames
	-- GDSDK
	f = f or M.gdsdk
	-- POKI
	f = f or M.poki
	-- CRAZYGAMES
	f = f or M.crazygames
	-- OTHER
	f = f or (M.adplatform=="none")
	return f
end

function M.load_ads()
	if maxsdk and (not maxsdk.is_interstitial_loaded()) then 
		print("ADS:LOAD Load maxsdk interstitial:", ad_ids.maxsdk[M.adplatform].interstitial)
		maxsdk.load_interstitial(ad_ids.maxsdk[M.adplatform].interstitial)
	end
	if ironsource and (not ironsource.is_interstitial_ready()) then 
		print("ADS:LOAD Load ironsource interstitial")
		ironsource.load_interstitial()
	end
	if fbinstant and M.supported_apis["getInterstitialAdAsync"] and not M.fbinstant.interstitial.ready then
		print("ADS:LOAD FBINSTATNT GET interstitial")
		fbinstant.get_interstitial_ad(ad_ids.facebook.interstitial, function(s, id, error)
			if not error then
				M.fbinstant.interstitial.id = id
				print("ADS:LOAD FBINSTATNT LOAD interstitial ", id)
				fbinstant.load_interstitial_ad(id, function(s, success, error) 
					if success then
						M.fbinstant.interstitial.ready = true
					else print("ADS:SHOW FBINSTATNT LOAD interstitial ERROR: ", error) end
				end)
			else print("ADS:SHOW FBINSTATNT GET interstitial ERROR: ", error) end
		end)
	end
end

function M.show_ads( onComplete ) 
	print("ADS.SHOW: fbinstant =", binstant, ", yagames =", M.yagames)
	M.onComplete = onComplete
	if M.show_next_mobile_ads("ads", sl, M.before_show) then
		M.is_show_ads_time = os.time() + M.is_show_ads_dtime
	elseif fbinstant and M.fbinstant.interstitial.ready then
		M.before_show()
		fbinstant.show_interstitial_ad(M.fbinstant.interstitial.id, function(s, success, error) 
			if success then
			else print("ADS:SHOW FBINSTATNT SHOW interstitial ERROR: ", error) end
			M.fbinstant.interstitial.ready = false
			i_closed()
		end)
	elseif M.yagames then
		M.before_show()
		yagames.adv_show_fullscreen_adv({
			open = function(self) end,
			close = function(self, was_shown) i_closed(was_shown) end,
			offline = function(self) print("yagames.adv_show_fullscreen_adv: 'offline' event.") end,
			error = function(self, err) i_closed(not err); print("yagames.adv_show_fullscreen_adv error:", err) end
		})
	elseif M.crazygames then
		crazy_games.request_ad("midgame")
	elseif M.gdsdk then
		gdsdk.show_interstitial_ad()
	elseif M.poki then
		poki_sdk.commercial_break(function(self) i_closed("poki") end)
	elseif M.adplatform=="none" then
		M.before_show()
		print("ADS:SHOW INTERSTITIAL (FAKE)")
		timer.delay(1.99, false, function() i_closed() end)
	end
end

function M.is_rewarded()
	local f = (maxsdk and maxsdk.is_rewarded_loaded())
	f = f or (ironsource and ironsource.is_rewarded_video_available())
	-- FBINSTANT
	f = f or M.fbinstant.rewarded.ready
	-- YAGAMES
	f = f or M.yagames
	-- GDSDK
	f = f or M.gdsdk
	-- POKI
	f = f or M.poki
	-- CRAZYGAMES
	f = f or M.crazygames
	-- OTHER
	f = f or (M.adplatform=="none")
	return f
end

function M.load_rewarded()
	if maxsdk and (not maxsdk.is_rewarded_loaded()) then 
		maxsdk.load_rewarded(ad_ids.maxsdk[M.adplatform].rewarded)
	end
	if ironsource and (not ironsource.is_rewarded_video_available()) then 
	--
	end
	if fbinstant and M.supported_apis["getRewardedVideoAsync"] and not M.fbinstant.rewarded.ready then
		print("ADS:LOAD FBINSTATNT GET rewarded")
		fbinstant.get_rewarded_video(ad_ids.facebook.rewarded, function(s, id, error)
			if not error then
				M.fbinstant.rewarded.id = id
				print("ADS:LOAD FBINSTATNT LOAD rewarded ", id)
				fbinstant.load_rewarded_video(id, function(s, success, error) 
					if success then
						M.fbinstant.rewarded.ready = true
					else print("ADS:LOAD FBINSTATNT LOAD rewarded ERROR: ", error) end
				end)
			else print("ADS:LOAD FBINSTATNT GET rewarded ERROR: ", error) end
		end)
	end
end

function M.show_rewarded(onReward, onComplete) 
	print("ADS:SHOW rewarded: fbinstant =", fbinstant, ", yagames =", M.yagames)
	local function sl(s) M.reward_source = s; M.onComplete = onComplete; M.onReward = onReward end
	if M.show_next_mobile_ads("rewarded", sl, M.before_show) then
	elseif fbinstant and M.fbinstant.rewarded.ready then
		M.before_show()
		sl("fbinstant")
		fbinstant.show_rewarded_video(M.fbinstant.rewarded.id, function(s, success, error) 
			if success then
				print("ADS:SHOW FBINSTATNT SHOW rewarded: ", success)
				r_earned()
			else print("ADS:SHOW FBINSTATNT SHOW rewarded ERROR: ", error) end
			M.fbinstant.rewarded.ready = false
			r_closed()
		end)
	elseif M.yagames then
		sl("yagames")
		M.before_show()
		pcall(function() 
			yagames.adv_show_rewarded_video({
				open = function(self) end,
				rewarded = function(self) r_earned() end,
				close = function(self) r_closed() end,
				error = function(self, err) r_closed(); print("yagames.adv_show_rewarded_video error", err) end
			}) 
		end)
	elseif M.crazygames then
		sl("crazygames")
		crazy_games.request_ad("rewarded")
	elseif M.gdsdk then
		sl("gdsdk")
		gdsdk.show_rewarded_ad()
	elseif M.poki then
		sl("poki")
		poki_sdk.commercial_break(function(self) r_earned(); r_closed("poki") end)
	elseif M.adplatform=="none" then
		-- if Target.name()=="NONE" then sl(); r_earned(); r_closed() end
		M.before_show()
		print("ADS:SHOW REWARDED (FAKE)")
		sl("none")
		timer.delay(1.99, false, function() r_earned(); r_closed() end)
	end
end

return M