default
{
    state_entry()
    {
        llSay(0, "Chat bot started");
        llListen(0, "", "", "");
    }


    listen( integer channel, string name, key id, string message )
    {
        //llOwnerSay("heard:"+message);
        if( llSubStringIndex(message, "nice house" ) != -1) {
            llOwnerSay("say:nice house");
            llSay(0,"Why thank you, I'll tell my owner. 117 prims is not much to work with but I think it has not turned out too bad.");
        } else if( llSubStringIndex(message, "i get one" ) != -1 || llSubStringIndex(message, "I get one" ) != -1) {
            llOwnerSay("say:get 1");
            llSay(0,"Linden gave out these homes as part of a beta test. As I recall, emails were sent to paying members and the first 500 responders received a home. Many seem to still be empty though so some might still be available.");
llSay(0,"See https://blogs.secondlife.com/community/land/blog/2009/12/16/linden-home-beta-is-now-open");
        } else if( llSubStringIndex(message, "filar" ) != -1 || llSubStringIndex(message, "Filar" ) != -1) {
            llOwnerSay("say:filar");
            llSay(0,"Filar Firecaster's chat interface does not work well yet. Try IMing him.");
        }
    }        
}