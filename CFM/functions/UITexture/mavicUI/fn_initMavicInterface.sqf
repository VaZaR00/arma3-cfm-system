/*
    Function: CFM_fnc_initMavicInterface
    Author: Vazar
    Description: Automatically generated SQF file.
*/

#include "defines.hpp" 

params[["_monitor", displayNull], ["_display", displayNull], ["_uiDisplayUniqueName", ""]];

GET_CTRL("DB_mavic_batteryPicture", 689)
GET_CTRL("DB_mavic_batteryText", 635)
GET_CTRL("DB_mavic_RemainingTimeText", 653)
GET_CTRL("DB_mavic_SignalText", 624)
GET_CTRL("DB_mavic_SatellitePicture", 385)
GET_CTRL("DB_mavic_FlightStatus_Text", 824)
GET_CTRL("DB_mavic_VSpeed_control", 375)
GET_CTRL("DB_mavic_HSpeed_control", 952)
GET_CTRL("DB_mavic_Height_control", 214)
GET_CTRL("DB_mavic_Distance_control", 458)
GET_CTRL("DB_mavic_Zoom_Text", 278)
GET_CTRL("DB_mavic_R2TPicture", 1488)
GET_CTRL("DB_mavic_EffectPicture", 1489)

[_display displayCtrl 1488, [DISP_CTRL 1489]]
