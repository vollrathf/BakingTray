function success=resumeAcquisition(obj,recipeFname)
    % Attach recipe  BT
    %
    % function success=resumeAcquisition(obj,recipeFname)
    %
    % Purpose
    % Attempts to resume an existing acquisition, by appropriately setting
    % the section start number, end number, and so forth. If resumption fails 
    % the default recipe is loaded instead and the acquisition path is set to 
    % an empty string. This is a safety feature to ensure that the user *has*
    % to consciously decide what to do next. 
    %
    %
    % Inputs
    % recipeFname - The path to the recipe file of the acquisition we hope to 
    %         resume. name of
    %
    % Outputs
    % success - Returns true if the resumption process succeeded and
    %           the system is ready to start.
    %

    if nargin<2
        recipeFname=[];
    end

    success=false;
    if ~exist(recipeFname,'file')
        fprintf('No recipe found at %s - BT.resumeAcquisition is quitting\n', recipeFname)
        return
    end

    pathToRecipe = fileparts(recipeFname);
    [containsAcquisition,details] = BakingTray.utils.doesPathContainAnAcquisition(pathToRecipe);

    if ~containsAcquisition
        fprintf(['No existing acquisition found in in directory %s.', ...
            'BT.resumeAcquisition will just load the recipe as normal\n'], pathToRecipe) %NOTE: the square bracket here was missing and MATLAB didn't spot the syntax error. When this methd was run it would hard-crash due to this
        success = obj.attachRecipe(recipeFname);
        return
    end


    % If we're here, then the path exists and acquisition should exist in the path. 
    % Attempt to set up for resuming the acquisition:

    % Finally we attempt to load the recipe
    success = obj.attachRecipe(recipeFname,true); % sets resume flag to true

    if ~success
        fprintf('Failed to resume recipe %s. Loading default.\n', recipeFname)
        obj.sampleSavePath=''; % So the user is forced to enter this before proceeding 
        obj.attachRecipe; % To load the default
        return
    end

    obj.sampleSavePath = pathToRecipe;

    % Set the section start number and num sections
    originalNumberOfRequestedSections = obj.recipe.mosaic.numSections;
    sectionsCompleted = length(details.sections);

    newSectionStartNumber = sectionsCompleted+1;
    newNumberOfRequestedSections = originalNumberOfRequestedSections-newSectionStartNumber+1;

    obj.recipe.mosaic.sectionStartNum = newSectionStartNumber;
    obj.recipe.mosaic.numSections = newNumberOfRequestedSections;

    % Delete the FINISHED file if it exists
    if exist(fullfile(pathToRecipe,'FINISHED'),'file')
        fprintf('Deleting FINISHED file\n')
        delete(fullfile(pathToRecipe,'FINISHED'))
    end

    % TODO: Look in the final section and check whether all tiles were acquired
    if 1
        extraZMove = obj.recipe.mosaic.sliceThickness;
    else
        extraZMove=0;
    end

    % So now we are safe to move the system to the last z-position plus one section
    blocking=true;
    obj.moveZto(details.sections(end).Z + extraZMove, blocking);

    % Set up the scanner as it was before. We have to manually read the scanner
    % field from the recipe, as the "live" version in the object be overwritten
    % with the current scanner settings.
    tmp=BakingTray.settings.readRecipe(recipeFname);
    if isempty(tmp)
        fprintf('BT.resumeAcquisition failed to load recipe file for applying scanner settings\n')
        return
    end
    obj.scanner.applyScanSettings(tmp.ScannerSettings)

