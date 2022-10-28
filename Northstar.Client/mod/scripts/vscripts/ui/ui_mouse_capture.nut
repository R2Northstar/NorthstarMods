global function AddMouseMovementCaptureHandler
global function UICodeCallback_MouseMovementCapture

struct
{
    // a table (indexed using a menu) that contains an array of functionrefs (callbacks)
    table< var, array< void functionref(var capturePanel, int deltaX, int deltaY) > > MouseMovementCaptureFunctionsTable = {}
} file

// just a note for anyone trying to use this, the var in the functionref is the hud element that captured the input
void function AddMouseMovementCaptureHandler( var menu, void functionref( var capturePanel, int deltaX, int deltaY ) func )
{
    // if this menu already has a callback, just add to the array
    if ( menu in file.MouseMovementCaptureFunctionsTable )
    {
        file.MouseMovementCaptureFunctionsTable[menu].append(func)
    }
    // if not, create the array before we add to it
    else
    {
        file.MouseMovementCaptureFunctionsTable[menu] <- [func]
    }
}

void function UpdateMouseMovementCaptureFunctions( var capturePanel, int deltaX, int deltaY )
{
    var activeMenu = GetActiveMenu()
    // check that the menu is in the table before trying anything stupid
    if ( activeMenu in file.MouseMovementCaptureFunctionsTable )
    {
        // iterate through the different callback functions
        foreach ( void functionref(var menu, int deltaX, int deltaY) callback in file.MouseMovementCaptureFunctionsTable[activeMenu] )
        {
            // run the callback function
            callback(capturePanel, deltaX, deltaY)
        }
    }
}

void function UICodeCallback_MouseMovementCapture( var capturePanel, int deltaX, int deltaY )
{
    float screenScaleXModifier = 1920.0 / GetScreenSize()[0] // 1920 is base screen width
    float mouseXRotateDelta = deltaX * screenScaleXModifier * MOUSE_ROTATE_MULTIPLIER

    float screenScaleYModifier = 1080.0 / GetScreenSize()[1] // 1080 is base screen height
    float mouseYRotationDelta = deltaY * screenScaleYModifier * MOUSE_ROTATE_MULTIPLIER

    UpdateMouseMovementCaptureFunctions( capturePanel, deltaX, deltaY )

    RunMenuClientFunction( "UpdateMouseRotateDelta", mouseXRotateDelta, mouseYRotationDelta )
}