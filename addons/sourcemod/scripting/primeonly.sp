#pragma semicolon 1

#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <sdktools>
#include <colorvariables>
#include <autoexecconfig>
#define REQUIRE_PLUGIN
#include <SteamWorks>

#pragma newdecls required

char g_sPrefix[] = "[{blue}PrimeOnly{default}]";

ConVar gc_bEnableBlock;
ConVar gc_sWarnMessage;

public Plugin myinfo = 
{
	name = "[Trinityplay] Prime Only",
	author = "Hypr",
	description = "Checks client info and makes sure only accounts with Prime-status can join",
	version = PLUGIN_VERSION,
	url = "https://trinityplay.net"
};

public void OnPluginStart() {
	if (GetEngineVersion() != Engine_CSGO)
		SetFailState("Game is not supported. CS:GO ONLY");
	
	AddCommandListener(OnJoinTeam, "jointeam");
	
	RegCvars();
	RegCmds();
}

public void OnClientPostAdminCheck(int client) {
	
	if((k_EUserHasLicenseResultDoesNotHaveLicense == SteamWorks_HasLicenseForApp(client, 624820)) && gc_bEnableBlock.IntValue == 1)
		KickClient(client, "You need a Prime-status to play on this server!");
	
	return;
}

public void RegCmds() {
	RegConsoleCmd("sm_prime", sm_prime);
}

public void RegCvars() {
	AutoExecConfig_SetFile("primeonly"); // What's the configs name and location?
	AutoExecConfig_SetCreateFile(true); // Create config if it does not exist
	
	gc_bEnableBlock = AutoExecConfig_CreateConVar("sm_prime_enable", "1", "Decides what happens if a client without prime joins.\n0 = Nothing happens.\n1 = Client is kicked with a message saying prime is required.\n2 = Client can join but is instantly informed that prime is recommended.", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	gc_sWarnMessage = AutoExecConfig_CreateConVar("sm_prime_warn", "This server is highly recommending you to upgrade your account status to {limegreen}Prime{default}.", "If sm_prime_enable is set to 2, what are we telling the player?", FCVAR_NOTIFY);
	
	AutoExecConfig_ExecuteFile(); // Execute the config
	AutoExecConfig_CleanFile(); // Clean the .cfg from spaces etc.
}

public Action OnJoinTeam(int client, char[] cmd, int args) {
	
	char sWarnMsg[255];
	char sFormat[255];
	
	GetConVarString(gc_sWarnMessage, sWarnMsg, sizeof(sWarnMsg));
	Format(sFormat, sizeof(sFormat), "%s %s", g_sPrefix, sWarnMsg);
	sWarnMsg = sFormat;
	
	if(gc_bEnableBlock.IntValue == 2)
		CPrintToChat(client, "%s", sWarnMsg);

	return Plugin_Continue;
}

public Action sm_prime(int client, int args) {
	if(gc_bEnableBlock.IntValue == 1)
		CPrintToChat(client, "%s This server is protected from non-prime accounts!", g_sPrefix);
	else
		CPrintToChat(client, "%s This server is not exclusive to prime accounts!", g_sPrefix);
	
	return Plugin_Handled;
}