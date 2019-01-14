function [initialX, Lambda, Gamma] = rand_contamination_components(n, runlength, seed)
if (runlength <= 0) || (seed <= 0) || (round(seed) ~= seed)
    fprintf('\nrunlength should be positive and real, seed should be a positive integer.\n');
    initialX=NaN;
    Lambda=NaN;
    Gamma=NaN;
else
    %% *********************PARAMETERS*********************
    nGen=runlength;          %number of independent generations
%     u=x;                     %prevention binary decision variable
    X=zeros(n,nGen);         %fraction contaminated at each stage for each generation
    epsilon=.05*ones(n,1);   %error probability
    p=.1*ones(n,1);          %proportion limit
    cost=ones(n,1);          %cost for prevention at stage i
    %Beta parameters for initial contamination, contamination rate,
    %restoration rate
    initialAlpha=1;
    initialBeta=30;
    contamAlpha=1;
    contamBeta=17/3;
    restoreAlpha=1;
    restoreBeta=3/7;
    
    %% GENERATE RANDOM NUMBER STREAMS
    % Generate new streams for
    [InitialStream, ContaminationStream, RestorationStream] = RandStream.create('mrg32k3a', 'NumStreams', 3);
    % Set the substream to the "seed"
    InitialStream.Substream = seed;
    ContaminationStream.Substream = seed;
    RestorationStream.Substream = seed;

    %% Generate initial fraction of contamination
    OldStream = RandStream.setGlobalStream(InitialStream); % Temporarily store old stream, for versions 2011 and later
    %OldStream = RandStream.setDefaultStream(InitialStream);%for versions 2010 and earlier
    % Generate initial fraction of contamination for stage 1 for each
    % generation
    initialX=betarnd(initialAlpha,initialBeta,1,nGen);
    
    %% Generate rates of contamination
    RandStream.setGlobalStream(ContaminationStream); %for Matlab versions 2011 and later
    %RandStream.setDefaultStream(ContaminationStream); % for versions 2010 and earlier
    
    % Generate rates of contamination for each stage and generation
    Lambda=betarnd(contamAlpha,contamBeta,n,nGen);
    
    %% Generate rates of restoration
    RandStream.setGlobalStream(RestorationStream); %for Matlab versions 2011 and later
    %RandStream.setDefaultStream(RestorationStream); %for Matlab versions 2010 and earlier
    % Generate rates of restoration for each stage and generation
    Gamma=betarnd(restoreAlpha,restoreBeta,n,nGen);
    
    RandStream.setGlobalStream(OldStream);                   % Restore old random number stream
    %RandStream.setDefaultStream(OldStream); %for versions 2010 and earlier
end
end