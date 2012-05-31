/*
 * This file is part of Undefined.
 *
 * Copyright © 2012, Kyle Repinski
 * Undefined is licensed under the GNU General Public License.
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

highlight( color, fontScale )
{
	self.color = color;
	self.fontScale = fontScale;
}
defineElement( client, color, hideWhenInMenu, alignX, alignY, xOffset, yOffset, alpha, sort, type, fontOrWidth, fontScaleOrHeight, shader )
{
	if( client ) definedElement = newClientHudElem( self );
	else definedElement = newHudElem();
	
	definedElement.color = color;
	definedElement.hideWhenInMenu = hideWhenInMenu;
	definedElement.x = xOffset;
	definedElement.y = yOffset;
	definedElement.alignX = alignX;
	definedElement.alignY = alignY;
	definedElement.horzAlign = alignX;
	definedElement.vertAlign = alignY;
	definedElement.alpha = alpha;
	definedElement.sort = sort;
	definedElement.foreground = true;
	
	if( type == "font" || type == "timer" )
	{
		definedElement.elemType = type;
		definedElement.font = fontOrWidth;
		definedElement.fontscale = fontScaleOrHeight;
		definedElement.baseFontScale = fontScaleOrHeight;
		definedElement.width = 0;
		definedElement.height = int( level.fontHeight * fontScaleOrHeight );
	}
	else if( type == "shader" && isDefined( shader ) )
	{
		definedElement setShader( shader, fontOrWidth, fontScaleOrHeight );
		definedElement.shader = shader;
	}
	else if( type == "icon" )
	{
		definedElement.elemType = type;
		definedElement.width = fontOrWidth;
		definedElement.height = fontScaleOrHeight;
		definedElement.baseWidth = fontOrWidth;
		definedElement.baseHeight = fontScaleOrHeight;
		
		if( isDefined( shader ) )
		{
			definedElement setShader( shader, fontOrWidth, fontScaleOrHeight );
			definedElement.shader = shader;
		}
	}
	
	return definedElement;
}
createBaseDirectory( name )
{
	self._baseName = name;
}
defineOption( baseName, name, optionNumber, type, permission, function, firstArgument, secondArgument, thirdArgument )
{
	titles = strTok( baseName, "/" );
	
	self._title[baseName] = titles[titles.size - 1];
	
	self._terminalNames[baseName][optionNumber - 1] = name;
	
	self._options[baseName][optionNumber - 1] = spawnStruct();
	
	self._options[baseName][optionNumber - 1].type = type;
	
	if( isDefined( permission ) ) self._options[baseName][optionNumber - 1].permission = permission;
	if( isDefined( function ) ) self._options[baseName][optionNumber - 1].function = function;
	
	if( isDefined( firstArgument ) ) self._options[baseName][optionNumber - 1].argument[0] = firstArgument;
	if( isDefined( secondArgument ) ) self._options[baseName][optionNumber - 1].argument[1] = secondArgument;
	if( isDefined( thirdArgument ) ) self._options[baseName][optionNumber - 1].argument[2] = thirdArgument;
}
unDefineOption( baseName, optionNumber )
{
	self._terminalNames[baseName][optionNumber] = undefined;
	
	self._options[baseName][optionNumber] = undefined;
}
disableControls()
{
	self disableWeapons();
	self allowAds( false );
	self allowJump( false );
	self allowSprint( false );
}
enableControls()
{
	self enableWeapons();
	self allowAds( true );
	self allowJump( true );
	self allowSprint( true );
}
enableHUD()
{
	self setEMPJammed( false );
	self setClientDvar( "cg_drawCrosshair", 1 );
	self setClientDvar( "cg_drawCrosshair3D", 1 );
	self setClientDvar( "cg_drawCrosshairNames", 1 );
	self setClientDvar( "cg_drawFriendlyNames", 1 );
	self setClientDvar( "cg_drawGun", 1 );
}
disableHUD()
{
	self setEMPJammed( true );
	self setClientDvar( "cg_drawCrosshair", 0 );
	self setClientDvar( "cg_drawCrosshair3D", 0 );
	self setClientDvar( "cg_drawCrosshairNames", 0 );
	self setClientDvar( "cg_drawFriendlyNames", 0 );
	self setClientDvar( "cg_drawGun", 0 );
}
destroyOnGameEnded( a, b, c, d, e, f )
{
	level waittill_any( "game_ended", "map_restarting" );
	
	if( isDefined( a ) ) a destroy();
	if( isDefined( b ) ) b destroy();
	if( isDefined( c ) ) c destroy();
	if( isDefined( d ) ) d destroy();
	if( isDefined( e ) ) e destroy();
	if( isDefined( f ) ) f destroy();
}