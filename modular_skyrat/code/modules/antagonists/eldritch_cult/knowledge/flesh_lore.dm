/datum/eldritch_knowledge/base_flesh
	name = "Principle of Hunger"
	desc = "Opens up the path of flesh to you. Allows you to create a Flesh Blade at a cost of 1 charge."
	gain_text = "Hundred's of us starved, but I.. I found the strength in my greed."
	banned_knowledge = list(/datum/eldritch_knowledge/base_ash,/datum/eldritch_knowledge/base_rust,/datum/eldritch_knowledge/final/ash_final,/datum/eldritch_knowledge/final/rust_final)
	next_knowledge = list(/datum/eldritch_knowledge/flesh_grasp)
	charges_needed = 1
	result_atoms = list(/obj/item/melee/sickly_blade/flesh)
	cost = 1
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_ghoul
	name = "Imperfect Ritual"
	desc = "Allows you to resurrect the dead as voiceless dead by transmuting them on the rune, it costs 2 charges to do so, and you can only have 3 ghouls at a time."
	gain_text = "I found notes.. notes of a ritual, it was unfinished and yet i still did it."
	cost = 2
	charges_needed = 1
	next_knowledge = list(/datum/eldritch_knowledge/flesh_mark,/datum/eldritch_knowledge/armor,/datum/eldritch_knowledge/ashen_eyes)
	route = PATH_FLESH
	var/max_amt = 3
	var/current_amt = 0
	var/list/ghouls = list()

/datum/eldritch_knowledge/flesh_ghoul/on_finished_recipe(mob/living/user,mob/living/carbon/human/buckled,loc)
	var/mob/living/carbon/human/humie = new(loc)
	humie.setMaxHealth(75)
	humie.health = 75 // Voiceless dead are much tougher than ghouls
	humie.become_husk()
	humie.faction |= "heretics"
	ADD_TRAIT(humie,TRAIT_MUTE,type)
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [humie.real_name], a ghoul warrior", ROLE_HERETIC, null, ROLE_HERETIC, 50,humie)
	if(!LAZYLEN(candidates))
		qdel(humie)
		return FALSE
	var/mob/dead/observer/C = pick(candidates)
	humie.ghostize(0)
	humie.key = C.key

	log_game("[key_name_admin(humie)] has become a ghoul warrior, their master is [user.real_name]")
	
	var/datum/antagonist/heretic_monster/heretic_monster = humie.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_monster.set_owner(master)
	RegisterSignal(humie,COMSIG_MOB_DEATH,.proc/remove_ghoul)
	ghouls += humie

/datum/eldritch_knowledge/flesh_ghoul/proc/remove_ghoul(datum/source)
	var/mob/living/carbon/human/humie = source
	ghouls -= humie
	humie.mind.remove_antag_datum(/datum/antagonist/heretic_monster)
	UnregisterSignal(source,COMSIG_MOB_DEATH)

/datum/eldritch_knowledge/flesh_grasp
	name = "Grasp of Flesh"
	gain_text = "My new found desire, it drove me to do great things! The Priest said."
	desc = "Empowers your mansus grasp to be able to extract a piece of flesh from a dead person, creating a ghoul warrior to serve by your side, you can only have 2 ghoul warriors at a time."
	cost = 5
	next_knowledge = list(/datum/eldritch_knowledge/flesh_ghoul)
	var/ghoul_amt = 2
	var/list/spooky_scaries
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_grasp/on_mansus_grasp(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!ishuman(target) || target == user)
		return
	var/mob/living/carbon/human/human_target = target
	var/datum/status_effect/eldritch/eldritch_effect = human_target.has_status_effect(/datum/status_effect/eldritch/rust) || human_target.has_status_effect(/datum/status_effect/eldritch/ash) || human_target.has_status_effect(/datum/status_effect/eldritch/flesh)
	if(eldritch_effect)
		. = TRUE
		eldritch_effect.on_effect()
		if(ishuman(target))
			var/mob/living/carbon/human/htarget = target
			htarget.bleed_rate += 10

	if(QDELETED(human_target) || human_target.stat != DEAD)
		return
	
	if(!do_mob(user,human_target,10 SECONDS))
		return

	var/mob/living/carbon/human/humie = new(get_turf(target))
	humie.fully_replace_character_name(null,"Ghoul Warrior")
	humie.setMaxHealth(50)
	humie.health = 50 // Voiceless dead are much tougher than ghouls
	humie.become_husk()
	humie.faction |= "heretics"
	var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [humie.real_name], a voiceless dead", ROLE_HERETIC, null, ROLE_HERETIC, 50,humie)
	if(!LAZYLEN(candidates))
		return
	var/mob/dead/observer/C = pick(candidates)
	humie.ghostize(0)
	humie.key = C.key

	log_game("[key_name_admin(humie)] has become a ghoul warrior, their master is [user.real_name]")
	
	var/datum/antagonist/heretic_monster/heretic_monster = humie.mind.add_antag_datum(/datum/antagonist/heretic_monster)
	var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
	heretic_monster.set_owner(master)
	RegisterSignal(humie,COMSIG_MOB_DEATH,.proc/remove_ghoul)
	spooky_scaries += humie

/datum/eldritch_knowledge/flesh_grasp/proc/remove_ghoul(datum/source)
	var/mob/living/carbon/human/humie = source
	spooky_scaries -= humie
	humie.mind.remove_antag_datum(/datum/antagonist/heretic_monster)
	UnregisterSignal(source, COMSIG_MOB_DEATH)

/datum/eldritch_knowledge/flesh_mark
	name = "Mark of flesh"
	gain_text = "I saw them, the marked ones. The screams.. the silence."
	desc = "Your sickly blade now applies mark of flesh status effect. To proc the mark, use your mansus grasp on the marked. Mark of flesh when procced causeds additional bleeding."
	cost = 10
	next_knowledge = list(/datum/eldritch_knowledge/summon/raw_prophet)
	banned_knowledge = list(/datum/eldritch_knowledge/rust_mark,/datum/eldritch_knowledge/ash_mark)
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_mark/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(isliving(target))
		var/mob/living/living_target = target
		living_target.apply_status_effect(/datum/status_effect/eldritch/flesh)

/datum/eldritch_knowledge/flesh_blade_upgrade
	name = "Bleeding Steel"
	gain_text = "It rained blood, that's when i understood the gravekeeper's advice."
	desc = "Your blade will now cause additional bleeding."
	cost = 10
	next_knowledge = list(/datum/eldritch_knowledge/summon/stalker)
	banned_knowledge = list(/datum/eldritch_knowledge/ash_blade_upgrade,/datum/eldritch_knowledge/rust_blade_upgrade)
	route = PATH_FLESH

/datum/eldritch_knowledge/flesh_blade_upgrade/on_eldritch_blade(target,user,proximity_flag,click_parameters)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.bleed_rate+= 2

/datum/eldritch_knowledge/summon/raw_prophet
	name = "Raw Ritual"
	gain_text = "Uncanny man, walks alone in the valley, I was able to call his aid."
	desc = "You can now summon a Raw Prophet at a cost of 2 charges. They are one eyed messengers of King of Arms, having increased vision range, xray and telepathy."
	cost = 5
	charges_needed = 2
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/raw_prophet
	next_knowledge = list(/datum/eldritch_knowledge/flesh_blade_upgrade,/datum/eldritch_knowledge/spell/blood_siphon,/datum/eldritch_knowledge/curse/paralysis)
	route = PATH_FLESH

/datum/eldritch_knowledge/summon/stalker
	name = "Lonely Ritual"
	gain_text = "I was able to combine my greed and desires to summon an eldritch beast i have not seen before."
	desc = "You can now summon a Stalker at a cost of 3 charges. They are monstrous creatures that have the ability to blend into the sorounding and fry nearby electronics."
	cost = 5
	charges_needed = 3
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/stalker
	next_knowledge = list(/datum/eldritch_knowledge/summon/ashy,/datum/eldritch_knowledge/summon/rusty,/datum/eldritch_knowledge/final/flesh_final)
	route = PATH_FLESH

/datum/eldritch_knowledge/summon/ashy
	name = "Ashen Ritual"
	gain_text = "I combined principle of hunger with desire of destruction. The eyeful lords have noticed me."
	desc = "You can now summon an Ash Man at a cost of 2 charges. They are wandering souls, long forgotten stranded between the manse. They can wreck havoc on the living world but are fragile."
	cost = 5
	charges_needed = 2
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/ash_spirit
	next_knowledge = list(/datum/eldritch_knowledge/summon/stalker,/datum/eldritch_knowledge/spell/rust_wave)

/datum/eldritch_knowledge/summon/rusty
	name = "Rusted Ritual"
	gain_text = "I combined principle of hunger with desire of corruption. The rusted hills call my name."
	desc = "You can now summon a Rust Walker at a cost of 2 charges. They are powerful machinas of long past, cast away.. forgotten. They can turn turfs to rust and passively heal while on them."
	cost = 5
	charges_needed = 2
	mob_to_summon = /mob/living/simple_animal/hostile/eldritch/rust_spirit
	next_knowledge = list(/datum/eldritch_knowledge/summon/stalker,/datum/eldritch_knowledge/spell/flame_birth)

/datum/eldritch_knowledge/spell/blood_siphon
	name = "Blood Siphon"
	gain_text = "Our blood is all the same after all, the owl told me."
	desc = "You gain a spell that drains enemies health and restores yours."
	cost = 5
	spell_to_add = /obj/effect/proc_holder/spell/targeted/touch/blood_siphon
	next_knowledge = list(/datum/eldritch_knowledge/summon/raw_prophet,/datum/eldritch_knowledge/spell/area_conversion)

/datum/eldritch_knowledge/final/flesh_final
	name = "Priest's Final Hymn"
	gain_text = "Man of this world. Hear me! For the time of the lord of arms has come!"
	desc = "To gain this spell you must sacrifice at least 5 people, and the ritual costs 5 charges. Ascend as a terror of the night prime or you can summon a regular terror of the night."
	cost = 15
	route = PATH_FLESH

/datum/eldritch_knowledge/final/flesh_final/on_finished_recipe(mob/living/user,mob/living/carbon/human/buckled,loc)
	var/alert_ = alert(user,"Do you want to ascend as the lord of the night or just summon a terror of the night?","...","Yes","No")
	user.SetImmobilized(10 HOURS) // no way someone will stand 10 hours in a spot, just so he can move while the alert is still showing.
	switch(alert_)
		if("No")
			var/mob/living/summoned = new /mob/living/simple_animal/hostile/eldritch/armsy(loc)
			message_admins("[summoned.name] is being summoned by [user.real_name] in [loc]")
			var/list/mob/dead/observer/candidates = pollCandidatesForMob("Do you want to play as a [summoned.real_name]", ROLE_HERETIC, null, ROLE_HERETIC, 100,summoned)
			user.SetImmobilized(0)
			if(LAZYLEN(candidates) == 0)
				to_chat(user,"<span class='warning'>No ghost could be found...</span>")
				qdel(summoned)
				return FALSE
			var/mob/dead/observer/ghost_candidate = pick(candidates)
			priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the dark, for vassal of arms has ascended! Terror of the night has come! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", 'sound/announcer/classic/spanomalies.ogg')
			log_game("[key_name_admin(ghost_candidate)] has taken control of ([key_name_admin(summoned)]).")
			summoned.ghostize(FALSE)
			summoned.key = ghost_candidate.key
			summoned.mind.add_antag_datum(/datum/antagonist/heretic_monster)
			var/datum/antagonist/heretic_monster/monster = summoned.mind.has_antag_datum(/datum/antagonist/heretic_monster)
			var/datum/antagonist/heretic/master = user.mind.has_antag_datum(/datum/antagonist/heretic)
			monster.set_owner(master)
			master.ascended = TRUE
		if("Yes")
			var/mob/living/summoned = new /mob/living/simple_animal/hostile/eldritch/armsy/prime(loc,TRUE,10)
			summoned.ghostize(0)
			user.SetImmobilized(0)
			priority_announce("$^@&#*$^@(#&$(@&#^$&#^@# Fear the dark, for Name of arms has ascended! Lord of the night has come! $^@&#*$^@(#&$(@&#^$&#^@#","#$^@&#*$^@(#&$(@&#^$&#^@#", 'sound/announcer/classic/spanomalies.ogg')
			log_game("[user.real_name] ascended as [summoned.real_name]")
			var/mob/living/carbon/carbon_user = user
			var/datum/antagonist/heretic/ascension = carbon_user.mind.has_antag_datum(/datum/antagonist/heretic)
			ascension.ascended = TRUE
			carbon_user.mind.transfer_to(summoned, TRUE)
			carbon_user.gib()

	return ..()
