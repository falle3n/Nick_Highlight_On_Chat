/*

================================================================================
						Highlight nickname on chat - v1.0
						By fall3n

This is a simple filterscript which highlights online player's name if it's
typed on chat, just like on Skype calls or IRC chats. The highlight color either
can be a custom color or uses GetPlayerColor to get the player's color. If it
runs by using GetPlayerColor you will need to use SetPlayerColor or else
it might return black. By default, it uses a custom color.

LICENSE:

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
Credits:

fall3n - For the complete filterscript.
Y_Less - For foreach include.
SA-MP Team - For SA-MP!

NOTE : This include can run with or without foreach. I prefer using foreach.

RUN MODES :

If you undefined DEFAULT_HIGHLIGHT_COLOR - It will highlight the player name by
getting the player's color. If it's not set, it will return 0 which is black.

If you undefine SHOW_ID_ONCHAT - It will just highlight the player like on a
normal chat system provided by SA-MP.


Github release link:

https://github.com/falle3n/Nick_Highlight_On_Chat

================================================================================
*/
							
#define FILTERSCRIPT

#include <a_samp>
#include <foreach>

#define DEFAULT_HIGHLIGHT_COLOR "{c3e4f5}" //By default it's light blue colored.
#define SHOW_ID_ONCHAT //comment to use sa-mp default chat output system.


new
	g_PlayerName[MAX_PLAYERS][MAX_PLAYER_NAME];

stock strcpy(dest[], const source[], size = sizeof(dest))
{
	return strcat((dest[0] = '\0', dest), source, size);
}

public OnPlayerConnect(playerid)
{
	GetPlayerName(playerid, g_PlayerName[playerid], MAX_PLAYER_NAME);
	return 1;
}

public OnFilterScriptInit()
{
	for(new i, j = GetMaxPlayers(); i< j; i++)
	{
	    if(!IsPlayerConnected(i)) continue;
	    #if defined _inc_foreach
	    	CallLocalFunction("OnPlayerConnect", "i", i); //There are some issues with foreach so calling out local OPC.
		#endif
	    OnPlayerConnect(i); //script sided opc.
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
    new
		pos = -1,
		string[144]
		#if !defined DEFAULT_HIGHLIGHT_COLOR
			,cstr[12]
		#endif
	;

	strcpy(string, text, sizeof(string));
	#if !defined _inc_foreach
    for(new i, j = GetMaxPlayers(); i< j; i++)
    {
        if(!IsPlayerConnected(i)) continue;
	#else
	foreach(new i : Player)
	{
	#endif
		pos = strfind(string, g_PlayerName[i], false);
		if(pos != -1)
		{
		    strins(string, "{FFFFFF}", pos + strlen(g_PlayerName[i]), sizeof(string));
		    #if !defined DEFAULT_HIGHLIGHT_COLOR
		        format(cstr, sizeof(cstr), "{%06x}", GetPlayerColor(i) >>> 8);
				strins(string, cstr, pos, sizeof(string));
			#else
			    strins(string, #DEFAULT_HIGHLIGHT_COLOR, pos, sizeof(string));
			#endif
		}
	}
	#if !defined SHOW_ID_ONCHAT
	
	    //If you want the chat to work like how you want simply edit this section.
	    //Instead of using "text" parameter, keep using "string" from here.

		SendPlayerMessageToAll(playerid, string);
	#else
	    new
	        output[180],
			col = GetPlayerColor(playerid);
		format(output, sizeof(output), "%s (%d):{FFFFFF} %s", g_PlayerName[playerid], playerid, string);
		SendClientMessageToAll(((col == 0) ? 0xFF0000AA : col), output);
	#endif
	return 0;
}


