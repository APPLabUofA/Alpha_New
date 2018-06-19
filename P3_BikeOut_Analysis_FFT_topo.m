clear all
close all

%%
%THIS CODE IS TO PLOT TOPOGRAPHIES%
%%

exp = 'BikeOut';
subs = {'004' '005' '006' '007' '008' '009' '010' '011' '012' '013' '014' '016'};
% subs = {'006';'007'}; %to test on just one sub

nsubs = length(subs);
conds = {'In'; 'Out'};
nconds = length(conds);
Pathname = 'M:\Data\bike\BikeOut\';
[ALLEEG EEG CURRENTSET ALLCOM] = eeglab;

pick_trials = 360; %pick per resample
%electrode = 7;% Pz
electrodes = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15]
perms = 1; %pick all the standard trials for each subject

i_count = 0;

power_out = zeros(61,nsubs,nconds,perms);
for i_sub = 1:nsubs
    for i_cond = 1:nconds
        
        i_count = i_count + 1;
        Filename = [subs{i_sub} '_' exp '_' conds{i_cond}];
        EEG = pop_loadset('filename',[Filename '_Corrected_Standard.set'],'filepath',[Pathname 'Segments\']);
        [ALLEEG, EEG, CURRENTSET] = eeg_store( ALLEEG, EEG, 0 );
     
        n_trials = ALLEEG(i_count).trials;
         for i_electrode = 1:length(electrodes)
        for i_perm = 1:perms 
            these_trials = randperm(n_trials,pick_trials);
               test = ALLEEG(i_count).data(:, :,these_trials) ;
               power = [];
               phase = [];
                 for i_pick = 1:pick_trials
                     tempdat = test(i_electrode,:,i_pick);
                    [power(:,i_pick) phase(:,i_pick) freqs] = kyle_fft(tempdat,EEG.srate,30);
%                     power(2:end,i_pick) = power(2:end,i_pick) - mean(power(2:end,i_pick,1)); %subtract mean spectra
                 end
        end
                power_out(:,i_sub,i_cond,i_perm, i_electrode) = mean(power(2:end,:),2);
                
        
        end
 
    end
end
eeglab redraw

mean_power_out = squeeze(mean(power_out,2));
stderr_power_out = squeeze(std(power_out,[],2))./sqrt(nsubs);
figure; boundedline(freqs(2:end),mean_power_out(:,1),stderr_power_out(:,1), 'b', freqs(2:end),mean_power_out(:,2),stderr_power_out(:,2), 'g', freqs(2:end),mean_power_out(:,3),stderr_power_out(:,3), 'r' ); axis tight; ylim([1 3.5])
legend(conds)
% 
%Stats
%  power_out(:,i_sub,i_cond,i_perm) = mean(power(2:end,:),2);
% 
% % sub_meansMMN1 = squeeze(mean(erp_diff_out(time_window,9,1,:),1));
% % sub_meansMMN2 = squeeze(mean(erp_diff_out(time_window,9,2,:),1));
% % sub_meansMMN3 = squeeze(mean(erp_diff_out(time_window,9,3,:),1));
% 
% sub_meansfreq1 = squeeze(mean(erp_diff_out(time_window,9,1,:),1));
%  sub_meansfreq2 = squeeze(mean(erp_diff_out(time_window,9,2,:),1));
%  sub_meansfreq3 = squeeze(mean(erp_diff_out(time_window,9,3,:),1));
%  
 
% figure;
% subplot(3,1,1);
% rms_perm_mean = squeeze(mean(rms_out,1));
% hist(rms_perm_mean(1,:),50); 
%  hold on; hist(rms_perm_mean(2,:),50); hold on; hist(rms_perm_mean(3,:),50);
%  g=findobj(gca,'Type','patch');
% set(g(1),'FaceColor',[.9 0 0],'EdgeColor','k');
% set(g(2),'FaceColor',[0 .9 0],'EdgeColor','k');
% set(g(3),'FaceColor',[0 0 .9],'EdgeColor','k');
% 
% subplot(3,1,2);
% rms_erp_perm_mean = squeeze(mean(rms_erp_out,1));
%  hist(rms_erp_perm_mean(1,:),50); 
%  hold on; hist(rms_erp_perm_mean(2,:),50); hold on; hist(rms_erp_perm_mean(3,:),50);
%  g=findobj(gca,'Type','patch');
% set(g(1),'FaceColor',[.9 0 0],'EdgeColor','k');
% set(g(2),'FaceColor',[0 .9 0],'EdgeColor','k');
% set(g(3),'FaceColor',[0 0 .9],'EdgeColor','k');
% 
% subplot(3,1,3);
% mean_erp_out = squeeze(mean(erp_out,2));
% rms_mean_erp_out = squeeze(rms(mean_erp_out,1));
% hist(rms_mean_erp_out(1,:),50); 
%  hold on; hist(rms_mean_erp_out(2,:),50); hold on; hist(rms_mean_erp_out(3,:),50);
%  g=findobj(gca,'Type','patch');
% set(g(1),'FaceColor',[.9 0 0],'EdgeColor','k');
% set(g(2),'FaceColor',[0 .9 0],'EdgeColor','k');
% set(g(3),'FaceColor',[0 0 .9],'EdgeColor','k');
% 
% legend(conds);
%% 
%% MAke the topo%% ERSP TOPOPLOT
 figure;
for i_cond = 1:nconds
   
    
    %A Topoplot needs to collapse across frequency and time so it can show the data across electrodes
    flims = [15 30]; % set the range of frequency to consider
   
    
    freq_lims = find(freqs>= flims(1),1):find(freqs>=flims(2),1)-1; %this code finds the frequencies you want from the freqs variable
    
    %Here you need a 1D variable, electrodes.
    %By default it will take the mean across participants, events, times and frequencies, and show the data for each set
    %ersp_power(:,i_cond,:,:,exp.brainelecs,freq_lims,time_lims) = 
    
    set_elec_ersp = squeeze(mean(mean(power_out(freq_lims,:,i_cond,:, :), 1), 2))
    %set_elec_ersp = squeeze(mean(mean(mean(ersp(:,i_cond,:,:,exp.brainelecs,freq_lims,time_lims),1),6),7))'
    %[ersp(i_electrode,:,:),itc(i_chan,:,:),powbase,times,freqs,dum1,dum2,all_ersp(i_chan).trials]  = pop_newtimef( EEG, 1, i_chan, exp.epochslims*1000, exp.cycles , ...
%   'topovec', i_chan, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'Pz', 'baseline', exp.erspbaseline, 'freqs', exp.freqrange, 'freqscale', 'linear', ...
%original 
%[ersp(i_chan,:,:),itc(i_chan,:,:),powbase,times,freqs,dum1,dum2,all_ersp(i_chan).trials]  = pop_newtimef( EEG, 1, i_chan, exp.epochslims*1000, exp.cycles , ...
%   'topovec', i_chan, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'Pz', 'baseline', exp.erspbaseline, 'freqs', exp.freqrange, 'freqscale', 'linear', ...

    %This variable sets the scale of the color axis, which corresponds to the itc or power values.
    CLim = ([1.25 2.5]);
    subplot(1,3,i_cond)
    %This code creates the topoplots. You need to replace all the non-brain electrodes with NaN.
    topoplot([set_elec_ersp' NaN NaN NaN],'M:\Analysis\Electrodelocs\Vamp_EOG_electrode_locs.ced','maplimits',CLim,'plotrad',0.6,'whitebk','on','colormap',parula); colorbar;
    
    %Make a Title
  %  title([conds{i_cond} ' at frequencies 8-12Hz'])
end

%% Condition Diff Topo
%% MAke the topo%% ERSP TOPOPLOT
 figure;
%for i_cond = 1:nconds
   
    
    %A Topoplot needs to collapse across frequency and time so it can show the data across electrodes
    flims = [15 30]; % set the range of frequency to consider
   
    
    freq_lims = find(freqs>= flims(1),1):find(freqs>=flims(2),1)-1; %this code finds the frequencies you want from the freqs variable
    
    %Here you need a 1D variable, electrodes.
    %By default it will take the mean across participants, events, times and frequencies, and show the data for each set
    %ersp_power(:,i_cond,:,:,exp.brainelecs,freq_lims,time_lims) = 
    
    set_elec_ersp = squeeze(mean(mean(power_out(freq_lims,:,2,:, :), 1), 2))-squeeze(mean(mean(power_out(freq_lims,:,1,:, :), 1), 2))
    %set_elec_ersp = squeeze(mean(mean(mean(ersp(:,i_cond,:,:,exp.brainelecs,freq_lims,time_lims),1),6),7))'
    %[ersp(i_electrode,:,:),itc(i_chan,:,:),powbase,times,freqs,dum1,dum2,all_ersp(i_chan).trials]  = pop_newtimef( EEG, 1, i_chan, exp.epochslims*1000, exp.cycles , ...
%   'topovec', i_chan, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'Pz', 'baseline', exp.erspbaseline, 'freqs', exp.freqrange, 'freqscale', 'linear', ...
%original 
%[ersp(i_chan,:,:),itc(i_chan,:,:),powbase,times,freqs,dum1,dum2,all_ersp(i_chan).trials]  = pop_newtimef( EEG, 1, i_chan, exp.epochslims*1000, exp.cycles , ...
%   'topovec', i_chan, 'elocs', EEG.chanlocs, 'chaninfo', EEG.chaninfo, 'caption', 'Pz', 'baseline', exp.erspbaseline, 'freqs', exp.freqrange, 'freqscale', 'linear', ...

    %This variable sets the scale of the color axis, which corresponds to the itc or power values.
    CLim = ([-1.5  1.5]);
    %subplot(1,2,i_cond)
    %This code creates the topoplots. You need to replace all the non-brain electrodes with NaN.
    topoplot([set_elec_ersp' NaN NaN NaN],'M:\Analysis\Electrodelocs\Vamp_EOG_electrode_locs.ced','maplimits',CLim,'plotrad',0.6,'whitebk','on','colormap',parula); colorbar;
 title('Post-Pre');   
  