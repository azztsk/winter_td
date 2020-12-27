"use strict"
var right_click_repair = CustomNetTables.GetTableValue("building_settings", "right_click_repair").value;

function GetMouseTarget()
{
    var mouseEntities = GameUI.FindScreenEntities( GameUI.GetCursorPosition() )
    var localHeroIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() )

    for ( var e of mouseEntities )
    {
        if ( !e.accurateCollision )
            continue
        return e.entityIndex
    }

    for ( var e of mouseEntities )
    {
        return e.entityIndex
    }

    return 0
}

// Handle Right Button events
function OnRightButtonPressed()
{
    var iPlayerID = Players.GetLocalPlayer()
    var selectedEntities = Players.GetSelectedEntities( iPlayerID )
    var mainSelected = Players.GetLocalPlayerPortraitUnit() 
    var targetIndex = GetMouseTarget()
    var pressedShift = GameUI.IsShiftDown()
    var bMessageShown = false

	// Enemy right click
    if (targetIndex && Entities.IsEnemy(targetIndex))
    {
        // If it can't be attacked by a unit on the selected group, send them to attack move and show an error (only once)
        
        var order = {
                    QueueBehavior : OrderQueueBehavior_t.DOTA_ORDER_QUEUE_DEFAULT,
                    ShowEffects : true,
                    OrderType : dotaunitorder_t.DOTA_UNIT_ORDER_ATTACK_MOVE,
                    Position : Entities.GetAbsOrigin( targetIndex ),
                }

        for (var i = 0; i < selectedEntities.length; i++)
        {
            if (!UnitCanAttackTarget(selectedEntities[i], targetIndex))
            {
                order.UnitIndex = selectedEntities[i]
                Game.PrepareUnitOrders( order )
                if (!bMessageShown)
                {
					var eventData = { reason: 80, message: "error_cant_target_air" };
					GameEvents.SendEventClientSide("dota_hud_error_message", eventData);
                    bMessageShown = true
                }
            }
        }
        if (bMessageShown)
        {
            return true
        }
    }
	
    // Builder Right Click
    if ( IsBuilder( mainSelected ) )
    {
        // Cancel BH
        if (!pressedShift) SendCancelCommand()

        // Repair rightclick
        if (right_click_repair && IsCustomBuilding(targetIndex) && Entities.GetHealthPercent(targetIndex) < 100 && IsAlliedUnit(targetIndex, mainSelected)) {
            GameEvents.SendCustomGameEventToServer( "building_helper_repair_command", {targetIndex: targetIndex, queue: pressedShift})
            return true
        }
    }

    return false
}

// Handle Left Button events
function OnLeftButtonPressed() {
    return false
}

function IsCustomBuilding(entIndex) {
    return (Entities.GetAbilityByName( entIndex, "ability_building") != -1)
}

function IsBuilder(entIndex) {
    var tableValue = CustomNetTables.GetTableValue( "builders", entIndex.toString())
    return (tableValue !== undefined) && (tableValue.IsBuilder == 1)
}

function IsAlliedUnit(entIndex, targetIndex) {
    return (Entities.GetTeamNumber(entIndex) == Entities.GetTeamNumber(targetIndex))
}

function OnAttacksEnabledChanged (args) {
    attackTable = CustomNetTables.GetAllTableValues("attacks_enabled")
}

function UnitCanAttackTarget (unit, target) {
    var attacks_enabled = GetAttacksEnabled(unit)
    var target_type = GetMovementCapability(target)
    return (attacks_enabled.indexOf(target_type) != -1)
}

function GetMovementCapability (entIndex) {
    return Entities.HasFlyMovementCapability(entIndex ) ? "air" : "ground"
}

function GetAttacksEnabled (unit) {
    var indexEntry = CustomNetTables.GetTableValue("attacks_enabled", unit)
    if (indexEntry) return indexEntry.enabled
    else
    {
        var unitName = Entities.GetUnitName(unit)
        var attackTypes = CustomNetTables.GetTableValue("attacks_enabled", unitName)
        return attackTypes ? attackTypes.enabled : "ground"
    }
}

// Main mouse event callback
GameUI.SetMouseCallback( function( eventName, arg ) {
    var CONSUME_EVENT = true
    var CONTINUE_PROCESSING_EVENT = false
    var LEFT_CLICK = (arg === 0)
    var RIGHT_CLICK = (arg === 1)

    if ( GameUI.GetClickBehaviors() !== CLICK_BEHAVIORS.DOTA_CLICK_BEHAVIOR_NONE )
        return CONTINUE_PROCESSING_EVENT

    var mainSelected = Players.GetLocalPlayerPortraitUnit()

    if ( eventName === "pressed" || eventName === "doublepressed")
    {
        // Builder Clicks
        if (IsBuilder(mainSelected))
            if (LEFT_CLICK) 
                return (state == "active") ? SendBuildCommand() : OnLeftButtonPressed()
            else if (RIGHT_CLICK) 
                return OnRightButtonPressed()

        if (LEFT_CLICK) 
            return OnLeftButtonPressed()
        else if (RIGHT_CLICK) 
            return OnRightButtonPressed() 
        
    }
    return CONTINUE_PROCESSING_EVENT
} )