global function ClientCallBack_RequestDialog

void function ClientCallBack_RequestDialog( string header, string message, string image, string rightImage, bool forceChoice, bool noChoice, bool noChoiceWithNavigateBack, bool showSpinner, bool showPCBackButton, float inputDisableTime, bool darkenBackground, bool useFullMessageHeight, string button0Text, string button1Text, string button2Text, string button3Text )
{    
    DialogData dialogData

    dialogData.header = header
    dialogData.message = message

    // if ( image.find("/") != null )
    //     dialogData.image = asset( image ) // this doesn't work and using compilestring( "return $\"" + image + "\"" )() is not safe
    // if ( rightImage.find("/") != null )
    //     dialogData.rightImage = asset( rightImage )

    dialogData.forceChoice = forceChoice
    dialogData.noChoice = noChoice
    dialogData.noChoiceWithNavigateBack = noChoiceWithNavigateBack
    dialogData.showSpinner = showSpinner
    dialogData.showPCBackButton = showPCBackButton
    dialogData.inputDisableTime = inputDisableTime
    dialogData.darkenBackground = darkenBackground
    dialogData.useFullMessageHeight = useFullMessageHeight

    if ( button0Text != "." )
        AddDialogButton( dialogData, button0Text, button0CallBack ) // max is 4 buttons
    if ( button1Text != "." )
        AddDialogButton( dialogData, button1Text, button1CallBack )
    if ( button2Text != "." )
        AddDialogButton( dialogData, button2Text, button2CallBack )
    if ( button3Text != "." )
        AddDialogButton( dialogData, button3Text, button3CallBack )
    
    OpenDialog( dialogData )
}

void function button0CallBack()
{
    ClientCommand( "ns_button_dialog 0" )
}

void function button1CallBack()
{
    ClientCommand( "ns_button_dialog 1" )
}

void function button2CallBack()
{
    ClientCommand( "ns_button_dialog 2" )
}

void function button3CallBack()
{
    ClientCommand( "ns_button_dialog 3" )
}