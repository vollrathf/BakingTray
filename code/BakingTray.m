function BakingTray(varargin)
    % Creates a instance of the BT class and places it in the base workspace as hBT
    %
    % function BakingTray(varargin)
    %
    % Purpose
    % BakingTray startup function. Starts BT if it is not already started.
    %
    %
    % Optional Input args (param/val pairs
    % 'useExisting' - [false by default] if true, any existing BT object in the 
    %                 base workspace is used to start BakingTray
    % 'dummyMode' - [false by default on Windows, true otherwise] if true we run 
    %               BakingTray in dummy mode, which simulates the hardware. If 
    %               ScanImage is present on start then we connect to it. 
    %
    %
    % Rob Campbell - 2016

    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    %Parse optional arguments
    params = inputParser;
    params.CaseSensitive = false;
    params.addParameter('useExisting', false, @(x) islogical(x) || x==0 || x==1);
    params.addParameter('dummyMode', false, @(x) islogical(x) || x==0 || x==1);
    params.parse(varargin{:});

    useExisting=params.Results.useExisting;
    dummyMode=params.Results.dummyMode;

    if ~ispc
        dummyMode=true;
    end

    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 

    % Build optional arguments to feed to BT during its construction
    BTargs={};
    if dummyMode
        fprintf('\nStarting in dummy mode\n')
        BTargs = {'componentSettings',BakingTray.settings.dummy};
    else
        BTargs=[BTargs,{}];
    end

    %TODO: check component settings. If they aren't complete or look otherwise problematic,
    %      bring up a blocking warning/instruction dialog then quit without building anything. 

    %Does a BT object exist in the base workspace?
    evalin('base','clear ans') %Because it sometimes makes a copy of BT in ans when it fails
    hBT=BakingTray.getObject(true);

    if isempty(hBT)
        %If not, we build BT and place it in the base workspace
        try
            hBT = BT(BTargs{:});
            if dummyMode==true
                W = evalin('base','whos');
                if ismember('hSI',{W.name});
                    fprintf('Found an instance of ScanImage. Attaching it to BakingTray\n')
                    hBT.scanner=SIBT;
                    hBT.scanner.parent=hBT;
                end

            end
            % Place the BT object in the base workspace as a variable called "hBT"
            assignin('base','hBT',hBT);
        catch ME

            fprintf('Build of BT failed\n')
            delete(hBT) %Avoids blocked hardware controllers
            evalin('base','clear ans') %Because it sometimes makes a copy of BT in ans when it fails
            rethrow(ME)
        end

    else

        %If it does exist, we only re-use it if the user explicitly asked for this and there
        if useExisting
            assignin('base','hBT',hBT);
        elseif ~isSafeToMake_hBT
            %TODO: run delete ourselves?
            return
        end

    end %if isempty(hBT)


    if hBT.buildFailed
        fprintf('BakingTray failed to create an instance of BT. Quitting.\n')
        evalin('base','clear hBT')
        return
    end %if hBT.buildFailed


    %By this point we should have a functioning hBT object, which is the model in our model/view system

    % Now we make the view
    hBTview = BakingTray.gui.view(hBT);
    assignin('base','hBTview',hBTview);

    % If necessary, run an optional startup script (must be a script not a function)
    startupBT = fullfile(BakingTray.settings.settingsLocation,'startup_bt.m');
    if exist(startupBT,'file')
        run(startupBT)
    end

    fprintf('BakingTray has started\n')
    %That was easy!






%-------------------------------------------------------------------------------------------------------------------------
function safe = isSafeToMake_hBT
    % Return true if it's safe to copy the created BT object to a variable called "hBT" in
    % the base workspace. Return false if not safe because the variable already exists.

    W=evalin('base','whos');

    if strmatch('hBT',{W.name})
        fprintf('BakingTray seems to have already started. If this is an error, remove the variable called "hBT" in the base workspace.\n')
        fprintf('Then "%s" again.\n',mfilename)
        safe=false;
    else
        safe=true;
    end
