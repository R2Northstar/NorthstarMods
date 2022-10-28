untyped // untyped purely so I can index into a table with var

global function AddMouseMovementCaptureHandler
global function UICodeCallback_MouseMovementCapture

struct
{
    // a table of capturePanels, each of which contains an array of callbacks
    table< var, array< void functionref( int deltaX, int deltaY ) > > mouseMovementCaptureCallbacks = {}
} file

void function AddMouseMovementCaptureHandler( var capturePanel, void functionref( int deltaX, int deltaY ) func )
{
    // if the capturePanel already has an array in the table, we append to the array
    // if not, we should create the array, [func] just turns func into an array
    if ( capturePanel in file.mouseMovementCaptureCallbacks )
        file.mouseMovementCaptureCallbacks[capturePanel].append(func)
    else
        file.mouseMovementCaptureCallbacks[capturePanel] <- [func]
}

void function UICodeCallback_MouseMovementCapture( var capturePanel, int deltaX, int deltaY )
{
    // check that the capturePanel is in the table before trying anything stupid
    if ( capturePanel in file.mouseMovementCaptureCallbacks )
    {
        // iterate through the different callback functions
        foreach ( void functionref( int deltaX, int deltaY ) callback in file.mouseMovementCaptureCallbacks[capturePanel] )
        {
            // run the callback function
            callback(deltaX, deltaY)
        }
    }

    // everything below here originally existed in vanilla sh_menu_models.gnut and is meant to be used for like all of their rotation stuff
    // its easier to move this here than to add a shared callback for all of the vanilla capture handlers (there are like >20)

    // this const was moved instead of made global because it was literally only used in the code below
    const MOUSE_ROTATE_MULTIPLIER = 25.0

    float screenScaleXModifier = 1920.0 / GetScreenSize()[0] // 1920 is base screen width
    float mouseXRotateDelta = deltaX * screenScaleXModifier * MOUSE_ROTATE_MULTIPLIER
    //printt( "deltaX:", deltaX, "screenScaleModifier:", screenScaleModifier, "mouseRotateDelta:", mouseRotateDelta )

    float screenScaleYModifier = 1080.0 / GetScreenSize()[1] // 1080 is base screen height
    float mouseYRotationDelta = deltaY * screenScaleYModifier * MOUSE_ROTATE_MULTIPLIER

    RunMenuClientFunction( "UpdateMouseRotateDelta", mouseXRotateDelta, mouseYRotationDelta )
}