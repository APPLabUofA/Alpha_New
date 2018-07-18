clear all
close all
ccc
% if matlabpool('size') == 0
%     matlabpool open
% end

exp = 'BikeOut';


%subs = {'004' '005' '006' '007' '008' '009' '010' '011' '012' '013' '014' '016'};
%subs = {'014'}; %to test on just one sub

nsubs = length(subs);
conds = {'In';'Out'};
nconds = length(conds);
Pathname = 'M:\Data\bike\BikeOut\';

if ~exist([Pathname 'segments\'])
    mkdir([Pathname 'segments\']);
end

[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

for i_sub = 1:nsubs
    for i_cond = 1:nconds
        
        Filename = [subs{i_sub} '_' exp '_' conds{i_cond} '.vhdr'];
        setname = Filename(1:end-5)

        EEG = pop_loadbv(Pathname, Filename);
                  
% get electrode locations
        EEG=pop_chanedit(EEG, 'load',{'M:\Analysis\Electrodelocs\Vamp_EOG_electrode_locs.ced' 'filetype' 'autodetect'});

% arithmetically rereference to linked mastoid
         for x=1:EEG.nbchan-2
             EEG.data(x,:) = (EEG.data(x,:)-((EEG.data(EEG.nbchan-2,:))*.5));
         end

% NO FILTER - DR. 
%        Filter the data with low pass of 30
%        EEG = pop_eegfilt( EEG, .1, 0, [], 0);  %high pass filter
%        EEG = pop_eegfilt( EEG, 0, 20, [], 0);  %low pass filter

         
        %change markers so they can be used by the gratton_emcp script
        if i_sub == 3 && i_cond == 1
            for i_event = 14:length(EEG.event)
                if strcmp (EEG.event(i_event).type,'S192')
                EEG.event(i_event).type = '6';
                end
            EEG.event(i_event).type = (EEG.event(i_event).type(end));                
            end 
        elseif i_sub == 3 && i_cond == 2
            for i_event = 3:length(EEG.event)-1
                if strcmp (EEG.event(i_event).type,'S192')
                EEG.event(i_event).type = '6';
                end
            EEG.event(i_event).type = (EEG.event(i_event).type(end));                
            end 
        elseif i_sub == 5 && i_cond == 2
            for i_event = 274:length(EEG.event)
                if strcmp (EEG.event(i_event).type,'S192')
                EEG.event(i_event).type = '6';
                end
            EEG.event(i_event).type = (EEG.event(i_event).type(end));                
            end 
            elseif i_sub == 11 && i_cond == 2;
            for i_event = 8:length(EEG.event)
                if strcmp (EEG.event(i_event).type,'S192')
                EEG.event(i_event).type = '6';
                end
            EEG.event(i_event).type = (EEG.event(i_event).type(end));                
            end 
        else
        for i_event = 3:length(EEG.event)
            if strcmp (EEG.event(i_event).type,'S192')
                EEG.event(i_event).type = '6';
        end 
            EEG.event(i_event).type = (EEG.event(i_event).type(end));
        end    
        end
        
        
 %epoch
 
%Changed from [-.2 1] to [-1 2]. DR
        EEG = pop_epoch( EEG, {  '1'  '2'  }, [-1  2], 'newname',  sprintf('%s epochs' , setname), 'epochinfo', 'yes'); %making the epochs longer is making the plot code not work. DR.  
        EEG = pop_rmbase( EEG, [-200    0]);

%         eeglab redraw
% 

        % Artifact rejection, trials with range >500 uV
        EEG = pop_eegthresh(EEG,1,[1:size(EEG.data,1)],-1000,1000,EEG.xmin,EEG.xmax,0,1);
        
        %   EMCP occular correction          
        temp_ocular = EEG.data(end-1:end,:,:); %to save the EYE data for after
        selection_cards = {'1','2' }; %different bin names, each condition should be separate
        EEG = gratton_emcp(EEG,selection_cards,{'VEOG'},{'HEOG'}); %this assumes the eye channels are called this
        EEG.emcp.table %this prints out the regression coefficients
        EEG.data(end-1:end,:,:) = temp_ocular; %replace the eye data
        
         %    Artifact rejection, trials with range >250 uV
        EEG = pop_rmbase( EEG, [-200 0]); %baseline again since this changed it
        EEG = pop_eegthresh(EEG,1,[1:size(EEG.data,1)-2],-500,500,EEG.xmin,EEG.xmax,0,1);

        tempEEG =   EEG;

   
        %now select the corrected trials
        EEG = pop_selectevent( tempEEG, 'type',1,'renametype','Target','deleteevents','on','deleteepochs','on','invertepochs','off');
        EEG = pop_editset(EEG, 'setname',[subs{i_sub} '_' exp '_' conds{i_cond} '_Corrected_Target']);
        EEG = pop_saveset( EEG, 'filename',[subs{i_sub} '_' exp '_' conds{i_cond} '_Corrected_Target.set'],'filepath',[Pathname 'segments\']);


        EEG = pop_selectevent( tempEEG, 'type',2 ,'renametype','Standard','deleteevents','on','deleteepochs','on','invertepochs','off');
        EEG = pop_editset(EEG, 'setname',[subs{i_sub} '_' exp '_' conds{i_cond} '_Corrected_Standard']);
        EEG = pop_saveset( EEG, 'filename',[subs{i_sub} '_' exp '_' conds{i_cond} '_Corrected_Standard.set'],'filepath',[Pathname 'segments\']);


    end %i_cond
end %i_sub
% 

%New addittions to code (still working on it) - Daniel

eeglab
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
EEG = pop_loadset('filename',{'001_BikeOut_Pilot_Corrected_Standard.set' '001_BikeOut_Pilot_Corrected_Target.set' '002_BikeOut_In_Corrected_Standard.set' '002_BikeOut_In_Corrected_Target.set' '002_BikeOut_Out_Corrected_Standard.set' '002_BikeOut_Out_Corrected_Target.set' '002_BikeOut_Pilot_Corrected_Standard.set' '002_BikeOut_Pilot_Corrected_Target.set' '003_BikeOut_In_Corrected_Standard.set' '003_BikeOut_In_Corrected_Target.set' '003_BikeOut_Out_Corrected_Standard.set' '003_BikeOut_Out_Corrected_Target.set' '004_BikeOut_In_Corrected_Standard.set' '004_BikeOut_In_Corrected_Target.set' '004_BikeOut_Out_Corrected_Standard.set' '004_BikeOut_Out_Corrected_Target.set' '005_BikeOut_In_Corrected_Standard.set' '005_BikeOut_In_Corrected_Target.set' '005_BikeOut_Out_Corrected_Standard.set' '005_BikeOut_Out_Corrected_Target.set' '006_BikeOut_In_Corrected_Standard.set' '006_BikeOut_In_Corrected_Target.set' '006_BikeOut_Out_Corrected_Standard.set' '006_BikeOut_Out_Corrected_Target.set' '007_BikeOut_In_Corrected_Standard.set' '007_BikeOut_In_Corrected_Target.set' '007_BikeOut_Out_Corrected_Standard.set' '007_BikeOut_Out_Corrected_Target.set' '008_BikeOut_In_Corrected_Standard.set' '008_BikeOut_In_Corrected_Target.set' '008_BikeOut_Out_Corrected_Standard.set' '008_BikeOut_Out_Corrected_Target.set' '009_BikeOut_In_Corrected_Standard.set' '009_BikeOut_In_Corrected_Target.set' '009_BikeOut_Out_Corrected_Standard.set' '009_BikeOut_Out_Corrected_Target.set' '010_BikeOut_In_Corrected_Standard.set' '010_BikeOut_In_Corrected_Target.set' '010_BikeOut_Out_Corrected_Standard.set' '010_BikeOut_Out_Corrected_Target.set' '011_BikeOut_In_Corrected_Standard.set' '011_BikeOut_In_Corrected_Target.set' '011_BikeOut_Out_Corrected_Standard.set' '011_BikeOut_Out_Corrected_Target.set' '012_BikeOut_In_Corrected_Standard.set' '012_BikeOut_In_Corrected_Target.set' '012_BikeOut_Out_Corrected_Standard.set' '012_BikeOut_Out_Corrected_Target.set' '013_BikeOut_In_Corrected_Standard.set' '013_BikeOut_In_Corrected_Target.set' '013_BikeOut_Out_Corrected_Standard.set' '013_BikeOut_Out_Corrected_Target.set' '014_BikeOut_In_Corrected_Standard.set' '014_BikeOut_In_Corrected_Target.set' '014_BikeOut_Out_Corrected_Standard.set' '014_BikeOut_Out_Corrected_Target.set' '016_BikeOut_In_Corrected_Standard.set' '016_BikeOut_In_Corrected_Target.set' '016_BikeOut_Out_Corrected_Standard.set' '016_BikeOut_Out_Corrected_Target.set'},'filepath','M:\\Data\\bike\\BikeOut\\segments\\');
[ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'study',0); 
EEG = eeg_checkset( EEG );
figure; pop_newtimef( EEG, 1, 1, [-200  998], [3         0.5] , 'topovec', 1, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'Oz', 'baseline',[0], 'plotphase', 'off', 'padratio', 1, 'winsize', 100);


 

