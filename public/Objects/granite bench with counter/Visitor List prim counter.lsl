// Global variables
list visitor_list;
float range = 20.0; // in meters
float rate = 1.0; // in seconds
float cloakSpeed = .5;

integer SIDE_TOP=0;
 
integer SIDE_FRONT=2;
 
// Functions
integer isNameOnList( string name )
{
    integer len = llGetListLength( visitor_list );
    integer i;
    for( i = 0; i < len; i++ )
    {
        if( llList2String(visitor_list, i) == name )
        {
            return TRUE;
        }
    }
    return FALSE;
}
 
setFloatText()
{
    vector pos = llGetPos();
    string buttonText = "This home has been furnished using (mostly) freebie prims (including drapes - touch box on table)";
    llSetText(buttonText, < 1, 1, 1 >, 1.0); // solid white text
    
}

// States
default
{
    state_entry()
    {
        llOwnerSay( "Visitor List Maker started...");
        llOwnerSay( "The owner can say 'help' for instructions."); 
        llSensorRepeat( "", "", AGENT, range, TWO_PI, rate );
        llListen(0, "", llGetOwner(), "");
        setFloatText();
        llSetTexture("Rock - Granite", ALL_SIDES);
        llSetTexture("NamePlate", SIDE_FRONT);
        llSetColor( < 1, 1, 1 >, ALL_SIDES );// white / clear to texture
        llSetAlpha(1.0,ALL_SIDES);   
    }
      
    on_rez(integer something)
    {
        setFloatText();
    }               
    
    touch_start(integer num_detected)
    {
        setFloatText();

        integer i;
        string avName;
        key avKey;

        for(i = 0; i < num_detected; ++i)
        {
            avKey = llDetectedKey(i);
            avName = llKey2Name(avKey);
            llSay(0,"Hello "+avName+ " feel free to look around");
        }
    }

    sensor( integer number_detected )
    {
        integer i;
        for( i = 0; i < number_detected; i++ )
        {
            if( llDetectedKey( i ) != llGetOwner() )
            {
                string detected_name = llDetectedName( i );
                if( isNameOnList( detected_name ) == FALSE )
                {
                    visitor_list += detected_name;
                    string url = "";
                    setFloatText();
                }
            }
                    integer x;
        float xf;
        for (x=9; x>=0; x--)
        {
            xf = x * .1;
            llSleep(cloakSpeed);
            llSetAlpha(xf,SIDE_FRONT);   
//            llSetColor( <xf, xf, xf >, SIDE_FRONT );
        }
        for (x=1; x<11; x++)
        {
            xf = x * .1;
            llSleep(cloakSpeed);
            llSetAlpha(xf,SIDE_FRONT);  
//            llSetColor( <xf, xf, xf >, SIDE_FRONT );
        }


        }    
    }
    
    listen( integer channel, string name, key id, string message )
    {
        if( id != llGetOwner() )
        {
            return;
        }
        
        if( message == "help" )
        {
            string listStr = "This object records the names of everyone who" ;
            listStr += "comes within "+ (string)range + " meters." ;
            listStr += "Commands the owner can say:" ;
            listStr += "'help'  - Shows these instructions." ;
            listStr += "'say list'   - Says the names of all visitors on the list.";
            listStr += "'reset list' - Removes all the names from the list." ;
            llOwnerSay(listStr);
        }
        else
        if( message == "say list" )
        {
            string listStr = "Visitor List:\n" ;
            integer len = llGetListLength( visitor_list );
            integer i;
            for( i = 0; i < len; i++ )
            {
                listStr += "\n";
                listStr += llList2String(visitor_list, i);
            }
            listStr += "\nTotal = ";
            listStr +=  (string)len; 
            llOwnerSay(listStr);
        }
        else
        if( message == "reset list" )
        {
            visitor_list = llDeleteSubList(visitor_list, 0, llGetListLength(visitor_list));
            llSay( 0, "Done resetting.");
        }
    }        
}

