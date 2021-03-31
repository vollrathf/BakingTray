function settings=componentSettings
    % component settings file for BakingTray
    %
    % function settings=componentSettings
    %
    % The BakingTray anatomy system controls the following hardware and software components:
    % a) three-axis stage on which the sample moves
    % b) Vibratome to cut the sample
    % c) Scanning software package that handles the image acquisition, laser power modulation,
    %    and fast objective motion for imaging multiple optical planes. 
    % d) Communications with the excitation laser.
    %
    % BakingTray coordinates image acquisition and cutting using the above components. 
    % This settings file defines precisely what those components are: which piece of hardware
    % does what, how to connect to the hardware, and with what parameters. e.g. which COM 
    % port the laser is connected to and what are the motion limits on the linear stages. 
    %
    % You should fill out the following fields carefully according to the instructions in 
    % the associated comment lines. Particularly with the motion limits on the linear stages
    % it is **YOUR RESPONSIBILITY** to ensure that stages can not move too far and cause damage.
    %

 


    %-------------------------------------------------------------------------------------------
    % Laser
    % BakingTray communicates with the laser in order to stop acquiring if it loses modelock
    % and to turn off the laser at the end of acquisition. 
    laser.type='dummyLaser'; % One of: 'maitai', 'chameleon', or 'dummyLaser'
    laser.COM=[];  %3  COM port number on which the laser is attached. e.g. the scalar 1




    %-------------------------------------------------------------------------------------------
    % Cutter
    % The cutter component communicates with the vibratome.
    cutter.type='FaulhaberMCDC'; % One of: 'FaulhaberMCDC', 'dummyCutter'.
    cutter.COM=7;  % COM port number on which the cutter is attached




    %-------------------------------------------------------------------------------------------
    % Scanner
    % Scanning is achieved using separate piece of software which BakingTray controls via an API.
    % Currently only ScanImage is supported, although in principle you could write your own
    % scanning code. ScanImage can be freely downloaded here:
    % http://scanimage.vidriotechnologies.com/display/SIH/ScanImage+Home
    scanner.type='SIBT'; % One of: 'SIBT', 'dummyScanner'
    % This optionally rotates tiles the preview tiles to ensure that the live preview image looks
    % correct. 0 means no rotation. Rotates by -90 degrees: -1 or +90 degrees: +1; 180 deg: +/-2
    % Conventional closed-coupled systems likely need thiss set to -1
%     scanner.settings.tileRotate=-1;
    scanner.settings = [];

    % Set this to 1 if you are using PMT2100 series PMTs from ThorLabs and want the trip state of the 
    % units to be reset after each X/Y position for units that tripped and are disabled. If you 
    % don't have these PMTs, leave this setting at 0 (false).
    scanner.settings.doResetTrippedPMT=1;




    %-------------------------------------------------------------------------------------------
    % MOTION CONTROLLERS
    % The remaining sections relate to the motion controllers used to translate the sample
    % in X and Y and push it up and down in Z. To set up each motion axis you need to define 
    % the properties of the physical stage responsible for motion along that axis and the 
    % properties of the controller that commands the stage. For example:
    % - Most stages at least are associated with parameters that define the minimum and maximum 
    %   position you wish them to move to. Some stages might have other parameters. 
    % - Stage controllers will need to at least have the method of communication defined, such as
    %   a COM port or a serial number. 
    % You may need to install other software to get your stages working. Read the manuals that 
    % came with the stage. 
    %
    % When setting up for the first time, you should initially set the motion limits to be at or 
    % near the full range of the stage. Place the empty water bath on the stage, remove the objective
    % and blade holder, and confirm the stages move as expected and gauge roughly what are the limits
    % of motion along all three axes. e.g. how far can you go before you risk hitting the objective 
    % with the bath. Set the motion limit parameter such that this doesn't happen. Close and re-connect
    % to the stages. Confirm they do not execute potentially dangerous motions. Add the objective and
    % blade holder and confirm. Note that, for instance, the clearance on the blade holder will vary 
    % with Z position. Ensure that at no Z position will the blade holder hit the stage. 
    % It is **CRITICAL** that you carefully do this in order to avoid hardware damage. Do not proceed
    % with using the software until you are convinced that the stages can not enter a configuration
    % that could cause damage. You are liable for your own hardware. 


    %-------------------------------------------------------------------------------------------

    nC=1;
    % The "type" refers to the motion controller being used for this axis. 
    motionAxis(nC).type='C891'; % One of: 'C891', 'C863', 'C663','BSC201_APT','soloist', 'dummy_linearcontroller'
                            % There may be other available controllers. See
                            % the components/motion directory.
    motionAxis(nC).settings.connectAt.interface='usb';
    motionAxis(nC).settings.connectAt.ID='120047040';
    motionAxis(nC).settings.connectAt.controllerModel='C-891'; % Used mainly for PI hardwar which have a generic controller e.g. C-891
 

    motionAxis(nC).stage.type='genericPIstage'; % One of: 'genericPIstage',  'DRV014', 'AVS_100_25', 'haydon43K4U', or 'dummy_linearstage'
    motionAxis(nC).stage.settings.invertDistance = 1; % True or false. Set so positive motions are away for Y, Right for X, and up for Z000
    motionAxis(nC).stage.settings.positionOffset=0; % X and Y should be zero at motion midpoint. Z at bottom of range. Adjust this scalar to achieve this if needed.
    motionAxis(nC).stage.settings.axisName='xAxis'; %One of: 'xAxis', 'yAxis', or 'zAxis'
    motionAxis(nC).stage.settings.minPos=-33;
    motionAxis(nC).stage.settings.maxPos=45;

    % Note that this settings file assumes that the X and Y axes are handled by separate
    % controller units. In principle it's possible to add two axis to a single controller 
    % unit and have BakingTray handle this situation. If you require this, please file a
    % support issue at: https://github.com/BaselLaserMouse/bakingtray
    % Once this is working, you will add the second axis like this:
    % xaxis.stage(2).type='';
    % zaxis.stage(2).settings=[];


    % Remainng axes follow and are set up as above
    nC=2;
    motionAxis(nC).type='C891';
    motionAxis(nC).settings.connectAt.interface='usb';
    motionAxis(nC).settings.connectAt.ID='120047036';
    
    motionAxis(nC).settings.connectAt.controllerModel='C-891';
  
    motionAxis(nC).stage.type='genericPIstage';
    motionAxis(nC).stage.settings.invertDistance = -1;
    motionAxis(nC).stage.settings.positionOffset=0;
    motionAxis(nC).stage.settings.axisName='yAxis'; 
    motionAxis(nC).stage.settings.minPos=-6;
    motionAxis(nC).stage.settings.maxPos=22;


    nC=3;
    motionAxis(nC).stage.type='generic_AeroTechZJack';
    motionAxis(nC).type='ensemble';
    motionAxis(nC).settings.connectAt.interface='usb';
    motionAxis(nC).settings.connectAt.ID='618526-1-1';
    motionAxis(nC).settings.connectAt.controllerModel='ensemble';
    motionAxis(nC).stage.settings.invertDistance=1;
    motionAxis(nC).stage.settings.positionOffset=0;
    motionAxis(nC).stage.settings.axisName='zAxis';
    motionAxis(nC).stage.settings.minPos=0;
    motionAxis(nC).stage.settings.maxPos=22;




    %-------------------------------------------------------------------------------------------
    % Assemble the output structure
    % -----> DO NOT EDIT BELOW THIS LINE <-----
    settings.laser      = laser  ;
    settings.cutter     = cutter ;
    settings.scanner    = scanner;
    settings.motionAxis = motionAxis;
    %-------------------------------------------------------------------------------------------

