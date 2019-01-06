#pragma semicolon 1

#define PLUGIN_VERSION "1.0.2"
#define SERVERTAG "Prime,primeonly"

#include <sourcemod>
#include <sdktools>
#include <colorvariables>
#include <autoexecconfig>
#define REQUIRE_PLUGIN
#include <SteamWorks>

#pragma newdecls required

char g_sPrefix[] = "[{blue}PrimeOnly{default}]";

// Plugin ConVars
ConVar gc_bEnableBlock;
ConVar gc_sWarnMessage;
ConVar gc_bEnableTag;

public Plugin myinfo = 
{
	name = "[CS:GO] Prime Only",
	author = "Hypr",
	description = "Checks client info and makes sure only accounts with Prime-status can join",
	version = PLUGIN_VERSION,
	url = "https://trinityplay.net"
};

public void OnPluginStart() {
	if (GetEngineVersion() != Engine_CSGO)
		SetFailState("Game is not supported. CS:GO ONLY");
	
	AddCommandListener(OnJoinTeam, "jointeam");
	
	RegCvars();		// Register all ConVars
	RegCmds();		// Register all commands
	
	// Set server tag if enabled in config!
	if(gc_bEnableTag.IntValue == 1)
		SetTags();
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
	
	gc_bEnableBlock	= AutoExecConfig_CreateConVar("sm_prime_enable", "1", "Decides what happens if a client without prime joins.\n0 = Nothing happens.\n1 = Client is kicked with a message saying prime is required.\n2 = Client can join but is instantly informed that prime is recommended.", FCVAR_NOTIFY, true, 0.0, true, 2.0);
	gc_sWarnMessage	= AutoExecConfig_CreateConVar("sm_prime_warn", "This server is highly recommending you to upgrade your account status to {limegreen}Prime{default}.", "If sm_prime_enable is set to 2, what are we telling the player?", FCVAR_NOTIFY);
	gc_bEnableTag	= AutoExecConfig_CreateConVar("sm_prime_tags", "1", "Allow the plugin to adjust server tags to show that it's prime only?\n1 = Enable.\0 = Disable.", FCVAR_NOTIFY, true, 0.0, true, 1.0);
	
	AutoExecConfig_ExecuteFile(); // Execute the config
	AutoExecConfig_CleanFile(); // Clean the .cfg from spaces etc.
}

public void SetTags() {
	char sTags[255];
	ConVar gc_sTags = FindConVar("sv_tags");
	
	GetConVarString(gc_sTags, sTags, sizeof(sTags));
	
	if(StrContains(sTags, SERVERTAG, false) == -1) {
		char murderTag[64];
		Format(murderTag, sizeof(murderTag), ", %s", SERVERTAG);
		
		StrCat(sTags, sizeof(sTags), murderTag);
		SetConVarString(gc_sTags, sTags);
	}
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