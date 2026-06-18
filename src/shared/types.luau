local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jecs = require(ReplicatedStorage.Packages.jecs)

local types = {}

export type GoalEvent = {
	hit: jecs.Entity | number,
	net: jecs.Entity | number,
	rink: jecs.Entity | number,
}

export type InputCommand = {
	shove: boolean,
	celebrate: boolean,
	drop_puck: boolean,
	mouse_lock: boolean,
	start_slapshot: boolean,
	cancel_slapshot: boolean,
	pressed_lying_block: boolean,
	power_reset: boolean,
	double_pokecheck: boolean,
	pokecheck: number?,
	power: number?,
	sprint: number?,
	glide_left: number?,
	glide_right: number?,
	raise_hand: number?,
	slapshot: number?,
	low_tip: number?,
	high_tip: number?,
	standing_block: number?,
	lying_block: number?,
	kneel_block: number?,
	fake_shot: number?,
	chip_shot: number?,
	wrist_shot: number?,
	sprinting: boolean,
}

export type HitDataServer = {
	rink_entity: jecs.Entity,
	player1: Player,
	player2: Player,
	part: BasePart,
	start: number,
	duration: number,
	power: number,
	start_position: Vector3,
	distance_from_puck: number,
}

export type HitTrackerInfo = {
	player1_name: string,
	player2_name: string,
	power: number,
	hit_distance: number,
	distance_from_puck: number,
	penalty: boolean,
}

export type IsHitData = {
	start: number,
	duration: number,
	shove: boolean,
}

export type SoundEvent = {
	part: Instance,
	sound_path: Folder,
	volume: number,
	length: number,
}

export type Lifetime = {
	duration: number,
	created: number,
}

export type StickStateMachine = {
	debug: boolean,
	current: string,
	busy: boolean,
	previous: string,
	active: boolean,
	GRACE_TIME: number,
	GRACE_DURATION: number,
	BLEND_DURATION: number,
	tick: number,
}

export type Power = {
	value: number,
	max: number,
	rate: number,
}

export type PlayerConfig = {
	shiftlock: boolean,
}

export type RoundState = {
	processed: boolean,
}

export type RoundTimer = {
	timestamp: number,
	duration: number,
}

export type Faceoff = {
	center: BasePart,
	home_pad: BasePart,
	away_pad: BasePart,
	billboard_gui: BillboardGui,
	text_label: TextLabel,
	home_ready: boolean,
	away_ready: boolean,
}

export type Uniform = {
	jersey: string,
	pants: string,
}

--[[
	name = "San Jose Sharks",
	Abbreviation = "SJS",
	logo = "rbxassetid://474197824",

	Uniforms = {
		Home = {
			Jerseys = {
				9432246689,
			},
			Pants = {
				9432248283,
			},
		},

		Away = {
			Jerseys = {
				9432248063,
			},
			Pants = {
				9432248283,
			},
		},
	},

	Horn = {
		SoundId = "rbxassetid://5818699832",
		Volume = 1,
		StartTime = 1,
	},]]

export type SoundData = {
	sound: Sound,
	volume: number,
	time_position: number,
}

export type SelectedTeamData = {
	name: string,
	abbreviation: string,
	logo: string,
	horn: SoundData,

	uniforms: {
		home: {
			jerseys: { string },
			pants: { string },
		},

		away: {
			jerseys: { string },
			pants: { string },
		},
	},

	colors: PrimaryColors,
}

export type PrimaryColors = {
	primary: Color3,
	auxillary: Color3,
	tertiary: Color3,
}

export type TrackingData = {
	part: BasePart,
	dist: number,
	cframe: CFrame,
}

export type ThreatData = {
	threat: string,
	poke: boolean,
	dist: number,
}

export type StateStruct = {
	Name: string,
	onEnter: (context: StickStateMachine, jecs.Entity, jecs.World) -> (),
	onExit: (jcontext: StickStateMachine, jecs.Entity, jecs.World) -> (),
	onUpdate: (context: StickStateMachine, jecs.Entity, jecs.World, number) -> (),
}

export type ChatEvent = {
	event: () -> (number, string, Player?),
	disconnect: () -> (),
}

export type ShotEvent = {
	entity: jecs.Entity,
	power: number,
	wrist: boolean,
	fake: boolean,
	chip: boolean,
}

export type Shot = {
	created: number,
	ray_result: RaycastResult,
}

export type ShotHitNet = {
	origin: Vector3,
	direction: Vector3,
	ray_result: RaycastResult,
	fake: boolean,
}

export type GoalieReacting = {
	created: number,
	duration: number,
}

export type GoalieStateMachine = {
	debug: boolean,
	current: string,
	busy: boolean,
	previous: string,
	active: boolean,
	GRACE_TIME: number,
	GRACE_DURATION: number,
	BLEND_DURATION: number,
	tick: number,
}

export type MoveTo = {
	part_to_move: BasePart,
	cframe: CFrame,
	speed: number,
}

export type Stamina = {
	current: number,
	total: number,
	regen_rate: number,
}

return types
