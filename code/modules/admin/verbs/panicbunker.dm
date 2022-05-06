/client/proc/panicbunker()
	set category = "Server"
	set name = "Toggle Panic Bunker"
	if (!CONFIG_GET(flag/sql_enabled))
		to_chat(usr, SPAN_ADMINNOTICE("The Database is not enabled!"), confidential = TRUE)
		return

	var/new_pb = !CONFIG_GET(flag/panic_bunker)
	var/interview = CONFIG_GET(flag/panic_bunker_interview)
	var/discord_required = CONFIG_GET(flag/panic_bunker_discord_require)
	var/time_rec = 0
	var/message = ""
	if(new_pb)
		time_rec = input(src, "How many living minutes should they need to play?", "Shit's fucked isn't it", CONFIG_GET(number/panic_bunker_living)) as num
		message = input(src, "What should they see when they log in?", "MMM", CONFIG_GET(string/panic_bunker_message)) as text
		message = replacetext(message, "%minutes%", time_rec)
		CONFIG_SET(number/panic_bunker_living, time_rec)
		CONFIG_SET(string/panic_bunker_message, message)

		var/interview_sys = tgui_alert(usr, "Should the interview system be enabled? (Allows players to connect under the hour limit and force them to be manually approved to play)", "Enable interviews?", list("Enable", "Disable"))
		interview = interview_sys == "Enable"
		CONFIG_SET(flag/panic_bunker_interview, interview)

		var/require_discord = tgui_alert(usr, "Should connecting be restricted to accounts with a valid Discord link?", "Enable Discord Requirement?", list("Enable", "Disable"))
		discord_required = require_discord == "Enable"
		CONFIG_SET(flag/panic_bunker_discord_require, discord_required)

	CONFIG_SET(flag/panic_bunker, new_pb)
	log_admin("[key_name(usr)] has toggled the Panic Bunker, it is now [new_pb ? "on and set to [time_rec] with a message of [message]. The interview system is [interview ? "enabled" : "disabled"]" : "off"].")
	message_admins("[key_name_admin(usr)] has toggled the Panic Bunker, it is now [new_pb ? "enabled with a living minutes requirement of [time_rec]. The interview system is [interview ? "enabled" : "disabled"]" : "disabled"].")
	if (new_pb && !SSdbcore.Connect())
		message_admins("The Database is not connected! Panic bunker will not work until the connection is reestablished.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Panic Bunker", "[new_pb ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_interviews()
	set category = "Server"
	set name = "Toggle PB Interviews"
	if (!CONFIG_GET(flag/panic_bunker))
		to_chat(usr, SPAN_ADMINNOTICE("NOTE: The panic bunker is not enabled, so this change will not effect anything until it is enabled."), confidential = TRUE)
	var/new_interview = !CONFIG_GET(flag/panic_bunker_interview)
	CONFIG_SET(flag/panic_bunker_interview, new_interview)
	log_admin("[key_name(usr)] has toggled the Panic Bunker's interview system, it is now [new_interview ? "enabled" : "disabled"].")
	message_admins("[key_name(usr)] has toggled the Panic Bunker's interview system, it is now [new_interview ? "enabled" : "disabled"].")

/client/proc/toggle_require_discord()
	set category = "Server"
	set name = "Toggle PB Discord Requirement"
	if (!CONFIG_GET(flag/panic_bunker))
		to_chat(usr, "<span class='adminnotice'>NOTE: The panic bunker is not enabled, so this change will not affect anything until it is enabled.</span>", confidential = TRUE)
	var/new_state = !CONFIG_GET(flag/panic_bunker_discord_require)
	CONFIG_SET(flag/panic_bunker_discord_require, new_state)
	var/logmessage = "has toggled the Panic Bunker's Multifactor Auth System, it is now [new_state ? "enabled" : "disabled"]."
	log_admin("[key_name(usr)] [logmessage]")
	message_admins("[key_name(usr)] [logmessage]")
