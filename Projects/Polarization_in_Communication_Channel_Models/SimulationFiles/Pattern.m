%% Pattern Handler
classdef Pattern < handle
  properties
    Nmodes = 0; % Number of modes / ports
    AngRes = 0; % [???] Angular resolution
    Angles; % Matrix to store all angles of the pattern data
    Ephi; % Matrix which holds the Electric field in phi-domain loaded 
    Ethe; % Matrix which holds the Electric field in theta-domain loaded
    Nphi = 0; % Number of values in phi domain
    Nthe = 0; % Number of values in theta domain
    filename = HorPol_NAnt4_NPorts4.it;
  end
  
  methods
    function P = Pattern(filename) 
      P.filename = filename;
      P.loadPattern();
    end
    
    function loadPattern(P)
      itload(P.filename);
      P.Angles = Angles;
      P.AngRes = Angles(1,2)- Angles(1,1);
      P.AngRes = P.AngRes / pi * 180; % Store angle resolution in degree
      P.Ephi = Ephi009;
      P.Ethe = Ethe009;
      P.Nmodes = min(size(P.Ephi));
      P.Nphi = 360 / P.AngRes;
      P.Nthe = 180 / P.AngRes + 1;
    end
    
    function Ephi = getEphi(P)
      Ephi = P.Ephi;
    end
    
    function Ethe = getEthe(P)
      Ethe = P.Ethe;
    end
  end
  
  methods
    function idx = getIndexOfAngle(P,phi,the)
      % New Modification to handle negative values and values beyond twice the angular range
      
      phi_ind = round(phi / P.AngRes);
      the_ind = round(the / P.AngRes);
      
      phi = phi_ind * P.AngRes;
      the = the_ind * P.AngRes;
      
      if the > 180 || the < 0
        warningtext = 'no';
        warningtext = warningtext + 'Theta is outside 0 - 180 degree. Might result in chnages of phi. \nTheta is ';
        warningtext = warningtext + num2str(the);
        warning(warningtext.char);

        sector = floor(the / 180);
        if mod(sector,2)
          warning('phi is altered');
          the = 180 - mod(the,180);
          phi = phi + 180;
        else
          the = mod(the,180);
        end
      end
      
      if phi >= 360 || phi < 0
        phi = mod(phi, 360);
      end
      
      phi_ind = round(phi / P.AngRes);
      the_ind = round(the / P.AngRes);
      
      idx = phi_ind * P.Nthe + the_ind + 1;
      if idx > 2664
          warning('If 5 degree resolution, index too high!\n');
      end
    end
 
    function [ephi,ethe] = getFieldOfAngle(P,phi,the)
      idx = P.getIndexOfAngle(phi,the);
      ephi = P.Ephi(:,idx);
      ethe = P.Ethe(:,idx); 
    end
    
    function angles = getPatternAngles(P)
      angles = P.Angles;
    end
  end
end
