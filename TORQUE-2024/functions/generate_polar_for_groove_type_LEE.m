%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           --- LEE2AERO ---                              %
% Opensource machine learning based tool for assessing blade performance  % 
%          impairment due to general leading edge degradation             %                      
%                           ----------------                              %
%                              Software by:                               %
%        Alessio Castorrini, Andrea Ortolani, Edmondo Minisci,            %
%                         M. Sergio Campobasso                            %
%                                                                         %
%                          Reference article:                             %
% Opensource machine learning metamodels for assessing blade performance  %
% impairment due to general leading edge degradation, Journal of Physics: % 
% Conference Series, Vol. xxxx, no.x, ref. xxxxxx, June 2024. DOI: xxxxxxxxx.
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% - This function script generates the lift and drag curves of a 
%   NACA64(3) 618 featuring a geometrically resolved chordwise groove, 
%   assumed to be caused by severe erosion, in the underlying CFD simulations. 
%   The chord-based Reynolds number is 9 M, and the lift and drag curves are 
%   provided for angle of attack between -10 and 16 degrees. 
%
%   The function has two input variables, 
%   - damage_parameters vector of components: su,sl,d
%   with:
%   1) curvilinear extent of roughness on upper side per unit chord (su). 
%   2) curvilinear extent of roughness on lower side per unit chord  (sl), 
%   3) groove depth per unit chord (d).
%   
% - Following constraints should be observed: 
%   0.05%<d<0.75%, -2<sl<4, -2<su<4.
%
% - The authors of the aforementioned software declare that they deny any 
%   and all liability for any damages arising out of using the considered 
%   software, as well as deny any implied warranties.

function generate_polar_for_groove_type_LEE(damage_parameters, activate_plots)

minSu = -2;
maxSu = 4;
minSl = -2;
maxSl = 4;
mind = 0.05;
maxd = 0.75;

%% Check damage provided if it is in the supported range
if (damage_parameters(1)<minSu || damage_parameters(1)>maxSu)
    error("The value provided for su/c variable is out of range of supported values, supported range is: "+minSu+" % < su/l < "+minSu+" %");
end
if (damage_parameters(2)<minSl || damage_parameters(2)>maxSl)
    error("The value provided for sl/c variable is out of range of supported values, supported range is: "+minSl+" % < su/l < "+minSl+" %");
end
if (damage_parameters(3)<mind || damage_parameters(3)>maxd)
    error("The value provided for d/c variable is out of range of supported values, supported range is: "+mind+" % < su/l < "+mind+" %");
end

%% Computation
% Add the folder
DirNewNets = 'ANNs_grooves';
addpath(DirNewNets)

% Define AoA range
AoA = -10:0.5:16;
aoa_length = length(AoA);

% Feature definition
xData=[0.01*damage_parameters(1)*ones(aoa_length,1) 0.01*damage_parameters(2)*ones(aoa_length,1) 0.01*damage_parameters(3)*ones(aoa_length,1) AoA'];

% Feature augmentation
x=[xData xData(:,1).*xData(:,2) xData(:,1).*xData(:,3) xData(:,1).*xData(:,4) xData(:,2).*xData(:,3) xData(:,2).*xData(:,4) xData(:,3).*xData(:,4) xData(:,1).^2 xData(:,2).^2 xData(:,3).^2 xData(:,4).^2];

% Call ANNs and compute the aerodynamic coefficients
Cl=ANN_CL(x');
Cd = ANN_CD(x');
polar = [AoA', Cl', Cd'];

% plot polars
if activate_plots == 1
    x0=0;
    y0=0;
    width=1200;
    height=400;
    figure
    subplot(1,2,1)
    plot(polar(:,1),polar(:,2),'k--x','LineWidth',1.5)
    xlabel("AoA [°]")
    ylabel("Cl")
    subplot(1,2,2)
    plot(polar(:,3),polar(:,2),'k--x','LineWidth',1.5)
    xlabel("Cd")
    ylabel("Cl")
    set(gcf,'position',[x0,y0,width,height])
end


fid = fopen("Polar.csv","w");
fprintf(fid, "AoA[°],\tCl,\tCd\n");
for i=1:aoa_length
    fprintf(fid, "%f,\t%f,\t%f\n",polar(i,1),polar(i,2),polar(i,3));
end
fclose(fid);

end

