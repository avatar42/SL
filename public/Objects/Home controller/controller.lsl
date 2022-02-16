integer channel2 = 1002;
integer privacy = 0;

default
{
    state_entry()
    {
        llSetText("Touch me to toggle privacy drapes", <1.0, 1.0, 1.0>, 1.0);
        llListen(0, "", llGetOwner(), "");
        llListen(channel2, "", "", "");
        llSay(0, "Home controller online.");
    }

    touch_start(integer total_number)
    {
        if (privacy == 0) {
            llShout(channel2, "privacy:on");
            llOwnerSay("privacy:on.");
            privacy = 1;
        } else {
            llShout(channel2, "privacy:off");
            llOwnerSay("privacy:off.");
            privacy = 0;
        }
    }
    
    listen( integer channel, string name, key id, string message )
    {
        if( channel == 0 && id != llGetOwner() )
        {
            return;
        }
        
        if( message == "privacy:on" )
        {
            privacy = 1;
        }
        else
        if( message == "privacy:off" )
        {
            privacy = 0;
        }
    }        

}
