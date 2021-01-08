clear all

ankle_acc = readtable('ankle_acc.csv');
thigh_acc = readtable('thigh_acc.csv');
hip_acc = readtable('hip_acc.csv');
ankle_gyro = readtable('ankle_gyro.csv');
thigh_gyro = readtable('thigh_gyro.csv');
hip_gyro = readtable('hip_gyro.csv');
ankle_press = readtable('ankle_press.csv');
thigh_press = readtable('thigh_press.csv');
hip_press = readtable('hip_press.csv');

offset = max([ankle_acc.epoch_ms_(1) thigh_acc.epoch_ms_(1) hip_acc.epoch_ms_(1) ankle_gyro.epoch_ms_(1) thigh_gyro.epoch_ms_(1) hip_gyro.epoch_ms_(1)  ankle_press.epoch_ms_(1) thigh_press.epoch_ms_(1) hip_press.epoch_ms_(1)])

acc_a = timeseries([ankle_acc.x_axis_g_ ankle_acc.y_axis_g_ ankle_acc.z_axis_g_],(ankle_acc.epoch_ms_-offset)./1000);
acc_t = timeseries([thigh_acc.x_axis_g_ thigh_acc.y_axis_g_ thigh_acc.z_axis_g_],(thigh_acc.epoch_ms_-offset)./1000);
acc_h = timeseries([hip_acc.x_axis_g_ hip_acc.y_axis_g_ hip_acc.z_axis_g_],(hip_acc.epoch_ms_-offset)./1000);

gyr_a = timeseries([ankle_gyro.x_axis_deg_s_ ankle_gyro.y_axis_deg_s_ ankle_gyro.z_axis_deg_s_],(ankle_gyro.epoch_ms_-offset)./1000);
gyr_t = timeseries([thigh_gyro.x_axis_deg_s_ thigh_gyro.y_axis_deg_s_ thigh_gyro.z_axis_deg_s_],(thigh_gyro.epoch_ms_-offset)./1000);
gyr_h = timeseries([hip_gyro.x_axis_deg_s_ hip_gyro.y_axis_deg_s_ hip_gyro.z_axis_deg_s_],(hip_gyro.epoch_ms_-offset)./1000);

%
pre_a = timeseries(ankle_press.pressure_Pa_,(ankle_press.epoch_ms_-offset)./1000);
pre_t = timeseries(thigh_press.pressure_Pa_,(thigh_press.epoch_ms_-offset)./1000);
pre_h = timeseries(hip_press.pressure_Pa_,(hip_press.epoch_ms_-offset)./1000);


new_time = 0:1/50:(25*60);

acc_a = resample(acc_a,new_time);
acc_t = resample(acc_t,new_time);
acc_h = resample(acc_h,new_time);
gyr_a = resample(gyr_a,new_time);
gyr_t = resample(gyr_t,new_time);
gyr_h = resample(gyr_h,new_time);
pre_a = resample(pre_a,new_time);
pre_t = resample(pre_t,new_time);
pre_h = resample(pre_h,new_time);
%

plot(acc_a.Time,acc_a.Data(:,1))
hold on
plot(acc_t.Time,acc_t.Data(:,1));
plot(acc_h.Time,acc_h.Data(:,1));

hold off
%%
% subplot(3,1,1);
% plot(acc_t.Time,acc_t.Data(:,1))
% hold on
% plot(acc_t.Time,acc_t.Data(:,2));
% plot(acc_t.Time,acc_t.Data(:,3));
% 
% hold off
% 
% subplot(3,1,2);
% plot(acc_a.Time,acc_a.Data(:,1))
% hold on
% plot(acc_a.Time,acc_a.Data(:,2));
% plot(acc_a.Time,acc_a.Data(:,3));
% hold off
% 
% subplot(3,1,3);
% plot(acc_h.Time,acc_h.Data(:,1))
% hold on
% plot(acc_h.Time,acc_h.Data(:,2));
% plot(acc_h.Time,acc_h.Data(:,3));
% hold off

%%
first_jump = 43.02;

activity = readtable('activity.csv');
act_on = table2array((activity(:,1)))./1000 + first_jump;
act_off = table2array((activity(:,2)))./1000 + first_jump;

act_char = table2array(activity(:,3));
act = NaN(size(act_char));

for i = 1:numel(act_char)
    switch char(act_char(i))
        case 'u'
            act(i) = 1;
        case 'w'
            act(i) = 2;
        case 'p'
            act(i) = 3;
        case 'c'
            act(i) = 4;
        case 'hw'
            act(i) = 5;
        case 'hs'
            act(i) = 6;
        case 'ss'
            act(i) = 7;
        case 'sc'
            act(i) = 8;
        case 'sr'
            act(i) = 9;
        case 'l'
            act(i) = 10;
        case '99'
            %act(i) = 99;
    end
end
            

% act(act == 5) = 3;
% act(act == 6) = 2;
% act(act == 99) = NaN;

%%Check sync
plot(acc_t.Time,acc_t.Data(:,2))
hold on
%plot(acc_a.Time,acc_a.Data(:,2));
plot(acc_a.Time,acc_a.Data(:,3));
vline(act_on,'k')
hold off


class = NaN(size(acc_t.Time));
class_act = timeseries(class, acc_t.Time);

for i = 1:length(class)
    if class_act.Time(i) < act_off(end-1)
        if not(isempty(act(find(class_act.Time(i) > act_on, 1, 'last'))))
            class_act.Data(i) = act(find(class_act.Time(i) > act_on, 1, 'last'));
        end
    end
end


% Write new feature extraction algorithm
varnames = {'time', 'x1', 'y1', 'z1', 'x2','y2','z2','x3','y3','z3','x1d', 'y1d', 'z1d', 'x2d','y2d','z2d','x3d','y3d','z3d','p1','p2','p3','class'};
ds = table(acc_t.Time, acc_a.Data(:,1),acc_a.Data(:,2),acc_a.Data(:,3), ...
    acc_t.Data(:,1), acc_t.Data(:,2),acc_t.Data(:,3),...
    acc_h.Data(:,1),acc_h.Data(:,2),acc_h.Data(:,3),...
    gyr_a.Data(:,1),gyr_a.Data(:,2),gyr_a.Data(:,3),...
    gyr_t.Data(:,1),gyr_t.Data(:,2),gyr_t.Data(:,3),...
    gyr_h.Data(:,1),gyr_h.Data(:,2),gyr_h.Data(:,3),...
    pre_a.Data, pre_t.Data, pre_h.Data, class_act.Data, 'VariableNames',varnames);


starti = find(not(isnan(ds.class)),1,'first');
stopi = find(not(isnan(ds.class)),1,'last');


ds = ds(starti:stopi,:);
ds_out = table();
w = 100;
indices = 1:w/4:height(ds)-101;
%for i = 1:10
for i = 1:length(indices)
    clear ds_n
    ds_n = table();

    ds_t = ds(indices(i):indices(i)+w,:);
    
    ds_n.time = mean(ds_t.time);
    ds_n.class = mode(ds_t.class);
    ds_n.class_prop = sum(ds_t.class == ds_n.class)/height(ds_t);
    
    sum1 = ds_t.x1 + ds_t.y1 + ds_t.z1;
    sum2 = ds_t.x2 + ds_t.y2 + ds_t.z2;
    sum3 = ds_t.x3 + ds_t.y3 + ds_t.z3;
    
    ds_n.a_sum = sum(sum1);
    ds_n.t_sum = sum(sum2);
    ds_n.h_sum = sum(sum3);
    
    ds_n.corr_13 = corr(sum1, sum3);
    ds_n.corr_12 = corr(sum1, sum2);
    ds_n.corr_23 = corr(sum2, sum3);
    
    ds_n.diff_p13 = mean(ds_t.p3 - ds_t.p1);
    ds_n.diff_p12 = mean(ds_t.p2 - ds_t.p1);
    ds_n.diff_p23 = mean(ds_t.p3 - ds_t.p2);
    
    %from here only using varfun, no more manual stats
    ds_t.time = [];
    ds_t.class = [];
    ds_n = horzcat(ds_n, varfun(@mean, ds_t));
    ds_n = horzcat(ds_n, varfun(@std, ds_t));
    ds_n = horzcat(ds_n, varfun(@skewness, ds_t));
    ds_n = horzcat(ds_n, varfun(@kurtosis, ds_t));
    
    ds_tfft = varfun(@fft, ds_t);
    ds_tfft = varfun(@abs, ds_tfft);
    ds_tfft = ds_tfft(1:w/2+1,:);
    
    ds_n = horzcat(ds_n, varfun(@(A) find(A == max(A(:))), ds_tfft));
    ds_n = horzcat(ds_n, varfun(@max, ds_tfft));
  
    ds_out = vertcat(ds_out, ds_n);
    
end
%
writetable(ds_out,'classification.txt')