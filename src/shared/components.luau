--!nocheck
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local jecs = require(ReplicatedStorage.Packages.jecs)
local replecs = require(ReplicatedStorage.Packages.replecs)
local world = require(ReplicatedStorage.Shared.world)

local T = require(ReplicatedStorage.Shared.types)

type Id<Type = nil> = number & { __T: Type }

local components = {}

-- Definitions
components.IsA = world:entity()

components.Model = world:component() :: Id<Model>
components.BasePart = world:component() :: Id<BasePart>
components.Renderable = world:component() :: Id<PVInstance>
components.Instance = world:component() :: Id<Instance>
components.Tool = world:component() :: Id<Tool>
components.Transform = world:component() :: Id<CFrame>
components.Humanoid = world:component() :: Id<Humanoid>
components.Player = world:component() :: Id<Player>
components.Character = world:entity()
components.Reconcile = world:entity()
components.Previous = world:entity()
components.UUID = world:component() :: Id<string>

components.LocalPlayer = world:component()
components.LocalCharacter = world:component()
components.PlayerConfig = world:component() :: Id<T.PlayerConfig>

components.MoveTo = world:component() :: Id<T.MoveTo>
components.Destroy = world:entity()
components.Connection = world:component()
components.Touched = world:entity()
components.Interpolated = world:entity()
components.Interpolate = world:entity()
components.PivotTo = world:component() :: Id<CFrame>
components.Lifetime = world:component() :: Id<T.Lifetime>
components.Timer = world:entity()
components.AnimationTrack = world:component()
components.EquippedOn = world:entity()
components.Unequip = world:entity()

components.Rink = world:entity()
components.Net = world:entity()
components.Goalie = world:entity()
components.Puck = world:entity()
components.Ghost = world:component() :: Id<BasePart>
components.Stick = world:entity()

components.CurrentParticipant = world:entity()
components.BelongsToRink = world:entity()
components.BelongsToTeam = world:entity()
components.ParticipantOf = world:entity()
components.Owner = world:entity()
components.PreviousOwner = world:component()
components.Team = world:component() :: Id<Team>
components.Score = world:component() :: Id<number>
components.Scoreboard = world:entity()
components.Active = world:entity()
components.Stamina = world:component() :: Id<number>
components.Sprinting = world:entity()
components.Benched = world:entity()
components.Cooldown = world:component()
components.CanCelebrate = world:component()
components.PreventCollect = world:entity()
components.MovementDisabled = world:entity()
components.ForceLock = world:component()

components.PlayState = world:entity()
components.RoundTimer = world:component() :: Id<T.RoundTimer>
components.RoundActive = world:component() :: Id<T.RoundState>
components.RoundGoal = world:component() :: Id<T.RoundState>
components.RoundFaceoff = world:component() :: Id<T.RoundState>
components.RoundOutOfBounds = world:component() :: Id<T.RoundState>
components.RoundReset = world:component() :: Id<T.RoundState>
components.RoundStart = world:component() :: Id<T.RoundState>
components.RoundEnd = world:component() :: Id<T.RoundState>

components.ServerStickState = world:component()
components.Glide = world:entity()

components.Faceoff = world:component() :: Id<T.Faceoff>

components.StickStateMachine = world:component() :: Id<T.StickStateMachine>
components.GoalieStateMachine = world:component() :: Id<T.GoalieStateMachine>

components.GoalActivator = world:entity()
components.GoalReceiver = world:entity()
components.ShotHitNet = world:component() :: Id<T.ShotHitNet>
components.CollectCheck = world:component()
components.OutOfBounds = world:entity()
components.ChatListener = world:component() :: Id<T.ChatEvent>
components.Raycasting = world:entity()
components.Power = world:component() :: Id<T.Power>
components.Shadow = world:component() :: Id<BasePart>
components.ClientPuckTag = world:entity()

components.GoalEvent = world:component() :: Id<T.GoalEvent>
components.VelocityBefore = world:component() :: Id<Vector3>
components.ShotEvent = world:component() :: Id<T.ShotEvent>
components.FiredShot = world:component()
components.DropEvent = world:entity()

components.DetectCollisions = world:component()
components.GoalieReacting = world:component() :: Id<T.GoalieReacting>
components.HitVictimCooldown = world:component()
components.Ragdolled = world:component()
components.Celebrating = world:component()
components.InFaceoff = world:component()
components.LastShotPosition = world:component()
components.LastPosition = world:component()

components.Tracking = world:component()
components.CenterCFrame = world:component() :: Id<CFrame>
components.RelativeZone = world:component() :: Id<string>
components.TrackingDistance = world:component() :: Id<number>
components.TrackingDirection = world:component() :: Id<Vector3>
components.ThreatData = world:component() :: Id<T.ThreatData>
components.StateDecision = world:component()

components.StartGameRequest = world:entity()
components.GameTime = world:component() :: Id<number>
components.GamePeriod = world:component() :: Id<number>
components.GameOvertime = world:entity()
components.IsHit = world:component() :: Id<T.IsHitData>
components.HitDataServer = world:component() :: Id<T.HitDataServer>
components.IsMoving = world:entity()

components.AwayTeamLink = world:entity()
components.HomeTeamLink = world:entity()

components.PlayIntermissionMusic = world:entity()

components.Music = world:component() :: Id<T.SoundData>
components.Uniform = world:component() :: Id<T.Uniform>
components.GoalHorn = world:component() :: Id<String>
components.PrimaryColors = world:component() :: Id<T.PrimaryColors>
components.Abbreviation = world:component() :: Id<String>
components.Dressed = world:entity()
components.ShiftSprint = world:component()
components.Momentum = world:component()

components.HitLogs = world:component()

-- Modifications
world:add(components.EquippedOn, jecs.pair(jecs.OnDeleteTarget, jecs.Delete))
world:add(components.BelongsToRink, jecs.Exclusive)
world:add(components.BelongsToTeam, jecs.Exclusive)
world:add(components.ParticipantOf, jecs.Exclusive)
world:add(components.PlayState, jecs.Exclusive)
world:add(components.CurrentParticipant, jecs.Exclusive)
world:add(components.Owner, jecs.Exclusive)
world:add(components.Tracking, jecs.Exclusive)

--world:add(components.Owner, jecs.pair(jecs.OnDeleteTarget, jecs.Delete))

-- Set name for each components
for name, component in components do
	world:set(component :: jecs.Entity, jecs.Name, name :: string)
	world:add(component :: jecs.Entity, replecs.shared)
end

-- Replecs
world:add(jecs.Name, replecs.shared)

return components
