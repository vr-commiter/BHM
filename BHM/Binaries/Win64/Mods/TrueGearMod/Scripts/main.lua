local truegear = require "truegear"

local hookIds = {}
local resetHook = true

local handItem = {
	LeftHandItem = nil,
	RightHandItem = nil
}

local isPause = false
local playerHealth = 100
local isRopeGrappleHookZip = false
local isLeftHandCrush = false
local isRightHandCrush = false
local isStrengthActivated = false
local strengthDuration = 0
local strengthActivatedTime = 0
local isLoreCollectibleRegister = false
local isMaxHealthUpRegister = false
local hookIds2 = {}
local hookIds3 = {}
local lastRopePullTime = 0
local lastSavePointTime = 0
local lastReleaseHand = 0
local forgeTime = 0
local heartbeatTime = 0
local healingTime = 0

local playerCharacter = nil;

function SendMessage(context)
	if context then
		print(context .. "\n")
		return
	end
	print("nil\n")
end

function PlayAngle(event,tmpAngle,tmpVertical)

	local rootObject = truegear.find_effect(event);

	local angle = (tmpAngle - 22.5 > 0) and (tmpAngle - 22.5) or (360 - tmpAngle)
	
    local horCount = math.floor(angle / 45) + 1
	local verCount = (tmpVertical > 0.1) and -4 or (tmpVertical < 0 and 8 or 0)


	for kk, track in pairs(rootObject.tracks) do
        if tostring(track.action_type) == "Shake" then
            for i = 1, #track.index do
                if verCount ~= 0 then
                    track.index[i] = track.index[i] + verCount
                end
                if horCount < 8 then
                    if track.index[i] < 50 then
                        local remainder = track.index[i] % 4
                        if horCount <= remainder then
                            track.index[i] = track.index[i] - horCount
                        elseif horCount <= (remainder + 4) then
                            local num1 = horCount - remainder
                            track.index[i] = track.index[i] - remainder + 99 + num1
                        else
                            track.index[i] = track.index[i] + 2
                        end
                    else
                        local remainder = 3 - (track.index[i] % 4)
                        if horCount <= remainder then
                            track.index[i] = track.index[i] + horCount
                        elseif horCount <= (remainder + 4) then
                            local num1 = horCount - remainder
                            track.index[i] = track.index[i] + remainder - 99 - num1
                        else
                            track.index[i] = track.index[i] - 2
                        end
                    end
                end
            end
            if track.index then
                local filteredIndex = {}
                for _, v in pairs(track.index) do
                    if not (v < 0 or (v > 19 and v < 100) or v > 119) then
                        table.insert(filteredIndex, v)
                    end
                end
                track.index = filteredIndex
            end
        elseif tostring(track.action_type) ==  "Electrical" then
            for i = 1, #track.index do
                if horCount <= 4 then
                    track.index[i] = 0
                else
                    track.index[i] = 100
                end
            end
            if horCount == 1 or horCount == 8 or horCount == 4 or horCount == 5 then
                track.index = {0, 100}
            end
        end
    end

	truegear.play_effect_by_content(rootObject)
end

function RegisterLoreCollectible()

	for k,v in pairs(hookIds2) do
		UnregisterHook(k, v.id1, v.id2)
	end
		
	hookIds2 = {}

	local funcName = "/Game/BHM/Interactables/LoreCollectible/BP_LoreCollectible.BP_LoreCollectible_C:BndEvt__BP_LoreCollectible_PLCInteractionCrush_K2Node_ComponentBoundEvent_2_PLCGenericCrushSignature__DelegateSignature"
	local hook3, hook4 = RegisterHook(funcName, LoreCollectibleCrushEnd)
	hookIds2[funcName] = { id1 = hook3; id2 = hook4 }

	local funcName = "/Game/BHM/Interactables/LoreCollectible/BP_LoreCollectible.BP_LoreCollectible_C:BndEvt__BP_LoreCollectible_PLCInteractionCrush_K2Node_ComponentBoundEvent_1_PLCGenericCrushSignature__DelegateSignature"
	local hook3, hook4 = RegisterHook(funcName, LoreCollectibleCrushBegin)
	hookIds2[funcName] = { id1 = hook3; id2 = hook4 }

	local funcName = "/Game/BHM/Interactables/LoreCollectible/BP_LoreCollectible.BP_LoreCollectible_C:BndEvt__BP_LoreCollectible_PLCInteractionCrush_K2Node_ComponentBoundEvent_0_PLCGenericCrushSignature__DelegateSignature"
	local hook3, hook4 = RegisterHook(funcName, LoreCollectibleCrushed)
	hookIds2[funcName] = { id1 = hook3; id2 = hook4 }
end

function RegisterMaxHealthUp()

	for k,v in pairs(hookIds3) do
		UnregisterHook(k, v.id1, v.id2)
	end
		
	hookIds3 = {}

	local funcName = "/Game/BHM/Blueprints/Interactables/Craftables/BP_MaxHealthUp.BP_MaxHealthUp_C:OnBeginCrushDelegate_Event"
	local hook5, hook6 = RegisterHook(funcName, OnBeginCrushDelegate_Event)
	hookIds3[funcName] = { id1 = hook5; id2 = hook6 }

	local funcName = "/Game/BHM/Blueprints/Interactables/Craftables/BP_MaxHealthUp.BP_MaxHealthUp_C:OnEndCrushDelegate_Event"
	local hook5, hook6 = RegisterHook(funcName, OnEndCrushDelegate_Event)
	hookIds3[funcName] = { id1 = hook5; id2 = hook6 }

	local funcName = "/Game/BHM/Blueprints/Interactables/Craftables/BP_MaxHealthUp.BP_MaxHealthUp_C:OnCrushedDelegate_Event"
	local hook5, hook6 = RegisterHook(funcName, OnCrushedDelegate_Event)
	hookIds3[funcName] = { id1 = hook5; id2 = hook6 }
end






function RegisterHooks()


	for k,v in pairs(hookIds) do
		UnregisterHook(k, v.id1, v.id2)
	end
		
	hookIds = {}
	
    playerCharacter = FindFirstOf("BHMPlayerCharacter")
    
    if(playerCharacter:IsValid()) then
    	print("Player Character Found")
    else
    	print("Player Character Not Found")
    end

    local funcName = "/Script/SDIGamePlugin.SDIInventorySlot:AttachInventory"
	local hook1, hook2 = RegisterHook(funcName, AttachInventory)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Script/SDIGamePlugin.SDIInventoryActor:GrabFromInventory"
	local hook1, hook2 = RegisterHook(funcName, GrabFromInventory)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
    
    local funcName = "/Script/BHM.BHMPlayerHand:OnActivateStrength"
	local hook1, hook2 = RegisterHook(funcName, OnActivateStrength)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Script/BHM.BHMPlayerHand:OnDeactivateStrength"
	local hook1, hook2 = RegisterHook(funcName, OnDeactivateStrength)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
    local funcName = "/Game/BHM/Blueprints/Player/BP_BHM_PlayerCharacter.BP_BHM_PlayerCharacter_C:OnCharacterDeath"
	local hook1, hook2 = RegisterHook(funcName, OnCharacterDeath)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
            
    local funcName = "/Game/BHM/Blueprints/Player/BP_BHM_PlayerCharacter.BP_BHM_PlayerCharacter_C:OnDamageTaken"
	local hook1, hook2 = RegisterHook(funcName, OnDamageTaken)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
                
    local funcName = "/Game/BHM/Blueprints/Player/BP_BHM_PlayerCharacter.BP_BHM_PlayerCharacter_C:OnDodge"
	local hook1, hook2 = RegisterHook(funcName, OnDodge)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
    
    local funcName = "/Game/BHM/Blueprints/Player/BP_BHM_PlayerCharacter.BP_BHM_PlayerCharacter_C:K2_OnStartCrouch"
	local hook1, hook2 = RegisterHook(funcName, OnCrouch)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
        
    local funcName = "/Game/BHM/Blueprints/Player/BP_BHM_PlayerCharacter.BP_BHM_PlayerCharacter_C:BP_StrengthStateChanged"
	local hook1, hook2 = RegisterHook(funcName, BP_StrengthStateChanged)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Script/SDIGamePlugin.SDIHeldActor:Grab"
	local hook1, hook2 = RegisterHook(funcName, HeldActorGrab)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
    
    local funcName = "/Game/BHM/Blueprints/Interactables/Weapons/BP_BHM_Melee_Weapon_Base.BP_BHM_Melee_Weapon_Base_C:OnAttackBlocked"
	local hook1, hook2 = RegisterHook(funcName, OnAttackBlocked)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/BHM/Blueprints/Interactables/Weapons/BP_BHM_Melee_Weapon_Base.BP_BHM_Melee_Weapon_Base_C:OnBlockedAttack"
	local hook1, hook2 = RegisterHook(funcName, OnBlockedAttack)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/BHM/Blueprints/Interactables/Weapons/BP_BHM_Melee_Weapon_Base.BP_BHM_Melee_Weapon_Base_C:OnParriedAttack"
	local hook1, hook2 = RegisterHook(funcName, OnParriedAttack)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Game/BHM/Blueprints/Interactables/Weapons/BP_BHM_Melee_Weapon_Base.BP_BHM_Melee_Weapon_Base_C:AddBloodToHands"
	local hook1, hook2 = RegisterHook(funcName, OnHit)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
    
    -- local funcName = "/Script/BHM.BHMCharacterMovementComponent:IsClimbJumping"
	-- local hook1, hook2 = RegisterHook(funcName, IsClimbJumping)
	-- hookIds[funcName] = { id1 = hook1; id2 = hook2 }


    local funcName = "/Script/SDIGamePlugin.SDIInteractiveActorInterface:OnGripPress"
	local hook1, hook2 = RegisterHook(funcName, OnGripPress)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/BHM/Blueprints/Player/Scroll/BP_BHM_Player_Scroll.BP_BHM_Player_Scroll_C:OnGripRelease"
	local hook1, hook2 = RegisterHook(funcName, ScrollOnGripRelease)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/BHM/Blueprints/Interactables/Weapons/Bow/BP_BHM_Bow.BP_BHM_Bow_C:LaunchArrow"
	local hook1, hook2 = RegisterHook(funcName, LaunchArrow)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/BHM/Blueprints/Interactables/Weapons/Bow/BP_BHM_Bow.BP_BHM_Bow_C:OnInteractPress"
	local hook1, hook2 = RegisterHook(funcName, OnInteractPress)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/BHM/Blueprints/Interactables/Weapons/Bow/BP_BHM_Bow.BP_BHM_Bow_C:OnGripRelease"
	local hook1, hook2 = RegisterHook(funcName, BowOnGripRelease)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

    local funcName = "/Script/SDIGamePlugin.SDIInteractiveActorInterface:OnGripRelease"
	local hook1, hook2 = RegisterHook(funcName, OnGripRelease)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/SDIGamePlugin.SDIHeldActor:OnActorHitLevelCheck"
	local hook1, hook2 = RegisterHook(funcName, OnActorHitLevelCheck)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
			
	local funcName = "/Game/BHM/Blueprints/Interactables/Props/GrappleHook/BP_GrappleHookGun_V2.BP_GrappleHookGun_V2_C:FireRope"
	local hook1, hook2 = RegisterHook(funcName, FireRope)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/BHM/Blueprints/Player/BP_BHM_PlayerCharacter.BP_BHM_PlayerCharacter_C:OnHealthUpdated"
	local hook1, hook2 = RegisterHook(funcName, OnHealthUpdated)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/BHM.BHMRopeReactionInterface:OnRopeGrappleHookZipDisengaged"
	local hook1, hook2 = RegisterHook(funcName, OnRopeGrappleHookZipDisengaged)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/BHM.BHMRopeReactionInterface:OnRopeGrappleHookZipEngaged"
	local hook1, hook2 = RegisterHook(funcName, OnRopeGrappleHookZipEngaged)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/BHM/Blueprints/Interactables/Weapons/Bow/BP_BHM_Arrow.BP_BHM_Arrow_C:ReturnToInventory"
	local hook1, hook2 = RegisterHook(funcName, ReturnToInventory)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Script/BHM.BHMPlayerController:OnStrengthSourceBeginCrush"
	local hook1, hook2 = RegisterHook(funcName, OnStrengthSourceBeginCrush)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/BHM.BHMPlayerController:OnStrengthSourceEndCrush"
	local hook1, hook2 = RegisterHook(funcName, OnStrengthSourceEndCrush)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/BHM.BHMPlayerController:OnStrengthSourceCrushed"
	local hook1, hook2 = RegisterHook(funcName, OnStrengthSourceCrushed)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/BHM/Maps/World/ZoneBat/ZoneBat_Boss/ZoneBat_Boss_Des.ZoneBat_Boss_Des_C:BndEvt__ZoneBat_Boss_Des_TriggerBox_2_K2Node_ActorBoundEvent_2_ActorBeginOverlapSignature__DelegateSignature"
	local hook1, hook2 = RegisterHook(funcName, GrabFromInventory)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/BHM/Maps/World/ZoneBat/ZoneBat_Boss/ZoneBat_Boss_Des.ZoneBat_Boss_Des_C:BndEvt__ZoneBat_Boss_Des_BP_SetPieceManager_C_0_K2Node_ActorBoundEvent_0_SequenceSetupElements__DelegateSignature"
	local hook1, hook2 = RegisterHook(funcName, ReturnToInventory)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Game/BHM/Blueprints/LevelFeatures/SavePoint/BP_SavePoint.BP_SavePoint_C:OnGripRelease"
	local hook1, hook2 = RegisterHook(funcName, SavePointOnGripRelease)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Game/BHM/Blueprints/Player/BP_BHM_GamePausedUI.BP_BHM_GamePausedUI_C:HideElements"
	local hook1, hook2 = RegisterHook(funcName, HideElements)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/BHM/Blueprints/Player/BP_BHM_GamePausedUI.BP_BHM_GamePausedUI_C:EnableElements"
	local hook1, hook2 = RegisterHook(funcName, EnableElements)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/BHM/UI/WBP/WBP_BHM_PauseMenu.WBP_BHM_PauseMenu_C:BndEvt__BTNExit_K2Node_ComponentBoundEvent_13_OnPressedEventDispatcher__DelegateSignature"
	local hook1, hook2 = RegisterHook(funcName, BndEvt__BTNExit_K2Node_ComponentBoundEvent_13_OnPressedEventDispatcher__DelegateSignature)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/BHM/UI/WBP/WBP_BHM_PauseMenu.WBP_BHM_PauseMenu_C:BndEvt__BTNResume_K2Node_ComponentBoundEvent_8_OnPressedEventDispatcher__DelegateSignature"
	local hook1, hook2 = RegisterHook(funcName, BndEvt__BTNResume_K2Node_ComponentBoundEvent_8_OnPressedEventDispatcher__DelegateSignature)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/BHM/UI/WBP/WBP_BHM_SaveGame.WBP_BHM_SaveGame_C:LoadGame"
	local hook1, hook2 = RegisterHook(funcName, LoadGame)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/BHM/Blueprints/LevelFeatures/Rope/BP_BaseRopeReactionActor.BP_BaseRopeReactionActor_C:RopePullTick"
	local hook1, hook2 = RegisterHook(funcName, RopePullTick)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

end


-- *******************************************************************

function OnActivateStrength(self)
	SendMessage("--------------------------------")
	SendMessage("OnStrengthActivated")
	strengthActivatedTime = os.clock()
	if playerCharacter:IsValid() then
		strengthDuration = playerCharacter:GetPropertyValue("StrengthAbilityDuration")
		print("Strength Duration: ", strengthDuration)
	end 
	isStrengthActivated = true
end

function OnDeactivateStrength(self)
	SendMessage("--------------------------------")
	SendMessage("OnStrengthDeactivated")
	isStrengthActivated = false
end

function HideElements(self)
	SendMessage("--------------------------------")
	SendMessage("HideElements")
	isPause = true
end

function LoadGame(self)
	SendMessage("--------------------------------")
	SendMessage("LoadGame")
	isPause = false
	playerHealth = 100
	isRopeGrappleHookZip = false
	isLeftHandCrush = false
	isRightHandCrush = false
end

function BndEvt__BTNResume_K2Node_ComponentBoundEvent_8_OnPressedEventDispatcher__DelegateSignature(self)
	SendMessage("--------------------------------")
	SendMessage("Resume")
	isPause = false
end

function BndEvt__BTNExit_K2Node_ComponentBoundEvent_13_OnPressedEventDispatcher__DelegateSignature(self)
	SendMessage("--------------------------------")
	SendMessage("Exit")
	isPause = false
	playerHealth = 100
	isRopeGrappleHookZip = false
	isLeftHandCrush = false
	isRightHandCrush = false
end

function EnableElements(self)
	SendMessage("--------------------------------")
	SendMessage("EnableElements")
	isPause = true
end

function SavePointOnGripRelease(self,Hand)
	SendMessage("--------------------------------")
	SendMessage("SavePointOnGripRelease")
	if os.clock() - lastSavePointTime < 0.5 and lastReleaseHand ~= Hand:get():GetPropertyValue("ControllerHand") then
		SendMessage("SaveGame")
		truegear.play_effect_by_uuid("SaveGame")
	end
	lastSavePointTime = os.clock()
	lastReleaseHand = Hand:get():GetPropertyValue("ControllerHand")
	SendMessage(self:get():GetFullName())
	SendMessage(tostring(os.clock()))
end

function RopePullTick(self)
	if os.clock() - lastRopePullTime > 0.15 then
		lastRopePullTime = os.clock()
		SendMessage("--------------------------------")
		SendMessage("RopePull")
		truegear.play_effect_by_uuid("RopePull")
		SendMessage(self:get():GetFullName())
	end
end

function OnCrushedDelegate_Event(self,CrushComponent,Actor,PC,Character,Hand)
	SendMessage("--------------------------------")
	if Hand:get():GetPropertyValue("ControllerHand") == 1 then
		SendMessage("RightHandCrushed")
		truegear.play_effect_by_uuid("RightHandCrushed")
	else
		SendMessage("LeftHandCrushed")
		truegear.play_effect_by_uuid("LeftHandCrushed")
	end
end

function OnEndCrushDelegate_Event(self,CrushComponent,Actor,PC,Character,Hand)
	SendMessage("--------------------------------")
	if Hand:get():GetPropertyValue("ControllerHand") == 1 then
		SendMessage("StopRightHandCrushed1")
		isRightHandCrush = false
	else
		SendMessage("StopLeftHandCrushed1")
		isLeftHandCrush = false
	end
end

function OnBeginCrushDelegate_Event(self,CrushComponent,Actor,PC,Character,Hand)
	SendMessage("--------------------------------")
	if Hand:get():GetPropertyValue("ControllerHand") == 1 then
		SendMessage("StartRightHandCrushed")
		isRightHandCrush = true
	else
		SendMessage("StartLeftHandCrushed")
		isLeftHandCrush = true
	end
end

function ReturnToInventory(self)
	SendMessage("--------------------------------")
	SendMessage("ReturnToInventory")
	truegear.play_effect_by_uuid("ChestSlotInputItem")
end

function GrabFromInventory(self)
	SendMessage("--------------------------------")
	SendMessage("GrabFromInventory")
	truegear.play_effect_by_uuid("ChestSlotOutputItem")
end

function ReturnToInventory(self)
	SendMessage("--------------------------------")
	SendMessage("ReturnToInventory")
	truegear.play_effect_by_uuid("ChestSlotInputItem")
	SendMessage(self:get():GetFullName())
end

function OnInteractPress(self)
	SendMessage("--------------------------------")
	SendMessage("OnInteractPress")
	SendMessage(self:get():GetFullName())
end

function LaunchArrow(self)
	if string.find(handItem["LeftHandItem"],"BHM_Bow") then
		SendMessage("--------------------------------")
		SendMessage("LeftHandLaunchArrow")
		truegear.play_effect_by_uuid("LeftHandLaunchArrow")
	else
		SendMessage("--------------------------------")
		SendMessage("RightHandLaunchArrow")
		truegear.play_effect_by_uuid("RightHandLaunchArrow")
	end
	SendMessage(self:get():GetFullName())
end

function OnStrengthSourceBeginCrush(self,SourceActor,Char,Hand)
	SendMessage("--------------------------------")
	if Hand:get():GetPropertyValue("ControllerHand") == 1 then
		SendMessage("StartRightHandCrush")
		isRightHandCrush = true
	else
		SendMessage("StartLeftHandCrush")
		isLeftHandCrush = true
	end
end

function OnStrengthSourceEndCrush(self,SourceActor,Char,Hand)
	SendMessage("--------------------------------")
	if Hand:get():GetPropertyValue("ControllerHand") == 1 then
		SendMessage("StopRightHandCrush2")
		isRightHandCrush = false
	else
		SendMessage("StopLeftHandCrush2")
		isLeftHandCrush = false
	end
end

function OnStrengthSourceCrushed(self,SourceActor,Char,Hand)
	SendMessage("--------------------------------")
	if Hand:get():GetPropertyValue("ControllerHand") == 1 then
		SendMessage("RightHandCrushed")
		truegear.play_effect_by_uuid("RightHandCrushed")
	else
		SendMessage("LeftHandCrushed")
		truegear.play_effect_by_uuid("LeftHandCrushed")
	end
end


function OnRopeGrappleHookZipEngaged(self)
	SendMessage("--------------------------------")
	SendMessage("StartRopeGrappleHookZip")
	isRopeGrappleHookZip = true
end

function OnRopeGrappleHookZipDisengaged(self)
	SendMessage("--------------------------------")
	SendMessage("StopRopeGrappleHookZip")
	isRopeGrappleHookZip = false
end


function OnHealthUpdated(self,PrevHealth,NewHealth)
	SendMessage("--------------------------------")
	SendMessage("OnHealthUpdated")
	if PrevHealth:get() < NewHealth:get() then
		if os.clock() - healingTime > 1.2 then
			healingTime = os.clock()
			SendMessage("Healing")
			truegear.play_effect_by_uuid("Healing")
		end
	end
	playerHealth = NewHealth:get()
	heartbeatTime = os.clock() 
	SendMessage(self:get():GetFullName())
	SendMessage(tostring(PrevHealth:get()))
	SendMessage(tostring(NewHealth:get()))
end

function FireRope(self)
	SendMessage("--------------------------------")
	SendMessage("FireRope")
	truegear.play_effect_by_uuid("FireRope")
	SendMessage(self:get():GetFullName())
end

function OnActorHitLevelCheck(self,SelfActor,OtherActor,NormalImpulse,Hit)
	if math.abs(NormalImpulse:get().X) > 200 then
		if self:get():GetFullName() == handItem["LeftHandItem"] then
			SendMessage("--------------------------------")
			SendMessage("LeftHandItemHit")
			truegear.play_effect_by_uuid("LeftHandItemHit")
			if string.find(OtherActor:get():GetFullName(),"_PlayerHand_") then
				SendMessage("RightHandItemHit")
				truegear.play_effect_by_uuid("RightHandItemHit")
			end
		end
		if self:get():GetFullName() == handItem["RightHandItem"] then
			SendMessage("--------------------------------")
			SendMessage("RightHandItemHit")
			truegear.play_effect_by_uuid("RightHandItemHit")
			if string.find(OtherActor:get():GetFullName(),"_PlayerHand_") then
				SendMessage("LeftHandItemHit")
				truegear.play_effect_by_uuid("LeftHandItemHit")
			end
		end
	end
end


function BowOnGripRelease(self,Hand)
	SendMessage("--------------------------------")
	SendMessage("BowOnGripRelease")
	local hand = Hand:get():GetPropertyValue("ControllerHand")
	if hand == 1 then
		handItem["RightHandItem"] = nil
	else
		handItem["LeftHandItem"] = nil	
	end
end

function ScrollOnGripRelease(self,Hand)
	local hand = Hand:get():GetPropertyValue("ControllerHand")
	if hand == 1 then
		handItem["RightHandItem"] = nil
	else
		handItem["LeftHandItem"] = nil	
	end
end

function OnHit(self)
	local hasAttack = false
	SendMessage("--------------------------------")
	if self:get():GetFullName() == handItem["LeftHandItem"] then
		SendMessage("LeftHandMeleeAttackHit")
		truegear.play_effect_by_uuid("LeftHandMeleeAttackHit")
		hasAttack = true
	end
	if self:get():GetFullName() == handItem["RightHandItem"] then
		SendMessage("RightHandMeleeAttackHit")
		truegear.play_effect_by_uuid("RightHandMeleeAttackHit")
		hasAttack = true
	end
	if hasAttack == false then
		SendMessage("LeftHandMeleeAttackHit1")
		SendMessage("RightHandMeleeAttackHit1")
		truegear.play_effect_by_uuid("LeftHandMeleeAttackHit")
		truegear.play_effect_by_uuid("RightHandMeleeAttackHit")
	end
	SendMessage(self:get():GetFullName())
end

function OnGripPress(self,Hand,Component,Entry)
	if string.find(Component:get():GetFullName(),"InventorySlot") or string.find(Component:get():GetFullName(),"MedicineSlot") then
		return
	end
	local hand = Hand:get():GetPropertyValue("ControllerHand")
	SendMessage("--------------------------------")
	if hand == 1 then
		SendMessage("RightHandPickupItem")
		truegear.play_effect_by_uuid("RightHandPickupItem")
	else
		SendMessage("LeftHandPickupItem")
		truegear.play_effect_by_uuid("LeftHandPickupItem")
	end
	SendMessage(Component:get():GetFullName())
	SendMessage(Entry:get():GetFullName())
end

function OnGripRelease(self,Hand)
	SendMessage("--------------------------------")
	SendMessage("OnGripRelease")
	if handItem["LeftHandItem"] ~= nil then
		if string.find(handItem["LeftHandItem"],"Player_Scroll") or string.find(handItem["LeftHandItem"],"BHM_Bow") then
			return
		end
		if handItem["RightHandItem"] == nil then
			handItem["LeftHandItem"] = nil
			return
		end
	end
	if handItem["RightHandItem"] ~= nil then
		if string.find(handItem["RightHandItem"],"Player_Scroll") or string.find(handItem["RightHandItem"],"BHM_Bow") then
			return
		end
		if handItem["LeftHandItem"] == nil then
			handItem["RightHandItem"] = nil
			return
		end
	end


	if handItem["LeftHandItem"] == nil and handItem["RightHandItem"] == nil then
		return
	end
	local hand = Hand:get():GetPropertyValue("ControllerHand")
	if hand == 1 then
		handItem["RightHandItem"] = nil
	else
		handItem["LeftHandItem"] = nil
	end	
end



function LoreCollectibleCrushed(self,CrushComponent,Actor,PC,Character,Hand)
	SendMessage("--------------------------------")
	if Hand:get():GetPropertyValue("ControllerHand") == 1 then
		SendMessage("RightHandCrushed")
		truegear.play_effect_by_uuid("RightHandCrushed")
	else
		SendMessage("LeftHandCrushed")
		truegear.play_effect_by_uuid("LeftHandCrushed")
	end
end

function LoreCollectibleCrushEnd(self,CrushComponent,Actor,PC,Character,Hand)
	SendMessage("--------------------------------")
	if Hand:get():GetPropertyValue("ControllerHand") == 1 then
		SendMessage("StopRightHandCrush3")
		isRightHandCrush = false
	else
		SendMessage("StopLeftHandCrush3")
		isLeftHandCrush = false
	end
end

function LoreCollectibleCrushBegin(self,CrushComponent,Actor,PC,Character,Hand)
	SendMessage("--------------------------------")
	if Hand:get():GetPropertyValue("ControllerHand") == 1 then
		SendMessage("StartRightHandCrush")
		isRightHandCrush = true
	else
		SendMessage("StartLeftHandCrush")
		isLeftHandCrush = true
	end
end

function OnHammerAreaBeginOverlap(self,OverlappedComponent,OtherActor,OtherComp,bFromSweep,SweepResult)
	if os.clock() - forgeTime < 0.2 then
		return
	end
	forgeTime = os.clock()	
	SendMessage("--------------------------------")
	SendMessage("OnHammerAreaBeginOverlap")
	SendMessage(self:get():GetFullName())
	SendMessage(OtherActor:get():GetFullName())
	SendMessage(tostring(bFromSweep:get()))
	local hasAttack = false
	if self:get():GetFullName() == handItem["LeftHandItem"] then
		hasAttack = true
		SendMessage("LeftHandMeleeBlockedAttack")
		truegear.play_effect_by_uuid("LeftHandMeleeBlockedAttack")
	end
	if self:get():GetFullName() == handItem["RightHandItem"] then
		hasAttack = true
		SendMessage("RightHandMeleeBlockedAttack")
		truegear.play_effect_by_uuid("RightHandMeleeBlockedAttack")
	end
	if hasAttack == false then
		SendMessage("LeftHandMeleeBlockedAttack1")
		SendMessage("RightHandMeleeBlockedAttack1")
		truegear.play_effect_by_uuid("LeftHandMeleeBlockedAttack")
		truegear.play_effect_by_uuid("RightHandMeleeBlockedAttack")
	end
end

function IsClimbJumping(self)
	SendMessage("--------------------------------")
	SendMessage("IsClimbJumping")
	SendMessage(self:get():GetFullName())
end

function BP_StrengthStateChanged(self,StrengthState)
	SendMessage("--------------------------------")
	SendMessage("BP_StrengthStateChanged")
	-- truegear.play_effect_by_uuid("StrengthStateChanged")
	SendMessage(tostring(StrengthState:get()))
	SendMessage(self:get():GetFullName())
end

function OnCrouch(self)
	SendMessage("--------------------------------")
	SendMessage("PlayerCrouch")
	truegear.play_effect_by_uuid("Crouch")
	SendMessage(self:get():GetFullName())
end




function HeldActorGrab(self,Grabber,Hand)
    if self:get():WasHeldByPlayer() or (self:get():GetPropertyValue("Owner"):GetFullName() ~= nil and string.find(self:get():GetPropertyValue("Owner"):GetFullName(),"Player")) then
        SendMessage("--------------------------------")
        SendMessage("HeldActorGrab")
		if Hand:get() == 1 then
			handItem["RightHandItem"] = self:get():GetFullName()
			SendMessage("RightHandPickupItem")
			truegear.play_effect_by_uuid("RightHandPickupItem")
		else
			handItem["LeftHandItem"] = self:get():GetFullName()
			SendMessage("LeftHandPickupItem")
			truegear.play_effect_by_uuid("LeftHandPickupItem")
		end
        SendMessage(self:get():GetFullName())
        SendMessage(tostring(Hand:get()))
        SendMessage(self:get():GetPropertyValue("Owner"):GetFullName())
        SendMessage(tostring(self:get():WasHeldByPlayer()))
        SendMessage(tostring(self:get():WasHeldByPlayerHand()))
    end
	if not isLoreCollectibleRegister then
		if string.find(self:get():GetFullName(),"LoreCollectible") then			
			local ran,errorMsg = pcall(RegisterLoreCollectible)
			if ran then
				isLoreCollectibleRegister = true
			end
		end
	end
	if not isMaxHealthUpRegister then
		if string.find(self:get():GetFullName(),"MaxHealthUp") then			
			local ran,errorMsg = pcall(RegisterMaxHealthUp)
			if ran then
				isMaxHealthUpRegister = true
			end
		end
	end
end


function OnParriedAttack(self)
	local hasAttack = false
	SendMessage("--------------------------------")
	if self:get():GetFullName() == handItem["LeftHandItem"] then
		hasAttack = true
		SendMessage("LeftHandMeleeParriedAttack")
		truegear.play_effect_by_uuid("LeftHandMeleeParriedAttack")
	end
	if self:get():GetFullName() == handItem["RightHandItem"] then
		hasAttack = true
		SendMessage("RightHandMeleeParriedAttack")
		truegear.play_effect_by_uuid("RightHandMeleeParriedAttack")
	end
	if hasAttack == false then
		SendMessage("LeftHandMeleeParriedAttack1")
		SendMessage("RightHandMeleeParriedAttack1")
		truegear.play_effect_by_uuid("LeftHandMeleeParriedAttack")
		truegear.play_effect_by_uuid("RightHandMeleeParriedAttack")
	end
end

function OnBlockedAttack(self)
	local hasAttack = false
	SendMessage("--------------------------------")
	if self:get():GetFullName() == handItem["LeftHandItem"] then
		hasAttack = true
		SendMessage("LeftHandMeleeBlockedAttack")
		truegear.play_effect_by_uuid("LeftHandMeleeBlockedAttack")
	end
	if self:get():GetFullName() == handItem["RightHandItem"] then
		hasAttack = true
		SendMessage("RightHandMeleeBlockedAttack")
		truegear.play_effect_by_uuid("RightHandMeleeBlockedAttack")
	end
	if hasAttack == false then
		SendMessage("LeftHandMeleeBlockedAttack1")
		SendMessage("RightHandMeleeBlockedAttack1")
		truegear.play_effect_by_uuid("LeftHandMeleeBlockedAttack")
		truegear.play_effect_by_uuid("RightHandMeleeBlockedAttack")
	end
end

function OnAttackBlocked(self)
	local hasAttack = false
	SendMessage("--------------------------------")
	if self:get():GetFullName() == handItem["LeftHandItem"] then
		hasAttack = true
		SendMessage("LeftHandMeleeAttackBlocked")
		truegear.play_effect_by_uuid("LeftHandMeleeAttackBlocked")
	end
	if self:get():GetFullName() == handItem["RightHandItem"] then
		hasAttack = true
		SendMessage("RightHandMeleeAttackBlocked")
		truegear.play_effect_by_uuid("RightHandMeleeAttackBlocked")
	end
	if hasAttack == false then
		SendMessage("LeftHandMeleeAttackBlocked1")
		SendMessage("RightHandMeleeAttackBlocked1")
		truegear.play_effect_by_uuid("LeftHandMeleeAttackBlocked")
		truegear.play_effect_by_uuid("LeftHandMeleeAttackBlocked")
	end
end

function CheckSlot(slotName)
	if string.find(slotName,"ChestInventoryComponent") then
		return "ChestSlot"
	elseif string.find(slotName,"RightHipInventoryComponent") then
		return "RightHipSlot"
	elseif string.find(slotName,"LeftHipInventoryComponent") then
		return "LeftHipSlot"
	elseif string.find(slotName,"RightBackInventoryComponent") then
		return "RightBackSlot"
	elseif string.find(slotName,"LeftBackInventoryComponent") then
		return "LeftBackSlot"
	elseif string.find(slotName,"GrappleHookGunSlot") then
		return "GrappleHookGunSlot"
	else
		return "ChestSlot"
	end
end

function AttachInventory(self)
	local slot = CheckSlot(self:get():GetFullName())
	SendMessage("--------------------------------")
	SendMessage(slot .. "InputItem")
	truegear.play_effect_by_uuid(slot .. "InputItem")
	SendMessage(self:get():GetFullName())
end

function GrabFromInventory(self)
	if self:get():GetPropertyValue("Slot"):GetFullName() ~= nil then
		local slot = CheckSlot(self:get():GetPropertyValue("Slot"):GetFullName())
		SendMessage("--------------------------------")
		SendMessage(slot .. "OutputItem")
		truegear.play_effect_by_uuid(slot .. "OutputItem")
		SendMessage(self:get():GetFullName())
		SendMessage(self:get():GetPropertyValue("Slot"):GetFullName())
	end
end

function OnDodge(self)
	SendMessage("--------------------------------")
	SendMessage("PlayerDodge")
	truegear.play_effect_by_uuid("Dodge")
	SendMessage(self:get():GetFullName())
end

function OnDamageTaken(self)
	SendMessage("--------------------------------")
	SendMessage("OnDamageTaken")
	SendMessage(self:get():GetFullName())

	local camera = self:get():GetPropertyValue("Controller"):GetPropertyValue("PlayerCameraManager")
	if camera:IsValid() ~= true then
		SendMessage("camera is not found")
		return
	end
	local view = camera:GetPropertyValue("ViewTarget")
	if view:IsValid() ~= true then
		SendMessage("view is not found")
		return
	end
	local playerYaw = view.POV.Rotation.Yaw

	local enemy = self:get():GetPropertyValue("LastHitBy")
	if enemy:IsValid() == false then
		SendMessage("NoEnemyDamage")
		truegear.play_effect_by_uuid("NoEnemyDamage")
		SendMessage("enemy is not found")
		return
	end
	local enemyPawn = enemy:GetPropertyValue("Pawn")
	if enemyPawn:IsValid() == false then
		SendMessage("enemyPawn is not found")
		return
	end
	local enemyController = enemyPawn:GetPropertyValue("Controller")
	if enemyController:IsValid() == false then
		SendMessage("enemyController is not found")
		return
	end
	local targetRotation = enemyController:GetPropertyValue("ControlRotation")
	if targetRotation:IsValid() == false then
		SendMessage("enemyPawn is not found")
		return
	end
	local angleYaw = playerYaw - targetRotation.Yaw
	angleYaw = angleYaw + 180
	if angleYaw > 360 then 
		angleYaw = angleYaw - 360
	elseif angleYaw < 0 then
		angleYaw = 360 + angleYaw
	end
	SendMessage("DefaultDamage," .. angleYaw .. ",0")
	PlayAngle("DefaultDamage",angleYaw,0)
end

function OnCharacterDeath(self)
	SendMessage("--------------------------------")
	SendMessage("PlayerDeath")
	truegear.play_effect_by_uuid("PlayerDeath")
	playerHealth = 0
	SendMessage(self:get():GetFullName())
end

function StrengthThrob()
	if isPause then
		return
	end
	
	if strengthDuration > 0 then
		if os.clock() - strengthActivatedTime > strengthDuration then
			return
		end
	end
	
	if isStrengthActivated then
		SendMessage("--------------------------------")
		SendMessage("StrengthThrob")
		truegear.play_effect_by_uuid("HeartBeat")

	end
end

function HeartBeat()
	if isPause then
		return
	end
	if os.clock() - heartbeatTime > 30 then
		return
	end
	if playerHealth > 0 and playerHealth < 30 then
		SendMessage("--------------------------------")
		SendMessage("HeartBeat")
		truegear.play_effect_by_uuid("HeartBeat")
	end
end

function RopeGrappleHookZip()
	if isPause then
		return
	end
	if isRopeGrappleHookZip then
		SendMessage("--------------------------------")
		SendMessage("RopeGrappleHookZip")
		truegear.play_effect_by_uuid("RopeGrappleHookZip")
	end
end

function LeftHandCrush()
	if isPause then
		return
	end
	if isLeftHandCrush then
		SendMessage("--------------------------------")
		SendMessage("LeftHandCrush")
		truegear.play_effect_by_uuid("LeftHandCrush")
	end
end

function RightHandCrush()
	if isPause then
		return
	end
	if isRightHandCrush then
		SendMessage("--------------------------------")
		SendMessage("RightHandCrush")
		truegear.play_effect_by_uuid("RightHandCrush")
	end
end

truegear.seek_by_uuid("DefaultDamage")
truegear.init("1707990", "Skydance's BEHEMOTH")

function CheckPlayerSpawned()
	RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
		if resetHook then
			local ran, errorMsg = pcall(RegisterHooks)
			if ran then
				SendMessage("--------------------------------")
				SendMessage("HeartBeat")
				truegear.play_effect_by_uuid("HeartBeat")
				resetHook = false
			else
				print(errorMsg)
			end
		end		
	end)
end

CheckPlayerSpawned()

LoopAsync(750,StrengthThrob)
LoopAsync(1000,HeartBeat)
LoopAsync(150,RopeGrappleHookZip)
LoopAsync(150,LeftHandCrush)
LoopAsync(150,RightHandCrush)

SendMessage("TrueGear Mod is Loaded");
