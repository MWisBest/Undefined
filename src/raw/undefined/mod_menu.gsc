/*
 * This file is part of Undefined.
 *
 * Undefined is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Undefined is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;
#include common_scripts\utility;
#include undefined\utility;

init()
{
	if( getDvar( "custom_gametype" ) == "" ) setDvar( "custom_gametype", "normal" );
	
	level._customGametype = getDvar( "custom_gametype" );
	
	if( level._customGametype == "normal" )
	{
		if( level.rankedMatch == 0 )
		{
			thread onPlayerConnect();
			thread onPlayerConnected();
		}
	}
}
onPlayerConnect()
{
	level endon( "map_restarting" );
	
	while( true )
	{
		level waittill( "connecting", player );
		
		if( level._customGametype == "normal" )
		{
			player thread precacheModMenuResources();
			player thread modMenuResources();
			player thread editingResources();
			player thread onPlayerSpawned();
			player thread globalDvars();
		}
	}
}
onPlayerConnected()
{
	level endon( "map_restarting" );
	
	while( true )
	{
		level waittill( "connected", player );
		
		if( level._customGametype == "normal" )
		{
			player thread playerVariables();
			level._lobbyStatusAlpha = 1;
			player thread lobbyStatus();
			player thread controlButtons();
			player thread monitorOpenModMenu();
		}
	}
}
playerVariables()
{
	self._inMenu = false;
	self._isFrozen = false;
}
globalDvars()
{
	level.onlineGame = 1;
	level.rankedEnabled = 1;
	level.rankedMatch = 1;
	setDvar( "onlinegame", 1 );
	setDvar( "scr_" + getDvar( "g_gametype" ) + "_scorelimit", 0 );
	setDvar( "scr_" + getDvar( "g_gametype" ) + "_timelimit", 0 );
	setDvar( "scr_" + getDvar( "g_gametype" ) + "_playerrespawndelay", 0 );
}
onPlayerSpawned()
{
	level endon( "map_restarting" );
	
	while( true )
	{
		self waittill( "spawned_player" );
		
		if( level._customGametype == "normal" ) self thread infiniteAmmo();
		self._isFrozen = false;
		if( self.pers["lobbyStatusValue"] >= 3 ) self freezeControls( false );
		self setClientDvar( "cg_drawGun", 1 );
	}
}
infiniteAmmo()
{
	level endon( "map_restarting" );
	self endon( "disconnect" );
	self endon( "death" );
	
	while( true )
	{
		currentWeapon = self getCurrentWeapon();
		if ( currentWeapon != "none" )
		{
			self setWeaponAmmoClip( currentWeapon, 500, "left" );
			self setWeaponAmmoClip( currentWeapon, 500, "right" );
			self giveMaxAmmo( currentWeapon );
		}
		
		currentOffhand = self getCurrentOffhand();
		if ( currentOffhand != "none" )
		{
			self setWeaponAmmoClip( currentOffhand, 20 );
			self giveMaxAmmo( currentOffhand );
		}
		wait 0.05;
	}
}
lobbyStatus()
{
	level endon( "map_restarting" );
	
	self._inGameStatus = self defineElement( true, ( 1, 1, 1 ), true, "noscale", "top", 7, 70, level._lobbyStatusAlpha, 2, "font", "objective", 1.3 );
	
	if( isDefined( self.pers["lobbyStatusValue"] ) )
	{
		/* Do Nothing */
	}
	else if( !isDefined( self.pers["lobbyStatusValue"] ) )
	{
		if( self isHost() ) self.pers["lobbyStatusValue"] = 3;
		else self.pers["lobbyStatusValue"] = 0;
	}
	
	while( true )
	{
		if( self.pers["lobbyStatusValue"] == 0 ) self.pers["lobbyStatusText"] = "^0User";
		else if( self.pers["lobbyStatusValue"] == 1 ) self.pers["lobbyStatusText"] = "^2VIP";
		else if( self.pers["lobbyStatusValue"] == 2 ) self.pers["lobbyStatusText"] = "^6Cohost";
		else
		{
			self.pers["lobbyStatusText"] = "^5Host";
			if( self._inMenu && self._selectedMenu == "normal" ) self thread updatePlayers();
		}
		
		self._inGameStatus setText( "^7Status: " + self.pers["lobbyStatusText"] );
		
		self waittill( "lobbyStatusUpdated" );
	}
}
controlButtons()
{
	self thread monitorAttackButton();
	self thread monitorUseButton();
	self thread monitorAdsButton();
	self thread monitorFragButton();
	self thread monitorMeleeButton();
}
monitorAttackButton()
{
	level endon( "map_restarting" );
	
	buttonReleased = true;
	
	while( true )
	{
		wait 0.01;
		
		if( !self attackButtonPressed() ) buttonReleased = true;
		else if( self attackButtonPressed() && buttonReleased )
		{
			self notify( "attackButtonPressed" );
			buttonReleased = false;
		}
		else if( self attackButtonPressed() && !buttonReleased )
		{
			wait 0.1;
			self notify( "attackButtonHeld" );
			wait 0.1;
		}
	}
}
monitorUseButton()
{
	level endon( "map_restarting" );
	
	buttonReleased = true;
	
	while( true )
	{
		wait 0.01;
		
		if( !self useButtonPressed() ) buttonReleased = true;
		else if( self useButtonPressed() && buttonReleased )
		{
			self notify( "useButtonPressed" );
			buttonReleased = false;
		}
		else if( self useButtonPressed() && !buttonReleased )
		{
			self notify( "useButtonHeld" );
			wait 0.05;
		}
	}
}
monitorAdsButton()
{
	level endon( "map_restarting" );
	
	buttonReleased = true;
	
	while( true )
	{
		wait 0.01;
		
		if( !self adsButtonPressed() ) buttonReleased = true;
		else if( self adsButtonPressed() && buttonReleased )
		{
			self notify( "adsButtonPressed" );
			buttonReleased = false;
		}
		else if( self adsButtonPressed() && !buttonReleased )
		{
			wait 0.1;
			self notify( "adsButtonHeld" );
			wait 0.1;
		}
	}
}
monitorFragButton()
{
	level endon( "map_restarting" );
	
	buttonReleased = true;
	
	while( true )
	{
		wait 0.01;
		
		if( !self fragButtonPressed() ) buttonReleased = true;
		else if( self fragButtonPressed() && buttonReleased )
		{
			self notify( "fragButtonPressed" );
			buttonReleased = false;
		}
		else if( self fragButtonPressed() && !buttonReleased )
		{
			self notify( "fragButtonHeld" );
			wait 0.05;
		}
	}
}
monitorMeleeButton()
{
	level endon( "map_restarting" );
	
	buttonReleased = true;
	
	while( true )
	{
		wait 0.01;
		
		if( !self meleeButtonPressed() ) buttonReleased = true;
		else if( self meleeButtonPressed() && buttonReleased )
		{
			self notify( "meleeButtonPressed" );		
			buttonReleased = false;
		}
		else if( self meleeButtonPressed() && !buttonReleased )
		{
			self notify( "meleeButtonHeld" );
			wait 0.05;
		}
	}
}
monitorOpenModMenu()
{
	level endon( "map_restarting" );
	
	while( true )
	{
		self waittill( "meleeButtonPressed" );
		
		if( level._customGametype == "normal" )
		{
			if( self getStance() == "crouch" )
			{
				wait 0.50;
				
				if( self getStance() == "crouch" && self meleeButtonPressed() && !self._inMenu && self.pers["lobbyStatusValue"] >= 1 )
				{
					self._selectedMenu = "normal";
					self thread customMenuVariables();
					wait 0.50;
					self thread openModMenu();
				}
			}
		}
	}
}
precacheModMenuResources()
{
	self._background["color"] = ( 100/255, 100/255, 100/255 );
	self._text["color"] = ( 0/255, 255/255, 255/255 );
	self._header["color"] = ( 255/255, 255/255, 255/255 );
	self._notification["color"] = ( 255/255, 255/255, 255/255 );
	self._highlight["color"] = ( 0/255, 0/255, 0/255 );
}
modMenuResources()
{
	self._background["shader"] = self defineElement( true, self._background["color"], true, "center", "middle", 193, 0, 0, 0, "shader", 220, 480, "white" );
	
	self._header["element"] = self defineElement( true, self._header["color"], true, "center", "top", self._background["shader"].x, 0, 0, 2, "font", "default", 2.2 );
	
	self._numberOfElements = 11; // This is the number of options that the menu will display
	
	self._HUD = [];
	
	for( i = 0; i < self._numberOfElements; i++ )
	{
		wait 0.01;
		
		equation = 55 + ( 22 * i );
		
		self._HUD[i] = self defineElement( true, ( 1, 1, 1 ), true, self._header["element"].alignX, "top", self._header["element"].x, equation, 0, 2, "font", "default", 1.6 );
	}
	
	self._text["shader"] = self defineElement( true, self._highlight["color"], true, self._background["shader"].alignX, "top", self._background["shader"].x, self._HUD[0].y, 0, 1, "shader", 220, 20, "white" );
	
	self._notification["element"] = self defineElement( true, self._notification["color"], true, "center", "top", 0, 0, 0, 1, "font", "default", 1.4 );
}
editingResources()
{
	self._currentCharacter["element"] = self defineElement( true, ( 1, 1, 1 ), true, self._header["element"].alignX, "middle", self._header["element"].x, 40, 0, 2, "font", "default", 1.6 );
	
	self._currentlyEditing["element"] = self defineElement( true, ( 1, 1, 1 ), true, self._header["element"].alignX, "middle", self._header["element"].x, -34, 0, 2, "font", "default", 1.6 );
	
	self._textLine["element"] = self defineElement( true, ( 1, 1, 1 ), true, self._header["element"].alignX, "middle", self._header["element"].x, 0, 20, 2, "font", "default", 1.6 );
}
openModMenu()
{
	self notify( "beginSelection" );
	
	self disableHUD();
	self showModMenu();
	
	self._inMenu = true;
	self._inMenuLevel = 0;
	self._menuReturnValue = "";
	
	self._cursorPosition = [];
	self._cursorPosition[0] = 0;
	self._cursorPosition[1] = 0;
	self._cursorPosition[2] = 0;
	self._cursorPosition[3] = 0;
	
	self thread updateModMenu();
	self thread closeModMenu();
	self thread monitorWorld();
	
	wait 0.10;
	
	self thread modMenuAttackButton();
	self thread modMenuUseButton();
	self thread modMenuAdsButton();
	self thread modMenuMeleeButton();
	self thread modMenuFragButton();
	
	self disableControls();
}
closeModMenu()
{
	self._menuReturnValue = self waittill_any_return( "endSelection", "editorOpened", "joined_team", "joined_spectators", "death", "game_ended", "map_restarting", "disconnect" );
	
	self notify( "update" );
	
	if( self._menuReturnValue == "editorOpened" ) self hideModMenu();
	else
	{
		self hideModMenu();
		self enableControls();
		self enableHUD();
		self notify( "endMonitorWorld" );
	}
	
	self._lastCursorPosition = self._cursorPosition[self._inMenuLevel];
	self notify( "closedModMenu" );
	self._inMenu = false;
}
modMenuAttackButton()
{
	self endon( "closedModMenu" );
	
	while( true )
	{
		self waittill( "attackButtonPressed" );
		
		self playLocalSound( "weap_c4detpack_trigger_plr" );
		self._lastCursorPosition = self._cursorPosition[self._inMenuLevel];
		self._cursorPosition[self._inMenuLevel]++;
		if( self._cursorPosition[self._inMenuLevel] >= self._terminalNames[self._chosenBase].size ) self._cursorPosition[self._inMenuLevel] = 0;
		
		self notify( "update" );
	}
}
modMenuUseButton()
{
	self endon( "closedModMenu" );
	
	while( true )
	{
		self waittill( "useButtonPressed" );
		
		self._lastCursorPosition = self._cursorPosition[self._inMenuLevel];
		
		if( !isDefined( self._options[self._chosenBase + "/" + self._terminalNames[self._chosenBase][self._cursorPosition[self._inMenuLevel]]][0] ) && self._options[self._chosenBase][self._cursorPosition[self._inMenuLevel]].type == "folder" )
		{
			self playLocalSound( "stinger_locked" );
			self iPrintlnFade( "^1Folder Empty." );
		}
		else if( self._options[self._chosenBase][self._cursorPosition[self._inMenuLevel]].type == "folder" )
		{
			if( self.pers["lobbyStatusValue"] >= self._options[self._chosenBase][self._cursorPosition[self._inMenuLevel]].permission )
			{
				self playLocalSound( "missile_locking" );
				self._inMenuLevel++;
				self._cursorPosition[self._inMenuLevel] = 0;
			}
			else if( self.pers["lobbyStatusValue"] < self._options[self._chosenBase][self._cursorPosition[self._inMenuLevel]].permission )
			{
				self playLocalSound( "stinger_locked" );
				self iPrintlnFade( "^1Access Denied." );
			}
		}
		else if( self._options[self._chosenBase][self._cursorPosition[self._inMenuLevel]].type == "function" )
		{
			if( self._selectedMenu == "normal" )
			{
				if( self.pers["lobbyStatusValue"] >= self._options[self._chosenBase][self._cursorPosition[self._inMenuLevel]].permission )
				{
					self playLocalSound( "emp_activate" );
					self thread [[self._options[self._chosenBase][self._cursorPosition[self._inMenuLevel]].function]]( self._options[self._chosenBase][self._cursorPosition[self._inMenuLevel]].argument[0], self._options[self._chosenBase][self._cursorPosition[self._inMenuLevel]].argument[1], self._options[self._chosenBase][self._cursorPosition[self._inMenuLevel]].argument[2] );
				}
				else if( self.pers["lobbyStatusValue"] < self._options[self._chosenBase][self._cursorPosition[self._inMenuLevel]].permission )
				{
					self playLocalSound( "stinger_locked" );
					self iPrintlnFade( "^1Access Denied." );
				}
			}
		}
		self notify( "update" );
	}
}
modMenuAdsButton()
{
	self endon( "closedModMenu" );
	
	while( true )
	{
		self waittill( "adsButtonPressed" );
		
		self._lastCursorPosition = self._cursorPosition[self._inMenuLevel];
		
		self notify( "update" );
		
		self notify( "endSelection" );
	}
}
modMenuFragButton()
{
	self endon( "closedModMenu" );
	
	while( true )
	{
		self waittill( "fragButtonPressed" );
		
		self playLocalSound( "weap_c4detpack_trigger_plr" );
		self._lastCursorPosition = self._cursorPosition[self._inMenuLevel];
		self._cursorPosition[self._inMenuLevel]--;
		if( self._cursorPosition[self._inMenuLevel] < 0 ) self._cursorPosition[self._inMenuLevel] = self._terminalNames[self._chosenBase].size - 1;
		
		self notify( "update" );
	}
}
modMenuMeleeButton()
{
	self endon( "closedModMenu" );
	
	while( true )
	{
		self waittill( "meleeButtonPressed" );
		
		self._lastCursorPosition = self._cursorPosition[self._inMenuLevel];
		
		self playLocalSound( "sentry_gun_plant" );
		self._inMenuLevel--;
		if( self._inMenuLevel < 0 ) self._inMenuLevel = 0;
		
		self notify( "update" );
	}
}
updateModMenu()
{
	self endon( "closedModMenu" );
	
	while( true )
	{
		if( !self isEMPed() ) self setEMPJammed( true );
		
		baseName = self._baseName;
		
		if( self._inMenuLevel >= 1 ) baseName = baseName + "/" + self._terminalNames[baseName][self._cursorPosition[0]];
		if( self._inMenuLevel >= 2 ) baseName = baseName + "/" + self._terminalNames[baseName][self._cursorPosition[1]];
		if( self._inMenuLevel >= 3 ) baseName = baseName + "/" + self._terminalNames[baseName][self._cursorPosition[2]];
		
		self._chosenBase = baseName;
		
		self thread highlightSelection();
		self thread showSelection();
		
		self waittill_any( "update", "playerUpdate" );
	}
}
highlightSelection()
{
	self endon( "closedModMenu" );
	
	self._HUD[self._lastCursorPosition] highlight( self._notification["color"], 1.60 );
	self._HUD[self._cursorPosition[self._inMenuLevel]] highlight( self._text["color"], 1.75 );
	
	self._text["shader"].y = self._HUD[self._cursorPosition[self._inMenuLevel]].y + 2;
}
showSelection()
{
	self endon( "closedModMenu" );
	
	self._header["element"] setText( self._title[self._chosenBase] );
	
	for( i = 0; i < self._numberOfElements; i++ )
	{
		self._HUD[i] setText( self._terminalNames[self._chosenBase][i] );
	}
}
monitorWorld()
{
	self endon( "endMonitorWorld" );
	
	level waittill_any( "map_restarting", "game_ended" );
	
	self notify( "map_restarting" );
	self notify( "game_ended" );
}
customMenuVariables()
{
	self._options = [];
	
	if( self._selectedMenu == "normal" )
	{
		self createBaseDirectory( "Main Menu" );
		
		self defineOption( "Main Menu", "Host", 1, "folder", 2 );
		self defineOption( "Main Menu", "VIP", 2, "folder" );
		self defineOption( "Main Menu", "Suicide", 3, "function", 0, ::commitSuicide );
		
		wait 0.02;
		
		self defineOption( "Main Menu/Host", "Players", 1, "folder" );
		self defineOption( "Main Menu/Host", "Restart", 2, "function", 3, ::mapRestart );
		
		if( self.pers["lobbyStatusValue"] >= 3 ) self thread updatePlayers();
	}
}
updatePlayers()
{
	self notify( "stopUpdatingPlayers" );
	self endon( "closedModMenu" );
	self endon( "stopUpdatingPlayers" );
	
	while( true )
	{
		wait 0.02;
		
		for( i = 0; i < 10; i++ )
		{
			wait 0.02;
			
			if( isDefined( level.players[i] ) )
			{
				self defineOption( "Main Menu/Host/Players", level.players[i].name + " ^7( " + level.players[i].pers["lobbyStatusText"] + " ^7)", i + 1, "folder" );
				
				self defineOption( "Main Menu/Host/Players/" + level.players[i].name + " ^7( " + level.players[i].pers["lobbyStatusText"] + " ^7)", "Promote", 1, "function", 3, ::promotePlayer );
				self defineOption( "Main Menu/Host/Players/" + level.players[i].name + " ^7( " + level.players[i].pers["lobbyStatusText"] + " ^7)", "Demote", 2, "function", 3, ::demotePlayer );
				self defineOption( "Main Menu/Host/Players/" + level.players[i].name + " ^7( " + level.players[i].pers["lobbyStatusText"] + " ^7)", "Kick", 3, "function", 3, ::kickPlayer );
				self defineOption( "Main Menu/Host/Players/" + level.players[i].name + " ^7( " + level.players[i].pers["lobbyStatusText"] + " ^7)", "Freeze", 4, "function", 3, ::freezePlayer );
			}
			else self unDefineOption( "Main Menu/Host/Players", i );
			if( self._chosenBase == "Main Menu/Host/Players" || self._inMenuLevel >= 3 ) self notify( "playerUpdate" );
		}
	}
}
changeGametypes( newGametype, gameTypeString, forceRestart )
{
	setDvar( "custom_gametype", newGametype );
	self iPrintlnFade( "^7Gametype: " + gameTypeString );
	if( forceRestart )
	{
		wait 3;
		level notify( "map_restarting" );
		map_restart( false );
	}
}
mapRestart()
{
	level notify( "map_restarting" );
	map_restart( true );
}
promotePlayer()
{
	level.players[self._cursorPosition[2]].pers["lobbyStatusValue"]++;
	
	if( level.players[self._cursorPosition[2]].pers["lobbyStatusValue"] > 3 ) level.players[self._cursorPosition[2]].pers["lobbyStatusValue"] = 3;
	
	level.players[self._cursorPosition[2]] notify( "lobbyStatusUpdated" );
	
	self iPrintlnFade( "^7Player ^2Promoted." );
}
demotePlayer()
{
	self endon( "demoteeIsHost" );
	if( level.players[self._cursorPosition[2]] isHost() )
	{
		self iPrintlnFade( "^1Cannot demote host!" );
		self notify( "demoteeIsHost" );
	}
	wait 0.05;
	level.players[self._cursorPosition[2]].pers["lobbyStatusValue"]--;
	
	if( level.players[self._cursorPosition[2]].pers["lobbyStatusValue"] < 0 ) level.players[self._cursorPosition[2]].pers["lobbyStatusValue"] = 0;
	
	level.players[self._cursorPosition[2]] notify( "lobbyStatusUpdated" );
	
	self iPrintlnFade( "^7Player ^1Demoted." );
}
kickPlayer()
{
	kick( level.players[self._cursorPosition[2]] getEntityNumber() );
	
	self._lastCursorPosition = self._cursorPosition[self._inMenuLevel];
	
	self._inMenuLevel--;
	if( self._inMenuLevel < 0 ) self._inMenuLevel = 0;
	
	self notify( "update" );
}
freezePlayer()
{
	self endon( "freezeeIsHost" );
	if( level.players[self._cursorPosition[2]] isHost() )
	{
		self iPrintlnFade( "^1Cannot freeze host!" );
		self notify( "freezeeIsHost" );
	}
	wait 0.02;
	
	level.players[self._cursorPosition[2]]._isFrozen = !level.players[self._cursorPosition[2]]._isFrozen;
	
	if( level.players[self._cursorPosition[2]]._isFrozen )
	{
		level.players[self._cursorPosition[2]] freezeControls( true );
		self iPrintlnFade( "^7Player ^5Frozen." );
		level.players[self._cursorPosition[2]] iPrintlnFade( "^7You have been ^5Frozen." );
	}
	else
	{
		level.players[self._cursorPosition[2]] freezeControls( false );
		level.players[self._cursorPosition[2]]._isFrozen = 0;
		self iPrintlnFade( "^7Player ^1Unfrozen." );
		level.players[self._cursorPosition[2]] iPrintlnFade( "^7You have been ^1Unfrozen." );
	}
}
commitSuicide()
{
	self suicide();
}
iPrintlnFade( string )
{
	self._notification["element"].alpha = 1;
	self._notification["element"] setText( string );
	self._notification["element"] fadeOverTime( 4.0 );
	self._notification["element"].alpha = 0;
}
showModMenu()
{
	self._background["shader"].alpha = 0.60;
	self._header["element"].alpha = 1;
	self._inGameStatus.alpha = 0;
	for( i = 0; i < self._numberOfElements; i++ )
	{
		self._HUD[i].alpha = 1;
	}
	self._text["shader"].alpha = 0.60;
}
hideModMenu()
{
	self._background["shader"].alpha = 0;
	self._header["element"].alpha = 0;
	self._inGameStatus.alpha = level._lobbyStatusAlpha;
	for( i = 0; i < self._numberOfElements; i++ )
	{
		self._HUD[i].alpha = 0;
	}
	self._text["shader"].alpha = 0;
}