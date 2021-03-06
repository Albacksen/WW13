
/turf/proc/ReplaceWithLattice()
	ChangeTurf(get_base_turf_by_area(src))
	spawn()
		new /obj/structure/lattice( locate(x, y, z) )

// Removes all signs of lattice on the pos of the turf -Donkieyo
/turf/proc/RemoveLattice()
	var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
	if (L)
		qdel(L)

//Creates a new turf
/turf/proc/ChangeTurf(var/turf/N, var/tell_universe=1, var/force_lighting_update = FALSE)
	if (!N)
		return

	// This makes sure that turfs are not changed to space when one side is part of a zone

	var/obj/fire/old_fire = fire
	var/old_opacity = opacity
	var/old_dynamic_lighting = dynamic_lighting
	var/list/old_affecting_lights = affecting_lights
	var/old_lighting_overlay = lighting_overlay
	var/list/old_lighting_corners = corners


	if (ispath(N, /turf/floor))
		var/turf/W = new N( locate(x, y, z) )
		if (istype(W, /turf/floor/plating/grass))
			switch (season)
				if ("WINTER")
					W.color = DEAD_COLOR
				if ("SUMMER")
					W.color = SUMMER_COLOR
				if ("FALL")
					W.color = FALL_COLOR

		if (old_fire)
			fire = old_fire

		if (istype(W,/turf/floor))
			W.RemoveLattice()


		W.levelupdate()
		. = W

	else

		var/turf/W = new N( locate(x, y, z) )

		if (old_fire)
			old_fire.RemoveFire()

		W.levelupdate()
		. =  W

	lighting_overlay = old_lighting_overlay
	affecting_lights = old_affecting_lights
	corners = old_lighting_corners

	for (var/atom/A in contents)
		if (A.light)
			A.light.force_update = TRUE

	for (var/i = TRUE to 4)//Generate more light corners when needed. If removed - pitch black shuttles will come for your soul!
		if (corners[i]) // Already have a corner on this direction.
			continue
		corners[i] = new/datum/lighting_corner(src, LIGHTING_CORNER_DIAGONAL[i])

	if ((old_opacity != opacity) || (dynamic_lighting != old_dynamic_lighting) || force_lighting_update)
		reconsider_lights()

	if (dynamic_lighting != old_dynamic_lighting)
		if (dynamic_lighting)
			lighting_build_overlay()
		else
			lighting_clear_overlay()

	fix_broken_daylights()