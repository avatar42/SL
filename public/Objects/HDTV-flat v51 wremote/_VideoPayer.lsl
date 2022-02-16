string version="0.2.0";
//string urlBase="http://dea42.com/SL/youTubeTv.jsp?key=";
string urlBase="https://www.youtube.com/embed/";
string urlOptions="?autoplay=1";

// config options
integer pChannel = 2222;
integer debug = 0; //1=on 0=off
float range = 10.0; // distance to check for avatars in meters
float interval = 10.0; // seconds between video changes
float rate = 2.0; // seconds between avatar checks
integer FRONT = 4; 
integer imMe = 0;

//vars for reading config data from card
string cardName = NULL_KEY;
key ncQuery1;
integer headerLines = 4;
integer lineNum = headerLines;

list picNames = [];
list picData = [];
integer picCount = 0;
integer picNum = 0;
integer loaded = 0;
integer itemOne=0;

// channel handles used to close old channels
integer listen_handle = 0;

vector HDscale = <3.17400, 0.01000, 1.78543>;
vector SDscale = <1.78543, 0.01000, 1.78543>;
key owner;  // get the key of the objects owner

sayVal() {
    if (debug)
    {
            list params= [PRIM_MEDIA_CONTROLS ,PRIM_MEDIA_CURRENT_URL,PRIM_MEDIA_HOME_URL,PRIM_MEDIA_AUTO_LOOP,PRIM_MEDIA_AUTO_PLAY];
             params += [PRIM_MEDIA_AUTO_SCALE];
             params += [PRIM_MEDIA_AUTO_ZOOM];
             params += [PRIM_MEDIA_FIRST_CLICK_INTERACT];
             params += [PRIM_MEDIA_WIDTH_PIXELS];
             params += [PRIM_MEDIA_HEIGHT_PIXELS ,PRIM_MEDIA_WHITELIST_ENABLE ,PRIM_MEDIA_WHITELIST,PRIM_MEDIA_PERMS_INTERACT];
             params += [ PRIM_MEDIA_PERMS_CONTROL ];
        list values = llGetPrimMediaParams( FRONT, params );
        string listStr = "Values List:\n" ;
        integer len = llGetListLength( values );
        integer i;
        for( i = 0; i < len; i++ )
        {
            listStr += "\n";
            listStr += llList2String(params, i);
            listStr += ":";
            listStr += llList2String(values, i);
        }
        listStr += "\nTotal = ";
        listStr +=  (string)len; 
        llSay(DEBUG_CHANNEL,listStr);
    }
}

loadData() {
    say("scale:"+(string) llGetScale());
    owner=llGetOwner();
    loaded = 0;
    picNames = [];
    picData = [];
    integer idx;
    string objectname;
    cardName = "Pic Data";
    // how many of that kind of inventory is in here?
    integer typecount = llGetInventoryNumber(INVENTORY_NOTECARD);  
    if (typecount > 0)
    {
        for (idx=0; idx<typecount;idx++)
        {
            objectname = llGetInventoryName(INVENTORY_NOTECARD,idx);
            dprint("Found:"+objectname);
            if (llSubStringIndex(objectname,"Pic Data") == 0)
            {
                cardName = objectname;
            }
        }            
        lineNum = headerLines - 1;
        picCount = 0;
        ncQuery1 = llGetNotecardLine(cardName, lineNum); 
 
    } else {
        llSay(0,"Could not find Pic Data notecard");
    }

}

integer whereNameOnList( string name )
{
    integer len = llGetListLength( picNames );
    integer i;
    for( i = 0; i < len; i++ )
    {
        if( llList2String(picNames, i) == name )
        {
            return i;
        }
    }
    return -1;
}
 
showPic() {
    string objectname = llList2String(picNames,picNum);
    dprint("loading "+objectname+":"+(string) picNum+" of " + (string) picCount);
    string  url=urlBase+(string)objectname+urlOptions;
    list params= [PRIM_MEDIA_CURRENT_URL,url,PRIM_MEDIA_HOME_URL,url,PRIM_MEDIA_CONTROLS,1,PRIM_MEDIA_AUTO_PLAY,1,PRIM_MEDIA_WIDTH_PIXELS,960,PRIM_MEDIA_HEIGHT_PIXELS,745];
    integer rtn = llSetPrimMediaParams( 4,  params );

    integer pidx = whereNameOnList( objectname );
    if( pidx > -1) {
        string dataLine =  trimComments(llList2String(picData,pidx));
        dprint("Found:"+dataLine);
        list data = llCSV2List( dataLine );
        string name = llList2String(data,0);
        llSetText(llList2String(data,2)+"   \n"+llList2String(data,3), <1.0, 1.0, 1.0>, 1.0);
        llSetTimerEvent(interval+llList2Integer(data,1));
        dprint(llList2String(data,1)+ "secs");
    } else {
        llSetText(objectname, <1.0, 1.0, 1.0>, 1.0);
        llSetTimerEvent(interval+300);
    }
    sayVal();

    picNum++;
    if (picNum >= picCount) {
        picNum = 0;
    }
}

imOwner(string msg) {
    if( imMe == 1) {
        llInstantMessage(owner,msg);
    }
}

// all debug messages should be sent through here
dprint(string msg) {
    if (debug)
    {
        llSay(DEBUG_CHANNEL,llGetScriptName( ) + ":" + msg);
    }
}

// all return type messages should be sent through here
sayStatus(string msg) {
    llOwnerSay(msg);
}

// all general messages and serious errors should be sent through here
say(string msg) {
    llSay(0,msg);
}

output(string msg) {
        string objName = llGetObjectName( );
        llSetObjectName("");
        llSay(0,msg);
        llSetObjectName(objName);
}

init() {
    //ensure we have a working listener but close the old one just to be safe
    if (listen_handle != 0) {
        llListenRemove(listen_handle);
    }
    listen_handle = llListen(pChannel, "", "", ""); 
    llSay(0,"Listening on channel "+ (string) pChannel);    
}

//trim line at #
string trimComments(string line) 
{
    integer idx = llSubStringIndex( line, "#" );
    return llGetSubString(line,0,idx);
}

// buttons fill from bottom up sort reoreder them so they will come out in right order
// bottom left -> right then bottom -> top order
list sortButtons(list btnList){
    dprint("in sortButtons()");

    return llList2List(btnList, -3, -1) +
        llList2List(btnList, -6, -4) +
        llList2List(btnList, -9, -7) +
        llList2List(btnList, -12, -10);

}

// build and display selection menu
showMenu (key av_key) {
        dprint("showMenu ("+(string) av_key+")");
    
    list buttons = ["Prev","Top","Next" ];
    string helpText = "Prev:Previous Page\nTop:First Page\nNext:Next Page\n";
    integer idx = itemOne; 
    integer itemNine = itemOne + 9;
    
    dprint("picData=("+(string)llGetListLength(picData)+")");
    if (itemNine > llGetListLength(picData) ) {
        itemNine = llGetListLength(picData);
    }
    dprint("Adding "+(string)itemOne+"-"+(string)itemNine);
    
    for (idx=itemOne; idx<itemNine;idx++)
    {
        string dataLine =  trimComments(llList2String(picData,idx));
        dprint("Found:"+dataLine);
        list data = llCSV2List( dataLine );
        buttons += [(string)idx ];
        helpText += (string)idx+":"+llList2String(data,2)+"\n";
    }                  
    
    dprint("av_key=("+(string)av_key+")");
    dprint("helpText=("+helpText+")");
    dprint("buttons=("+(string)llGetListLength(buttons)+")");
    dprint("pChannel=("+(string)pChannel+")");
    llDialog(av_key, 
           helpText, 
           sortButtons(buttons), 
           pChannel);    
}
// States
default
{
    changed(integer change) 
    {
        if (change & CHANGED_INVENTORY) 
        { 
            loadData();
        } else if (change & CHANGED_REGION_START) {
            //Sim restarted so reinit to be safe
            loadData();
        }
    }

    on_rez(integer something)
    {
        loadData();
    }

    state_entry()
    {
//        llInstantMessage(owner,"Powering up.");
        if (cardName == NULL_KEY) {
            loadData();
        } else {
            ncQuery1 = llGetNotecardLine(cardName, lineNum);  
        }
        llSensorRepeat( "", "", AGENT, range, TWO_PI, rate );
        llOffsetTexture(0.0, 0.0, FRONT);
        llScaleTexture(1.0, 1.0, FRONT);
        llSetTextureAnim(FALSE, FRONT, 0, 0, 0.0, 0.0, 1.0);
        say("Picture player started...");
        init();
    }
                     
    sensor( integer number_detected )
    {
//        llInstantMessage(owner,"Staying awake for:"+llDetectedName( 0 ));

    }
    
    state_exit()
    {
        llSetTimerEvent(0);
    }

     no_sensor() {
        imOwner("No one around so going to sleep.");
          state waiting;
     }

    touch_start(integer num_detected)
    {
        init();
        integer i = 0;
        for(; i<num_detected; ++i) {
            showMenu(llDetectedKey(i));
        }
    }
    
    listen(integer chan, string name, key id, string mes)
    {
        dprint("listen("+(string) chan+", "+name+", "+(string) id+", "+mes+")");
        if( mes == "help" ) {
            string listStr = "HDTV w/video player" ;
            listStr += "Commands the owner can say:\n" ;
            listStr += "'help'  - Shows these instructions.\n" ;
            listStr += "'IM me'  - toggles IM when TV starts up / shuts down.(owner only)\n" ;
            listStr += "\n" ;
            listStr += "'Top' opens remote.\n" ;
            output(listStr);
        }else if( llGetSubString(mes,0,6) == "IM me" ) {
            if( id != llGetOwner() && chan != pChannel) {
                return;
            }
            if (imMe == 0) {
                imMe = 1;
                say("IM me now on.");
            } else {
                imMe = 0;
                say("IM me now off.");
            }
        } else if (mes == "Prev") {
            itemOne = itemOne - 9;
            if (itemOne < 0) {
                itemOne = 0;
            }
            showMenu(id);
        } else if (mes == "Top") {
            itemOne = 0;
            showMenu(id);
        } else if (mes == "Next") {
            integer max = llGetListLength(picData) - 9;
            itemOne = itemOne + 9;
            if (itemOne > max) {
                itemOne = max;
            }
            showMenu(id);
        } else {
            integer pn = (integer) mes;
            if (pn < llGetListLength(picData)) {
                picNum = pn;
                showPic();
            }
        }
    }        


    

    dataserver(key queryId, string dataLinef) 
    {
        dprint("dataline:"+(string) lineNum+":"+dataLinef);
        if (queryId == ncQuery1) {
            // this is a line of our notecard
            if (dataLinef != EOF) {    
                string dataLine =  trimComments(dataLinef);
                if (lineNum == headerLines - 1) {
                    interval = (integer) dataLine;
                    llSetTimerEvent(0);
                    
                    lineNum = headerLines;
                    ncQuery1 = llGetNotecardLine(cardName, lineNum);  
                } else {
                    // comment of invaild line, skip
                    if (llStringLength(dataLine) < 6) {
                        lineNum++;
                        ncQuery1 = llGetNotecardLine(cardName, lineNum);
                    } else {
                        list data = llCSV2List( dataLine );
                        integer end = llGetListLength(data);
                        if(end < 3) {
                            lineNum++;
                            ncQuery1 = llGetNotecardLine(cardName, lineNum);
                        } else {
                            // format is:
                            // texture name,SD or HD,caption
                            string name = llList2String(data,0);
//                            llSetTexture(name, FRONT);    
//                            llSetText(llList2String(data,2), <1.0, 1.0, 1.0>, 1.0);
                            if(loaded == 0) {
                                picNames += name;
                                picData += dataLinef;
                                lineNum++;
                                picCount++;  
                                ncQuery1 = llGetNotecardLine(cardName, lineNum);
                            }
                        }                                
                    }    
                }
            } else {
                showPic();  
            }
        }

    }
   
    timer()
    {
        showPic();
    }
}
    

state waiting
{
    state_entry()
    {
        say( "Going into saver mode.");
//        llInstantMessage(owner,"Going into saver mode.");
        llSensorRepeat( "", "", AGENT, range, TWO_PI, rate );
    }

    sensor( integer number_detected )
    {
        imOwner("Starting up for:"+llDetectedName( 0 ));

        state default;
    }
    
    state_exit()
    {
        say("Powering back up.");
    }
    
}
